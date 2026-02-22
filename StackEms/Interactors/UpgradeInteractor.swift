import Foundation

@Observable
final class UpgradeInteractor {
    private let profileState: ProfileState
    var onUpgradeChanged: (() -> Void)?

    init(profileState: ProfileState) {
        self.profileState = profileState
    }

    func canUpgrade(blockType: BlockType, stat: StatType) -> Bool {
        let current = profileState.upgradeLevel(for: blockType)
        let level = current.level(for: stat)
        guard level < BlockStats.maxLevel else { return false }
        let cost = BlockStatsConfig.upgradeCost(currentLevel: level)
        return profileState.coins >= cost
    }

    func upgradeCost(blockType: BlockType, stat: StatType) -> Int? {
        let current = profileState.upgradeLevel(for: blockType)
        let level = current.level(for: stat)
        guard level < BlockStats.maxLevel else { return nil }
        return BlockStatsConfig.upgradeCost(currentLevel: level)
    }

    func performUpgrade(blockType: BlockType, stat: StatType) -> Bool {
        guard canUpgrade(blockType: blockType, stat: stat) else { return false }
        var current = profileState.upgradeLevel(for: blockType)
        let level = current.level(for: stat)
        let cost = BlockStatsConfig.upgradeCost(currentLevel: level)

        profileState.coins -= cost
        current.increment(stat)
        profileState.setUpgradeLevel(for: blockType, stats: current)
        onUpgradeChanged?()
        return true
    }

    func resolvedStats(for blockType: BlockType) -> ResolvedBlockStats {
        let upgrades = profileState.upgradeLevel(for: blockType)
        return BlockStatsConfig.resolve(blockType: blockType, upgrades: upgrades)
    }
}
