import Foundation

enum MatchPhase: Equatable {
    case menu
    case planning
    case countdown
    case combat
    case result(MatchResult)
}
