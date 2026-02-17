import Foundation
import RealityKit

struct StackPhysicsSystem: System {
    static let memberQuery = EntityQuery(where: .has(StackMemberComponent.self))
    static let controllerQuery = EntityQuery(where: .has(StackControllerComponent.self))

    init(scene: RealityKit.Scene) {}

    func update(context: SceneUpdateContext) {
        // Build a map of stack root positions
        var stackPositions: [String: SIMD3<Float>] = [:]
        for stackEntity in context.entities(matching: Self.controllerQuery, updatingSystemWhen: .rendering) {
            stackPositions[stackEntity.name] = stackEntity.position(relativeTo: nil)
        }

        // Check each block to see if it has fallen off its stack
        for entity in context.entities(matching: Self.memberQuery, updatingSystemWhen: .rendering) {
            guard var member = entity.components[StackMemberComponent.self] else { continue }
            guard member.isAttached else { continue }

            let blockWorldPos = entity.position(relativeTo: nil)
            var detached = false

            // Check 1: Block fell below ground
            if blockWorldPos.y < GameConfiguration.Physics.blockFallThreshold {
                detached = true
            }

            // Check 2: Block is lying on its side (Y position too low for its stack index)
            // A block at index N should be at least at Y = N * 0.15 if stacked properly
            if !detached && member.index > 0 {
                if blockWorldPos.y < Float(member.index) * 0.15 {
                    detached = true
                }
            }

            // Check 3: Block drifted horizontally from its stack
            if !detached {
                let stackName = "stack_\(member.stackID)"
                if let stackPos = stackPositions[stackName] {
                    let dx = blockWorldPos.x - stackPos.x
                    let dz = blockWorldPos.z - stackPos.z
                    let dist = sqrt(dx * dx + dz * dz)
                    if dist > GameConfiguration.Physics.blockDetachDistance {
                        detached = true
                    }
                }
            }

            // Check 4: Block orientation — tilted too far
            if !detached {
                let rotation = entity.orientation(relativeTo: nil)
                let up = rotation.act(SIMD3<Float>(0, 1, 0))
                let tiltAngle = acos(min(max(up.y, -1.0), 1.0))
                let thresholdRad = GameConfiguration.Physics.blockTiltThreshold * (.pi / 180.0)
                if tiltAngle > thresholdRad {
                    detached = true
                }
            }

            if detached {
                member.isAttached = false
                entity.components.set(member)
            }
        }

        // Count attached blocks per stack and update controllers
        // Use the member query to count by stackID since children iteration might miss physics-driven entities
        var attachedCounts: [String: Int] = [:]
        for entity in context.entities(matching: Self.memberQuery, updatingSystemWhen: .rendering) {
            guard let member = entity.components[StackMemberComponent.self] else { continue }
            if member.isAttached {
                attachedCounts[member.stackID, default: 0] += 1
            }
        }

        for stackEntity in context.entities(matching: Self.controllerQuery, updatingSystemWhen: .rendering) {
            guard var controller = stackEntity.components[StackControllerComponent.self] else { continue }

            let teamName = controller.team == .player ? "player" : "opponent"
            let count = attachedCounts[teamName] ?? 0
            controller.attachedBlockCount = count

            if count < GameConfiguration.Physics.minBlocksToSurvive && !controller.hasToppled {
                controller.hasToppled = true
            }

            stackEntity.components.set(controller)
        }
    }
}
