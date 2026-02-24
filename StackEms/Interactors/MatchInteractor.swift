import Foundation

@Observable
final class MatchInteractor {
    private let matchState: MatchState
    private let profileState: ProfileState
    var onMatchEnd: (() -> Void)?

    init(matchState: MatchState, profileState: ProfileState) {
        self.matchState = matchState
        self.profileState = profileState
    }

    func startMatch() {
        matchState.matchID = UUID()
        matchState.phase = .countdown
        matchState.matchTimer = 0
        matchState.playerBlocksRemaining = matchState.playerBlueprint.blocks.count
        matchState.opponentBlocksRemaining = matchState.opponentBlueprint.blocks.count
    }

    func beginCombat() {
        matchState.phase = .combat
    }

    func endMatch(playerWon: Bool) {
        let rewards = RewardCalculator.calculate(
            playerWon: playerWon,
            playerBlocksRemaining: matchState.playerBlocksRemaining,
            totalPlayerBlocks: matchState.playerBlueprint.blocks.count,
            matchDuration: matchState.matchTimer,
            currentWinStreak: profileState.currentWinStreak,
            currentXP: profileState.xp,
            currentLevel: profileState.level
        )

        let result = MatchResult(
            playerWon: playerWon,
            playerBlocksRemaining: matchState.playerBlocksRemaining,
            opponentBlocksRemaining: matchState.opponentBlocksRemaining,
            matchDuration: matchState.matchTimer,
            coinsEarned: rewards.coinsEarned,
            xpEarned: rewards.xpEarned
        )

        matchState.phase = .result(result)
        profileState.recordResult(result, rewards: rewards)
        onMatchEnd?()
    }

    func returnToMenu() {
        matchState.phase = .menu
        matchState.isPaused = false
    }

    func goToSquad() {
        matchState.phase = .squad
    }

    func goToPlanning() {
        matchState.phase = .planning
    }
}
