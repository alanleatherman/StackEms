import Foundation
import SwiftData

@Model
final class PlayerProfile {
    var playerName: String = "Player"
    var coins: Int = 0
    var xp: Int = 0
    var level: Int = 1
    var wins: Int = 0
    var losses: Int = 0
    var currentWinStreak: Int = 0
    var bestWinStreak: Int = 0

    // Saved team as raw values (BlockType is Codable)
    var savedTeamRawValues: [String] = ["capyblocka", "tortodome", "jellypop", "cubeuin", "triacera"]

    // Settings
    var soundEnabled: Bool = true
    var musicEnabled: Bool = true
    var hapticsEnabled: Bool = true
    var difficultyRawValue: String = "normal"

    var blockUpgradesJSON: String = "{}"

    @Relationship(deleteRule: .cascade)
    var matchHistory: [PersistedMatchResult] = []

    init() {}

    var blockUpgrades: [String: BlockStats] {
        get {
            guard let data = blockUpgradesJSON.data(using: .utf8),
                  let dict = try? JSONDecoder().decode([String: BlockStats].self, from: data)
            else { return [:] }
            return dict
        }
        set {
            if let data = try? JSONEncoder().encode(newValue),
               let str = String(data: data, encoding: .utf8) {
                blockUpgradesJSON = str
            }
        }
    }

    func upgrades(for blockType: BlockType) -> BlockStats {
        blockUpgrades[blockType.rawValue] ?? BlockStats(power: 1, defense: 1, speed: 1)
    }

    var savedTeam: [BlockType] {
        get { savedTeamRawValues.compactMap { BlockType(rawValue: $0) } }
        set { savedTeamRawValues = newValue.map(\.rawValue) }
    }

    var difficulty: DifficultyLevel {
        get { DifficultyLevel(rawValue: difficultyRawValue) ?? .normal }
        set { difficultyRawValue = newValue.rawValue }
    }
}
