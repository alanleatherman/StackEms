import Foundation

@Observable
final class AppContainer {
    let appState: AppState
    let matchInteractor: MatchInteractor
    let stackBuilderInteractor: StackBuilderInteractor
    let profileInteractor: ProfileInteractor
    let matchCoordinator: MatchCoordinator

    init(appState: AppState = AppState()) {
        self.appState = appState
        self.matchInteractor = MatchInteractor(matchState: appState.matchState, profileState: appState.profileState)
        self.stackBuilderInteractor = StackBuilderInteractor(matchState: appState.matchState)
        self.profileInteractor = ProfileInteractor(profileState: appState.profileState)
        self.matchCoordinator = MatchCoordinator(
            matchState: appState.matchState,
            matchInteractor: self.matchInteractor
        )
    }
}
