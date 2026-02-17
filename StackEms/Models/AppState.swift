import Foundation

@Observable
final class AppState {
    var matchState: MatchState
    var profileState: ProfileState
    var settingsState: SettingsState

    init(
        matchState: MatchState = MatchState(),
        profileState: ProfileState = ProfileState(),
        settingsState: SettingsState = SettingsState()
    ) {
        self.matchState = matchState
        self.profileState = profileState
        self.settingsState = settingsState
    }
}

@Observable
final class MatchState {
    var phase: MatchPhase = .menu
    var playerBlueprint: StackBlueprint = .defaultBlueprint
    var opponentBlueprint: StackBlueprint = .defaultBlueprint
    var matchTimer: TimeInterval = 0
    var playerBlocksRemaining: Int = 0
    var opponentBlocksRemaining: Int = 0
    var isPaused: Bool = false
}

@Observable
final class ProfileState {
    var playerName: String = "Player"
    var wins: Int = 0
    var losses: Int = 0
    var matchHistory: [MatchResult] = []

    var totalMatches: Int { wins + losses }

    var winRate: Double {
        guard totalMatches > 0 else { return 0 }
        return Double(wins) / Double(totalMatches)
    }

    func recordResult(_ result: MatchResult) {
        if result.playerWon {
            wins += 1
        } else {
            losses += 1
        }
        matchHistory.append(result)
    }
}

@Observable
final class SettingsState {
    var soundEnabled: Bool = true
    var musicEnabled: Bool = true
    var hapticsEnabled: Bool = true
    var difficulty: DifficultyLevel = .normal
}

enum DifficultyLevel: String, CaseIterable, Identifiable {
    case easy, normal, hard

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .easy: "Easy"
        case .normal: "Normal"
        case .hard: "Hard"
        }
    }

    var aiAggression: Float {
        switch self {
        case .easy: 0.3
        case .normal: 0.6
        case .hard: 0.9
        }
    }

    var aiReactionTime: TimeInterval {
        switch self {
        case .easy: 1.5
        case .normal: 0.8
        case .hard: 0.3
        }
    }
}
