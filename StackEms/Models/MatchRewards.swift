import Foundation

struct MatchRewards: Equatable {
    let coinsEarned: Int
    let xpEarned: Int
    let leveledUp: Bool
    let newLevel: Int
    let winStreak: Int

    let coinBreakdown: [RewardLine]
    let xpBreakdown: [RewardLine]

    struct RewardLine: Equatable, Identifiable {
        let id = UUID()
        let label: String
        let amount: Int

        static func == (lhs: RewardLine, rhs: RewardLine) -> Bool {
            lhs.label == rhs.label && lhs.amount == rhs.amount
        }
    }
}
