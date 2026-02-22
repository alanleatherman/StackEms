import Foundation
import RealityKit

struct AIControlledComponent: Component {
    enum Behavior: String {
        case aggressive
        case defensive
        case balanced
    }

    enum Phase: Int {
        case chase = 0
        case circle = 1
        case charge = 2
        case retreat = 3
    }

    var behavior: Behavior = .balanced
    var aggression: Float = 0.6
    var reactionTime: TimeInterval = 0.8
    var timeSinceLastDecision: TimeInterval = 0
    var timeSinceLastSwipe: TimeInterval = 0

    // State machine
    var phase: Phase = .chase
    var phaseTimer: TimeInterval = 0
    var circleDirection: Float = 1  // 1 = clockwise, -1 = counter-clockwise
    var chargesBeforeRetreat: Int = 0
}
