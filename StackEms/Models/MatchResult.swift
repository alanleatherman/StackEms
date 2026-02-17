import Foundation

struct MatchResult: Equatable, Identifiable {
    let id: UUID
    let playerWon: Bool
    let playerBlocksRemaining: Int
    let opponentBlocksRemaining: Int
    let matchDuration: TimeInterval
    let date: Date

    init(
        id: UUID = UUID(),
        playerWon: Bool,
        playerBlocksRemaining: Int,
        opponentBlocksRemaining: Int,
        matchDuration: TimeInterval,
        date: Date = .now
    ) {
        self.id = id
        self.playerWon = playerWon
        self.playerBlocksRemaining = playerBlocksRemaining
        self.opponentBlocksRemaining = opponentBlocksRemaining
        self.matchDuration = matchDuration
        self.date = date
    }
}
