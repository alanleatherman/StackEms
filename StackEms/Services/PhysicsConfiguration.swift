import RealityKit

struct PhysicsConfiguration {
    static let playerGroup = CollisionGroup(rawValue: 1 << 0)
    static let opponentGroup = CollisionGroup(rawValue: 1 << 1)
    static let arenaGroup = CollisionGroup(rawValue: 1 << 2)

    static let playerFilter = CollisionFilter(
        group: playerGroup,
        mask: .all
    )

    static let opponentFilter = CollisionFilter(
        group: opponentGroup,
        mask: .all
    )

    static let arenaFilter = CollisionFilter(
        group: arenaGroup,
        mask: .all
    )

    static func physicsMaterial(
        friction: Float = GameConfiguration.Physics.blockFriction,
        restitution: Float = GameConfiguration.Physics.blockRestitution
    ) -> PhysicsMaterialResource {
        .generate(
            staticFriction: friction,
            dynamicFriction: friction * 0.8,
            restitution: restitution
        )
    }

    static func totalStackMass(blueprint: StackBlueprint) -> Float {
        blueprint.blocks.reduce(0) { $0 + $1.mass }
    }
}
