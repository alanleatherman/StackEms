import Foundation
import RealityKit
import os

private let logger = Logger(subsystem: "com.stackems", category: "StackPhysics")

struct StackPhysicsSystem: System {
    static let memberQuery = EntityQuery(where: .has(StackMemberComponent.self))
    static let controllerQuery = EntityQuery(where: .has(StackControllerComponent.self))
    static var combatElapsed: TimeInterval = 0

    init(scene: RealityKit.Scene) {
        StackPhysicsSystem.combatElapsed = 0
    }

    func update(context: SceneUpdateContext) {
        guard WinConditionSystem.combatActive else {
            StackPhysicsSystem.combatElapsed = 0
            return
        }

        // Grace period: let physics settle for 1 second after combat starts
        StackPhysicsSystem.combatElapsed += context.deltaTime
        guard StackPhysicsSystem.combatElapsed > 1.0 else { return }

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
                logger.info("Block \(entity.name) detached (stackID=\(member.stackID), index=\(member.index))")
                member.isAttached = false
                entity.components.set(member)

                // Remove from stack hierarchy so it stops following the stack root
                let worldTransform = entity.transformMatrix(relativeTo: nil)
                if let scene = entity.scene {
                    // Find the root content entity (first entity in the scene)
                    if let sceneRoot = scene.performQuery(Self.controllerQuery).first(where: { _ in true })?.parent {
                        entity.removeFromParent()
                        sceneRoot.addChild(entity)
                        entity.setTransformMatrix(worldTransform, relativeTo: nil)
                    }
                }

                // Fade out and shrink the detached block
                if let modelEntity = entity as? ModelEntity {
                    // Animate: shrink + sink over 1.5 seconds, then remove
                    var fadeTransform = entity.transform
                    fadeTransform.scale = SIMD3<Float>(repeating: 0.1)
                    fadeTransform.translation.y -= 0.5
                    entity.move(to: fadeTransform, relativeTo: entity.parent, duration: 1.5)

                    // Disable physics so it doesn't interfere during fade
                    entity.components.remove(PhysicsBodyComponent.self)
                    entity.components.remove(CollisionComponent.self)

                    // Schedule removal after animation
                    Task { @MainActor in
                        try? await Task.sleep(for: .seconds(1.5))
                        entity.removeFromParent()
                    }
                }
            }
        }

        // Count attached blocks per stack and update controllers
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
                logger.info("Stack \(teamName) toppled! count=\(count)")
                controller.hasToppled = true
            }

            stackEntity.components.set(controller)
        }
    }
}
