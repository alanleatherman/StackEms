import Foundation

struct BlockStats: Equatable, Codable, Sendable {
    var power: Int
    var defense: Int
    var speed: Int

    static let maxLevel = 10

    func level(for stat: StatType) -> Int {
        switch stat {
        case .power: power
        case .defense: defense
        case .speed: speed
        }
    }

    mutating func increment(_ stat: StatType) {
        switch stat {
        case .power: power = min(power + 1, Self.maxLevel)
        case .defense: defense = min(defense + 1, Self.maxLevel)
        case .speed: speed = min(speed + 1, Self.maxLevel)
        }
    }
}

enum StatType: String, CaseIterable, Sendable {
    case power, defense, speed

    var displayName: String { rawValue.capitalized }

    var icon: String {
        switch self {
        case .power: "bolt.fill"
        case .defense: "shield.fill"
        case .speed: "hare.fill"
        }
    }

    var color: String {
        switch self {
        case .power: "orange"
        case .defense: "blue"
        case .speed: "green"
        }
    }
}

struct ResolvedBlockStats: Sendable {
    let restitution: Float
    let massMultiplier: Float
    let speedFactor: Float
    let effectiveMass: Float
}

enum BlockStatsConfig {
    static func baseStats(for type: BlockType) -> BlockStats {
        switch type {
        case .capyblocka: BlockStats(power: 2, defense: 5, speed: 1)
        case .tortodome:  BlockStats(power: 2, defense: 4, speed: 2)
        case .jellypop:   BlockStats(power: 5, defense: 1, speed: 4)
        case .cubeuin:    BlockStats(power: 3, defense: 1, speed: 5)
        case .triacera:   BlockStats(power: 4, defense: 3, speed: 3)
        }
    }

    static func upgradeCost(currentLevel: Int) -> Int {
        let base = 50
        let scaling = 25 * (currentLevel - 1) + (currentLevel > 3 ? 25 * (currentLevel - 3) : 0)
        return base + scaling
    }

    static func resolve(blockType: BlockType, upgrades: BlockStats) -> ResolvedBlockStats {
        let base = baseStats(for: blockType)
        let effectivePower = base.power + (upgrades.power - 1)
        let effectiveDefense = base.defense + (upgrades.defense - 1)
        let effectiveSpeed = base.speed + (upgrades.speed - 1)

        // Power → restitution: map 1–15 to 0.2–0.7
        let restitution = Float(0.2) + Float(min(effectivePower, 15) - 1) / 14.0 * 0.5

        // Defense → mass multiplier: map 1–15 to 0.9–1.6
        let massMultiplier = Float(0.9) + Float(min(effectiveDefense, 15) - 1) / 14.0 * 0.7

        // Speed → speed factor: map 1–15 to 0.8–1.4
        let speedFactor = Float(0.8) + Float(min(effectiveSpeed, 15) - 1) / 14.0 * 0.6

        let effectiveMass = blockType.mass * massMultiplier

        return ResolvedBlockStats(
            restitution: restitution,
            massMultiplier: massMultiplier,
            speedFactor: speedFactor,
            effectiveMass: effectiveMass
        )
    }
}
