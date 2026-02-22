import Foundation
import SwiftData

final class PersistenceService {
    let modelContainer: ModelContainer
    private let modelContext: ModelContext
    private var profile: PlayerProfile?

    init() throws {
        let schema = Schema([PlayerProfile.self, PersistedMatchResult.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: false)
        self.modelContainer = try ModelContainer(for: schema, configurations: [config])
        self.modelContext = ModelContext(modelContainer)
    }

    func loadOrCreateProfile() -> PlayerProfile {
        if let existing = profile { return existing }

        let descriptor = FetchDescriptor<PlayerProfile>()
        let profiles = (try? modelContext.fetch(descriptor)) ?? []
        if let existing = profiles.first {
            self.profile = existing
            return existing
        }
        let newProfile = PlayerProfile()
        modelContext.insert(newProfile)
        try? modelContext.save()
        self.profile = newProfile
        return newProfile
    }

    func save() {
        try? modelContext.save()
    }

    func hydrateAppState(_ appState: AppState) {
        let profile = loadOrCreateProfile()

        // Profile state
        let ps = appState.profileState
        ps.playerName = profile.playerName
        ps.coins = profile.coins
        ps.xp = profile.xp
        ps.level = profile.level
        ps.wins = profile.wins
        ps.losses = profile.losses
        ps.currentWinStreak = profile.currentWinStreak
        ps.bestWinStreak = profile.bestWinStreak

        // Settings state
        let ss = appState.settingsState
        ss.soundEnabled = profile.soundEnabled
        ss.musicEnabled = profile.musicEnabled
        ss.hapticsEnabled = profile.hapticsEnabled
        ss.difficulty = profile.difficulty

        // Saved team
        let savedTeam = profile.savedTeam
        if !savedTeam.isEmpty {
            appState.matchState.playerBlueprint = StackBlueprint(blocks: savedTeam)
        }

        // Block upgrades
        for blockType in BlockType.allCases {
            ps.blockUpgrades[blockType] = profile.upgrades(for: blockType)
        }
    }

    func persistFromAppState(_ appState: AppState) {
        let profile = loadOrCreateProfile()

        // Profile state
        let ps = appState.profileState
        profile.playerName = ps.playerName
        profile.coins = ps.coins
        profile.xp = ps.xp
        profile.level = ps.level
        profile.wins = ps.wins
        profile.losses = ps.losses
        profile.currentWinStreak = ps.currentWinStreak
        profile.bestWinStreak = ps.bestWinStreak

        // Settings state
        let ss = appState.settingsState
        profile.soundEnabled = ss.soundEnabled
        profile.musicEnabled = ss.musicEnabled
        profile.hapticsEnabled = ss.hapticsEnabled
        profile.difficulty = ss.difficulty

        // Saved team
        profile.savedTeam = appState.matchState.playerBlueprint.blocks

        // Block upgrades
        var upgradeDict: [String: BlockStats] = [:]
        for (blockType, stats) in ps.blockUpgrades {
            upgradeDict[blockType.rawValue] = stats
        }
        profile.blockUpgrades = upgradeDict

        save()
    }

    func persistMatchResult(from result: MatchResult) {
        let profile = loadOrCreateProfile()
        let persisted = PersistedMatchResult(
            playerWon: result.playerWon,
            playerBlocksRemaining: result.playerBlocksRemaining,
            opponentBlocksRemaining: result.opponentBlocksRemaining,
            matchDuration: result.matchDuration,
            coinsEarned: result.coinsEarned,
            xpEarned: result.xpEarned
        )
        persisted.profile = profile
        profile.matchHistory.append(persisted)
        save()
    }
}
