import SwiftUI

private struct AppContainerKey: EnvironmentKey {
    nonisolated static let defaultValue: AppContainer = AppContainer()
}

extension EnvironmentValues {
    var appContainer: AppContainer {
        get { self[AppContainerKey.self] }
        set { self[AppContainerKey.self] = newValue }
    }
}

struct AppEnvironmentModifier: ViewModifier {
    let container: AppContainer

    func body(content: Content) -> some View {
        content
            .environment(\.appContainer, container)
            .environment(container.appState)
    }
}

extension View {
    func appEnvironment(_ container: AppContainer) -> some View {
        modifier(AppEnvironmentModifier(container: container))
    }
}
