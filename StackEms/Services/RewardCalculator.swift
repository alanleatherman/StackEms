import Foundation

struct RewardCalculator {
    static func calculate(
        playerWon: Bool,
        playerBlocksRemaining: Int,
        totalPlayerBlocks: Int,
        matchDuration: TimeInterval,
        currentWinStreak: Int,
        currentXP: Int,
        currentLevel: Int
    ) -> MatchRewards {
        let config = GameConfiguration.Progression.self
        var coinLines: [MatchRewards.RewardLine] = []
        var xpLines: [MatchRewards.RewardLine] = []

        // Base reward
        if playerWon {
            coinLines.append(.init(label: "Victory", amount: config.coinsPerWin))
            xpLines.append(.init(label: "Victory", amount: config.xpPerWin))
        } else {
            coinLines.append(.init(label: "Participation", amount: config.coinsPerLoss))
            xpLines.append(.init(label: "Participation", amount: config.xpPerLoss))
        }

        // Bonuses only for wins
        if playerWon {
            // Blocks remaining bonus
            if playerBlocksRemaining > 0 {
                let coinBonus = playerBlocksRemaining * config.coinsPerBlockRemaining
                let xpBonus = playerBlocksRemaining * config.xpPerBlockRemaining
                coinLines.append(.init(label: "\(playerBlocksRemaining) blocks left", amount: coinBonus))
                xpLines.append(.init(label: "\(playerBlocksRemaining) blocks left", amount: xpBonus))
            }

            // Perfect win (all blocks remaining)
            if playerBlocksRemaining == totalPlayerBlocks {
                coinLines.append(.init(label: "Perfect!", amount: config.coinsBonusPerfectWin))
                xpLines.append(.init(label: "Perfect!", amount: config.xpBonusPerfectWin))
            }

            // Fast win
            if matchDuration < config.fastWinThreshold {
                coinLines.append(.init(label: "Speed bonus", amount: config.coinsBonusFastWin))
                xpLines.append(.init(label: "Speed bonus", amount: config.xpBonusFastWin))
            }
        }

        // Win streak
        let newStreak = playerWon ? currentWinStreak + 1 : 0
        if playerWon && newStreak >= 2 {
            let streakCoins = config.coinsStreakBonus * newStreak
            coinLines.append(.init(label: "\(newStreak)x streak", amount: streakCoins))
        }

        let totalCoins = coinLines.reduce(0) { $0 + $1.amount }
        let totalXP = xpLines.reduce(0) { $0 + $1.amount }

        let newTotalXP = currentXP + totalXP
        let newLevel = GameConfiguration.Progression.levelForTotalXP(newTotalXP)

        return MatchRewards(
            coinsEarned: totalCoins,
            xpEarned: totalXP,
            leveledUp: newLevel > currentLevel,
            newLevel: newLevel,
            winStreak: newStreak,
            coinBreakdown: coinLines,
            xpBreakdown: xpLines
        )
    }
}
