import SwiftUI
import RealityKit

@main
struct StackEmsApp: App {
    @State private var appContainer = AppContainer()

    init() {
        StackMemberComponent.registerComponent()
        StackControllerComponent.registerComponent()
        HealthComponent.registerComponent()
        TeamComponent.registerComponent()
        SwipeableComponent.registerComponent()
        CameraTargetComponent.registerComponent()
        AIControlledComponent.registerComponent()
        StackPhysicsSystem.registerSystem()
        SwipeForceSystem.registerSystem()
        StackMovementSystem.registerSystem()
        CameraFollowSystem.registerSystem()
        AIBehaviorSystem.registerSystem()
        WinConditionSystem.registerSystem()
    }

    var body: some SwiftUI.Scene {
        WindowGroup {
            MainAppView(appContainer: appContainer)
        }
    }
}
