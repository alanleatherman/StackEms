import RealityKit

struct SwipeForceSystem: System {
    static let query = EntityQuery(where: .has(SwipeableComponent.self) && .has(PhysicsBodyComponent.self))

    init(scene: RealityKit.Scene) {}

    func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard var swipeable = entity.components[SwipeableComponent.self],
                  let impulse = swipeable.pendingImpulse else { continue }

            let clampedForce = min(
                length(impulse),
                GameConfiguration.Physics.maxSwipeForce
            )
            let direction = normalize(impulse)
            let finalImpulse = direction * clampedForce * swipeable.forceMultiplier

            (entity as? ModelEntity)?.addForce(finalImpulse, relativeTo: nil)

            swipeable.pendingImpulse = nil
            swipeable.lastSwipeTime = context.deltaTime
            entity.components.set(swipeable)
        }
    }
}
