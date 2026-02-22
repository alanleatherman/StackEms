import Foundation
import SwiftData

@Observable
final class AppContainer {
    let appState: AppState
    let matchInteractor: MatchInteractor
    let stackBuilderInteractor: StackBuilderInteractor
    let profileInteractor: ProfileInteractor
    let matchCoordinator: MatchCoordinator
    let upgradeInteractor: UpgradeInteractor
    let persistenceService: PersistenceService?

    init(appState: AppState = AppState()) {
        self.appState = appState

        // Persistence
        let persistence = try? PersistenceService()
        self.persistenceService = persistence

        // Hydrate app state from disk
        persistence?.hydrateAppState(appState)

        // Interactors
        self.matchInteractor = MatchInteractor(matchState: appState.matchState, profileState: appState.profileState)
        self.stackBuilderInteractor = StackBuilderInteractor(matchState: appState.matchState)
        self.profileInteractor = ProfileInteractor(profileState: appState.profileState, settingsState: appState.settingsState)
        self.matchCoordinator = MatchCoordinator(
            matchState: appState.matchState,
            matchInteractor: self.matchInteractor
        )
        self.upgradeInteractor = UpgradeInteractor(profileState: appState.profileState)

        // Wire save callbacks
        self.matchInteractor.onMatchEnd = { [weak self] in
            guard let self else { return }
            self.persistenceService?.persistFromAppState(self.appState)
            if case .result(let result) = self.appState.matchState.phase {
                self.persistenceService?.persistMatchResult(from: result)
            }
        }

        self.stackBuilderInteractor.onTeamChanged = { [weak self] _ in
            guard let self else { return }
            self.persistenceService?.persistFromAppState(self.appState)
        }

        self.profileInteractor.onProfileChanged = { [weak self] in
            guard let self else { return }
            self.persistenceService?.persistFromAppState(self.appState)
        }

        self.upgradeInteractor.onUpgradeChanged = { [weak self] in
            guard let self else { return }
            self.persistenceService?.persistFromAppState(self.appState)
        }
    }
}
