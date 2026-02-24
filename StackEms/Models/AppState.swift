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
    var matchID: UUID = UUID()
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
    var coins: Int = 0
    var xp: Int = 0
    var level: Int = 1
    var wins: Int = 0
    var losses: Int = 0
    var currentWinStreak: Int = 0
    var bestWinStreak: Int = 0
    var matchHistory: [MatchResult] = []
    var lastMatchRewards: MatchRewards? = nil
    var blockUpgrades: [BlockType: BlockStats] = [:]

    func upgradeLevel(for blockType: BlockType) -> BlockStats {
        blockUpgrades[blockType] ?? BlockStats(power: 1, defense: 1, speed: 1)
    }

    func setUpgradeLevel(for blockType: BlockType, stats: BlockStats) {
        blockUpgrades[blockType] = stats
    }

    var totalMatches: Int { wins + losses }

    var winRate: Double {
        guard totalMatches > 0 else { return 0 }
        return Double(wins) / Double(totalMatches)
    }

    var xpForCurrentLevel: Int {
        GameConfiguration.Progression.xpRequiredForLevel(level)
    }

    var xpIntoCurrentLevel: Int {
        xp - GameConfiguration.Progression.xpAccumulatedForLevel(level)
    }

    var levelProgress: Double {
        guard xpForCurrentLevel > 0 else { return 0 }
        return Double(xpIntoCurrentLevel) / Double(xpForCurrentLevel)
    }

    func recordResult(_ result: MatchResult, rewards: MatchRewards) {
        if result.playerWon {
            wins += 1
            currentWinStreak += 1
            bestWinStreak = max(bestWinStreak, currentWinStreak)
        } else {
            losses += 1
            currentWinStreak = 0
        }
        coins += rewards.coinsEarned
        xp += rewards.xpEarned
        level = rewards.newLevel
        lastMatchRewards = rewards
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
