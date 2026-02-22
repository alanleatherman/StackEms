import Foundation
import RealityKit

struct AIBehaviorSystem: System {
    static let aiQuery = EntityQuery(where: .has(AIControlledComponent.self) && .has(StackControllerComponent.self))
    static let playerQuery = EntityQuery(where: .has(StackControllerComponent.self))

    // Distance thresholds
    private let circleRange: Float = 4.0
    private let chargeRange: Float = 2.5
    private let ramRange: Float = 1.2
    private let retreatDistance: Float = 5.0

    init(scene: RealityKit.Scene) {}

    func update(context: SceneUpdateContext) {
        guard WinConditionSystem.combatActive else { return }
        let dt = context.deltaTime

        // Find player position
        var playerPosition: SIMD3<Float>?
        for entity in context.entities(matching: Self.playerQuery, updatingSystemWhen: .rendering) {
            guard let controller = entity.components[StackControllerComponent.self] else { continue }
            if controller.team == .player {
                playerPosition = entity.position(relativeTo: nil)
            }
        }

        guard let targetPos = playerPosition else { return }

        for entity in context.entities(matching: Self.aiQuery, updatingSystemWhen: .rendering) {
            guard var ai = entity.components[AIControlledComponent.self],
                  var controller = entity.components[StackControllerComponent.self] else { continue }
            guard !controller.hasToppled else { continue }

            ai.timeSinceLastDecision += dt
            ai.timeSinceLastSwipe += dt
            ai.phaseTimer += dt

            guard ai.timeSinceLastDecision >= ai.reactionTime else {
                entity.components.set(ai)
                continue
            }

            ai.timeSinceLastDecision = 0

            let aiPos = entity.position(relativeTo: nil)
            let toPlayer = targetPos - aiPos
            let horizontalToPlayer = SIMD3<Float>(toPlayer.x, 0, toPlayer.z)
            let distance = length(horizontalToPlayer)
            let dirToPlayer = distance > 0.01 ? normalize(horizontalToPlayer) : SIMD3<Float>(0, 0, 1)

            // Get entity's forward direction
            let fwd = -entity.transform.matrix.columns.2
            let forwardXZ = SIMD3<Float>(fwd.x, 0, fwd.z)
            let normalizedForward = length(forwardXZ) > 0.01 ? normalize(forwardXZ) : SIMD3<Float>(0, 0, -1)

            // How aligned is the AI's forward with the direction to player
            let dot = simd_dot(normalizedForward, dirToPlayer)
            // Cross product for steering direction (positive = turn right)
            let cross = normalizedForward.x * dirToPlayer.z - normalizedForward.z * dirToPlayer.x

            // Phase transitions
            updatePhase(ai: &ai, distance: distance, dot: dot)

            // Compute desired movement direction (world space) and convert to steer+drive
            var desiredDir = dirToPlayer // default: toward player
            var speed: Float = ai.aggression * 0.7

            switch ai.phase {
            case .chase:
                desiredDir = dirToPlayer
                speed = ai.aggression * 0.7

            case .circle:
                // Perpendicular to player direction (strafing)
                let perpX = -dirToPlayer.z * ai.circleDirection
                let perpZ = dirToPlayer.x * ai.circleDirection
                // Mix in some toward-player bias so we don't drift away
                desiredDir = normalize(SIMD3<Float>(perpX, 0, perpZ) + dirToPlayer * 0.3)
                speed = 0.4 + ai.aggression * 0.2

                if ai.phaseTimer > 1.5 && Float.random(in: 0...1) < 0.02 {
                    ai.circleDirection *= -1
                }

            case .charge:
                desiredDir = dirToPlayer
                speed = 1.0

            case .retreat:
                desiredDir = -dirToPlayer // away from player
                speed = 0.6
            }

            // Convert desired world direction to steer + drive inputs
            // Steer: how much to turn toward desired direction
            let desiredDot = simd_dot(normalizedForward, desiredDir)
            let desiredCross = normalizedForward.x * desiredDir.z - normalizedForward.z * desiredDir.x
            let steer = max(-1.0, min(1.0, desiredCross * 3.0))

            // Drive: move forward when facing the right way, reverse when facing wrong way
            let drive: Float
            if desiredDot > 0.3 {
                drive = speed // facing roughly correct direction, go forward
            } else if desiredDot < -0.3 {
                drive = -speed * 0.5 // facing wrong way, reverse while turning
            } else {
                drive = speed * 0.2 // perpendicular, crawl forward while turning
            }

            controller.movementInput = SIMD2<Float>(steer, drive)

            // Swipe attack when in range
            if distance < ramRange &&
               ai.timeSinceLastSwipe >= GameConfiguration.AI.swipeCooldown * TimeInterval(1.5 - ai.aggression) {
                if Float.random(in: 0...1) < ai.aggression {
                    ai.timeSinceLastSwipe = 0
                    applyAISwipe(entity: entity, direction: dirToPlayer)
                }
            }

            // Hard wall clamp — prevent going off arena
            let arenaHalf = GameConfiguration.Arena.groundSize / 2 - 1.0
            var clampedPos = aiPos
            clampedPos.x = max(-arenaHalf, min(arenaHalf, clampedPos.x))
            clampedPos.z = max(-arenaHalf, min(arenaHalf, clampedPos.z))
            if clampedPos != aiPos {
                entity.position = clampedPos
                // Override: steer back toward center
                let toCenter = -normalize(SIMD3<Float>(clampedPos.x, 0, clampedPos.z))
                let centerCross = normalizedForward.x * toCenter.z - normalizedForward.z * toCenter.x
                controller.movementInput.x = max(-1, min(1, centerCross * 4.0))
                controller.movementInput.y = simd_dot(normalizedForward, toCenter) > 0 ? 0.8 : -0.4
            }

            entity.components.set(ai)
            entity.components.set(controller)
        }
    }

    private func updatePhase(ai: inout AIControlledComponent, distance: Float, dot: Float) {
        switch ai.phase {
        case .chase:
            if distance < circleRange {
                ai.phase = .circle
                ai.phaseTimer = 0
                ai.circleDirection = Bool.random() ? 1 : -1
            }

        case .circle:
            let circleTime = 1.5 - TimeInterval(ai.aggression)
            if ai.phaseTimer > circleTime && dot > 0.5 && distance < chargeRange * 1.5 {
                ai.phase = .charge
                ai.phaseTimer = 0
                ai.chargesBeforeRetreat += 1
            }
            if distance > circleRange * 1.3 {
                ai.phase = .chase
                ai.phaseTimer = 0
            }

        case .charge:
            if distance < ramRange || ai.phaseTimer > 2.0 {
                if ai.chargesBeforeRetreat >= 2 || Float.random(in: 0...1) < 0.4 {
                    ai.phase = .retreat
                    ai.phaseTimer = 0
                    ai.chargesBeforeRetreat = 0
                } else {
                    ai.phase = .circle
                    ai.phaseTimer = 0
                    ai.circleDirection *= -1
                }
            }

        case .retreat:
            let retreatTime: TimeInterval = 1.0 + TimeInterval(1.0 - ai.aggression)
            if ai.phaseTimer > retreatTime || distance > retreatDistance {
                ai.phase = .chase
                ai.phaseTimer = 0
            }
        }
    }

    private func applyAISwipe(entity: Entity, direction: SIMD3<Float>) {
        for child in entity.children {
            guard var swipeable = child.components[SwipeableComponent.self] else { continue }
            let jitter = SIMD3<Float>(
                Float.random(in: -0.3...0.3),
                Float.random(in: 0...0.2),
                Float.random(in: -0.3...0.3)
            )
            let swipeDir = normalize(direction + jitter)
            let force = swipeDir * GameConfiguration.Physics.swipeForceMultiplier * 0.6
            swipeable.pendingImpulse = force
            child.components.set(swipeable)
            break
        }
    }
}
