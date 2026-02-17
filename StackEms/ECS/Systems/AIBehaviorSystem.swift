import Foundation
import RealityKit

struct AIBehaviorSystem: System {
    static let aiQuery = EntityQuery(where: .has(AIControlledComponent.self) && .has(StackControllerComponent.self))
    static let playerQuery = EntityQuery(where: .has(StackControllerComponent.self))

    init(scene: RealityKit.Scene) {}

    func update(context: SceneUpdateContext) {
        let dt = context.deltaTime

        var playerPosition: SIMD3<Float>?
        for entity in context.entities(matching: Self.playerQuery, updatingSystemWhen: .rendering) {
            guard let controller = entity.components[StackControllerComponent.self] else { continue }
            if controller.team == .player {
                playerPosition = entity.position
            }
        }

        guard let targetPos = playerPosition else { return }

        for entity in context.entities(matching: Self.aiQuery, updatingSystemWhen: .rendering) {
            guard var ai = entity.components[AIControlledComponent.self],
                  var controller = entity.components[StackControllerComponent.self] else { continue }
            guard !controller.hasToppled else { continue }

            ai.timeSinceLastDecision += dt
            ai.timeSinceLastSwipe += dt

            guard ai.timeSinceLastDecision >= ai.reactionTime else {
                entity.components.set(ai)
                continue
            }

            ai.timeSinceLastDecision = 0

            let toPlayer = targetPos - entity.position
            let distance = length(toPlayer)
            let direction = distance > 0 ? normalize(toPlayer) : SIMD3<Float>(0, 0, -1)

            let forward = -entity.transform.matrix.columns.2
            let forwardXZ = SIMD3<Float>(forward.x, 0, forward.z)
            let normalizedForward = length(forwardXZ) > 0 ? normalize(forwardXZ) : SIMD3<Float>(0, 0, -1)

            let cross = normalizedForward.x * direction.z - normalizedForward.z * direction.x
            let steerAmount = max(-1, min(1, cross * 3.0))
            controller.movementInput = SIMD2<Float>(steerAmount * ai.aggression, 0)

            if distance < GameConfiguration.AI.swipeRange &&
               ai.timeSinceLastSwipe >= GameConfiguration.AI.swipeCooldown {

                let shouldSwipe = Float.random(in: 0...1) < ai.aggression
                if shouldSwipe {
                    ai.timeSinceLastSwipe = 0
                    applyAISwipe(entity: entity, direction: direction, context: context)
                }
            }

            let arenaHalf = GameConfiguration.Arena.groundSize / 2
            let avoidDist = GameConfiguration.AI.avoidWallDistance
            if abs(entity.position.x) > arenaHalf - avoidDist {
                let wallSteer = entity.position.x > 0 ? Float(-1) : Float(1)
                controller.movementInput.x += wallSteer * 0.5
            }

            entity.components.set(ai)
            entity.components.set(controller)
        }
    }

    private func applyAISwipe(entity: Entity, direction: SIMD3<Float>, context: SceneUpdateContext) {
        for child in entity.children {
            guard var swipeable = child.components[SwipeableComponent.self] else { continue }
            let force = direction * GameConfiguration.Physics.swipeForceMultiplier * 0.5
            swipeable.pendingImpulse = force
            child.components.set(swipeable)
            break
        }
    }
}
