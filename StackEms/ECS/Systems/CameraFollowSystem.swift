import RealityKit

struct CameraTargetComponent: Component {
    var isActive: Bool = true
}

struct CameraFollowSystem: System {
    static let controllerQuery = EntityQuery(where: .has(StackControllerComponent.self))
    static let cameraQuery = EntityQuery(where: .has(CameraTargetComponent.self))

    init(scene: RealityKit.Scene) {}

    func update(context: SceneUpdateContext) {
        var playerPosition: SIMD3<Float>?
        var playerForward: SIMD3<Float>?

        for entity in context.entities(matching: Self.controllerQuery, updatingSystemWhen: .rendering) {
            guard let controller = entity.components[StackControllerComponent.self] else { continue }
            if controller.team == .player {
                playerPosition = entity.position
                let fwd = -entity.transform.matrix.columns.2
                playerForward = SIMD3<Float>(fwd.x, 0, fwd.z)
            }
        }

        guard let pos = playerPosition,
              let fwd = playerForward,
              length(fwd) > 0 else { return }

        let normalizedForward = normalize(fwd)

        let targetCameraPos = pos
            - normalizedForward * GameConfiguration.Camera.followDistance
            + SIMD3<Float>(0, GameConfiguration.Camera.followHeight, 0)

        let lookTarget = pos + normalizedForward * GameConfiguration.Camera.lookAheadDistance

        for camera in context.entities(matching: Self.cameraQuery, updatingSystemWhen: .rendering) {
            let smoothing = GameConfiguration.Camera.smoothingFactor
            camera.position = mix(camera.position, targetCameraPos, t: smoothing)
            camera.look(at: lookTarget, from: camera.position, relativeTo: camera.parent)
        }
    }
}
