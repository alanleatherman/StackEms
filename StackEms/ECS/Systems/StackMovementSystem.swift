import RealityKit

struct StackMovementSystem: System {
    static let query = EntityQuery(where: .has(StackControllerComponent.self))

    init(scene: RealityKit.Scene) {}

    func update(context: SceneUpdateContext) {
        guard WinConditionSystem.combatActive else { return }
        let dt = Float(context.deltaTime)

        // Collect all stack positions for collision avoidance
        var stackPositions: [(entity: Entity, position: SIMD3<Float>, team: StackControllerComponent.Team)] = []
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard let controller = entity.components[StackControllerComponent.self] else { continue }
            stackPositions.append((entity, entity.position(relativeTo: nil), controller.team))
        }

        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard let controller = entity.components[StackControllerComponent.self] else { continue }
            guard !controller.hasToppled else { continue }

            let steerInput = controller.movementInput.x
            let forwardInput = controller.movementInput.y

            // Only move/steer when there's input
            guard abs(steerInput) > 0.05 || abs(forwardInput) > 0.05 else { continue }

            // Steering rotation
            let steerAngle = steerInput * GameConfiguration.Movement.maxSteerAngle * (.pi / 180) * dt
            let steerRotation = simd_quatf(angle: -steerAngle, axis: SIMD3<Float>(0, 1, 0))
            entity.transform.rotation = steerRotation * entity.transform.rotation

            // Forward/backward movement based on joystick Y
            let forward = -entity.transform.matrix.columns.2
            let forwardDir = SIMD3<Float>(forward.x, 0, forward.z)
            let normalizedForward = length(forwardDir) > 0 ? normalize(forwardDir) : SIMD3<Float>(0, 0, -1)

            var movement = normalizedForward * forwardInput * controller.movementSpeed * dt
            var newPos = entity.position + movement

            // Collision with other stacks — prevent overlap at block size
            let minDist: Float = 0.5 // roughly half a block width per stack
            for other in stackPositions where other.team != controller.team {
                let diff = SIMD3<Float>(newPos.x - other.position.x, 0, newPos.z - other.position.z)
                let dist = length(diff)
                if dist < minDist && dist > 0.01 {
                    let pushDir = normalize(diff)
                    newPos = other.position + pushDir * minDist
                }
            }

            // Clamp to arena bounds
            let arenaHalf = GameConfiguration.Arena.groundSize / 2 - 1.0
            newPos.x = max(-arenaHalf, min(arenaHalf, newPos.x))
            newPos.z = max(-arenaHalf, min(arenaHalf, newPos.z))

            entity.position = newPos
        }
    }
}
