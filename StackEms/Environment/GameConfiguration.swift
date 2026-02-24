import Foundation

struct GameConfiguration {
    enum Physics {
        static let gravity: Float = -9.81
        static let blockFriction: Float = 0.5
        static let blockRestitution: Float = 0.3
        static let groundFriction: Float = 0.9
        static let groundRestitution: Float = 0.1
        static let toppleAngleThreshold: Float = 45.0
        static let swipeForceMultiplier: Float = 12.0
        static let maxSwipeForce: Float = 50.0
        static let blockDetachDistance: Float = 2.0
        static let blockFallThreshold: Float = -0.5
        static let blockTiltThreshold: Float = 45.0
        static let minBlocksToSurvive: Int = 3
    }

    enum Arena {
        static let groundSize: Float = 20.0
        static let wallHeight: Float = 3.0
        static let wallThickness: Float = 0.2
        static let startDistance: Float = 8.0
        static let playerStartZ: Float = 8.0
        static let opponentStartZ: Float = -8.0
    }

    enum Stack {
        static let maxBlocks: Int = 5
        static let blockSpacing: Float = 0.02
        static let baseYOffset: Float = 0.2
    }

    enum Movement {
        static let forwardSpeed: Float = 4.0
        static let steerSpeed: Float = 3.0
        static let maxSteerAngle: Float = 45.0
    }

    enum AI {
        static let updateInterval: TimeInterval = 0.1
        static let swipeCooldown: TimeInterval = 2.0
        static let swipeRange: Float = 2.0
        static let avoidWallDistance: Float = 2.0
    }

    enum Camera {
        static let followDistance: Float = 3.0
        static let followHeight: Float = 8.0
        static let lookAheadDistance: Float = 4.0
        static let smoothingFactor: Float = 0.1
    }

    enum Match {
        static let countdownDuration: TimeInterval = 3.0
        static let maxMatchDuration: TimeInterval = 90.0
    }

    enum Progression {
        // XP rewards
        static let xpPerWin: Int = 100
        static let xpPerLoss: Int = 10
        static let xpPerBlockRemaining: Int = 10
        static let xpBonusFastWin: Int = 25
        static let xpBonusPerfectWin: Int = 50
        static let fastWinThreshold: TimeInterval = 30.0

        // Coin rewards
        static let coinsPerWin: Int = 50
        static let coinsPerLoss: Int = 0
        static let coinsPerBlockRemaining: Int = 5
        static let coinsBonusFastWin: Int = 15
        static let coinsBonusPerfectWin: Int = 30
        static let coinsStreakBonus: Int = 10

        // Leveling — quadratic curve
        static func xpRequiredForLevel(_ level: Int) -> Int {
            level * level * 100 + level * 100
        }

        static func levelForTotalXP(_ xp: Int) -> Int {
            var level = 1
            var accumulated = 0
            while true {
                let required = xpRequiredForLevel(level)
                if accumulated + required > xp { break }
                accumulated += required
                level += 1
            }
            return level
        }

        static func xpAccumulatedForLevel(_ level: Int) -> Int {
            var total = 0
            for l in 1..<level {
                total += xpRequiredForLevel(l)
            }
            return total
        }
    }
}
