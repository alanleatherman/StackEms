import RealityKit
import UIKit

struct ArenaBuilder {
    static func buildArena() -> Entity {
        let arena = Entity()
        arena.name = "arena"

        arena.addChild(buildGround())
        buildWalls().forEach { arena.addChild($0) }
        arena.addChild(buildDirectionalLight())
        arena.addChild(buildCamera())

        return arena
    }

    private static func buildGround() -> ModelEntity {
        let size = GameConfiguration.Arena.groundSize
        let mesh = MeshResource.generatePlane(width: size, depth: size)
        var material = SimpleMaterial()
        material.color = .init(tint: UIColor(red: 0.15, green: 0.18, blue: 0.15, alpha: 1.0))
        material.roughness = .float(0.8)

        let ground = ModelEntity(mesh: mesh, materials: [material])
        ground.name = "ground"
        ground.position = .zero

        ground.components.set(CollisionComponent(
            shapes: [.generateBox(width: size, height: 0.1, depth: size)],
            filter: .default
        ))
        ground.components.set(PhysicsBodyComponent(
            shapes: [.generateBox(width: size, height: 0.1, depth: size)],
            mass: 0,
            material: .generate(
                staticFriction: GameConfiguration.Physics.groundFriction,
                dynamicFriction: GameConfiguration.Physics.groundFriction,
                restitution: GameConfiguration.Physics.groundRestitution
            ),
            mode: .static
        ))

        return ground
    }

    private static func buildWalls() -> [ModelEntity] {
        let size = GameConfiguration.Arena.groundSize
        let halfSize = size / 2
        let height = GameConfiguration.Arena.wallHeight
        let thickness = GameConfiguration.Arena.wallThickness
        var wallMaterial = SimpleMaterial()
        wallMaterial.color = .init(tint: UIColor(white: 0.4, alpha: 0.3))

        let wallPositions: [(SIMD3<Float>, SIMD3<Float>)] = [
            ([halfSize, height / 2, 0], [thickness, height, size]),
            ([-halfSize, height / 2, 0], [thickness, height, size]),
            ([0, height / 2, halfSize], [size, height, thickness]),
            ([0, height / 2, -halfSize], [size, height, thickness]),
        ]

        return wallPositions.enumerated().map { index, config in
            let (position, wallSize) = config
            let mesh = MeshResource.generateBox(size: wallSize)
            let wall = ModelEntity(mesh: mesh, materials: [wallMaterial])
            wall.name = "wall_\(index)"
            wall.position = position

            wall.components.set(CollisionComponent(
                shapes: [.generateBox(size: wallSize)],
                filter: .default
            ))
            wall.components.set(PhysicsBodyComponent(
                shapes: [.generateBox(size: wallSize)],
                mass: 0,
                mode: .static
            ))

            return wall
        }
    }

    private static func buildDirectionalLight() -> Entity {
        let light = Entity()
        light.name = "directional_light"

        light.components.set(DirectionalLightComponent(
            color: .white,
            intensity: 2000,
            isRealWorldProxy: false
        ))
        light.components.set(DirectionalLightComponent.Shadow())
        light.look(at: .zero, from: [5, 8, 5], relativeTo: nil)

        return light
    }

    private static func buildCamera() -> Entity {
        let camera = PerspectiveCamera()
        camera.name = "game_camera"
        camera.camera.fieldOfViewInDegrees = 60
        camera.position = [0, GameConfiguration.Camera.followHeight, GameConfiguration.Arena.playerStartZ + GameConfiguration.Camera.followDistance]
        camera.look(at: [0, 0, GameConfiguration.Arena.playerStartZ], from: camera.position, relativeTo: nil)
        camera.components.set(CameraTargetComponent())
        return camera
    }
}
