import SwiftUI

struct MainAppView: View {
    let appContainer: AppContainer
    @State private var appState: AppState

    init(appContainer: AppContainer) {
        self.appContainer = appContainer
        self._appState = State(initialValue: appContainer.appState)
    }

    var body: some View {
        Group {
            switch appState.matchState.phase {
            case .menu:
                MainMenuView()
            case .squad:
                SquadView()
            case .planning:
                PlanningView()
            case .countdown, .combat:
                CombatView()
                    .id(appState.matchState.matchID)
            case .result(let result):
                ResultsView(result: result)
            }
        }
        .appEnvironment(appContainer)
    }
}
