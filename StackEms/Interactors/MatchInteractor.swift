import Foundation

@Observable
final class MatchInteractor {
    private let matchState: MatchState
    private let profileState: ProfileState

    init(matchState: MatchState, profileState: ProfileState) {
        self.matchState = matchState
        self.profileState = profileState
    }

    func startMatch() {
        matchState.phase = .countdown
        matchState.matchTimer = 0
        matchState.playerBlocksRemaining = matchState.playerBlueprint.blocks.count
        matchState.opponentBlocksRemaining = matchState.opponentBlueprint.blocks.count
    }

    func beginCombat() {
        matchState.phase = .combat
    }

    func endMatch(playerWon: Bool) {
        let result = MatchResult(
            playerWon: playerWon,
            playerBlocksRemaining: matchState.playerBlocksRemaining,
            opponentBlocksRemaining: matchState.opponentBlocksRemaining,
            matchDuration: matchState.matchTimer
        )
        matchState.phase = .result(result)
        profileState.recordResult(result)
    }

    func returnToMenu() {
        matchState.phase = .menu
        matchState.isPaused = false
    }

    func goToPlanning() {
        matchState.phase = .planning
    }
}
