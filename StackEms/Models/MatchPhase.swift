import Foundation

enum MatchPhase: Equatable {
    case menu
    case squad
    case planning
    case countdown
    case combat
    case result(MatchResult)
}
