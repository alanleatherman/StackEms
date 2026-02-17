import RealityKit

struct StackMovementSystem: System {
    static let query = EntityQuery(where: .has(StackControllerComponent.self))

    init(scene: RealityKit.Scene) {}

    func update(context: SceneUpdateContext) {
        let dt = Float(context.deltaTime)

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

            let forwardMovement = normalizedForward * forwardInput * GameConfiguration.Movement.forwardSpeed * dt
            entity.position += forwardMovement
        }
    }
}
