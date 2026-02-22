import Foundation

struct MatchResult: Equatable, Identifiable, Codable {
    let id: UUID
    let playerWon: Bool
    let playerBlocksRemaining: Int
    let opponentBlocksRemaining: Int
    let matchDuration: TimeInterval
    let coinsEarned: Int
    let xpEarned: Int
    let date: Date

    init(
        id: UUID = UUID(),
        playerWon: Bool,
        playerBlocksRemaining: Int,
        opponentBlocksRemaining: Int,
        matchDuration: TimeInterval,
        coinsEarned: Int = 0,
        xpEarned: Int = 0,
        date: Date = .now
    ) {
        self.id = id
        self.playerWon = playerWon
        self.playerBlocksRemaining = playerBlocksRemaining
        self.opponentBlocksRemaining = opponentBlocksRemaining
        self.matchDuration = matchDuration
        self.coinsEarned = coinsEarned
        self.xpEarned = xpEarned
        self.date = date
    }
}
