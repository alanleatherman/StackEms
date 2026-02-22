import Foundation
import SwiftData

@Model
final class PersistedMatchResult {
    var matchID: UUID = UUID()
    var playerWon: Bool = false
    var playerBlocksRemaining: Int = 0
    var opponentBlocksRemaining: Int = 0
    var matchDuration: TimeInterval = 0
    var coinsEarned: Int = 0
    var xpEarned: Int = 0
    var date: Date = Date.now

    var profile: PlayerProfile?

    init(
        playerWon: Bool,
        playerBlocksRemaining: Int,
        opponentBlocksRemaining: Int,
        matchDuration: TimeInterval,
        coinsEarned: Int,
        xpEarned: Int
    ) {
        self.matchID = UUID()
        self.playerWon = playerWon
        self.playerBlocksRemaining = playerBlocksRemaining
        self.opponentBlocksRemaining = opponentBlocksRemaining
        self.matchDuration = matchDuration
        self.coinsEarned = coinsEarned
        self.xpEarned = xpEarned
        self.date = .now
    }
}
