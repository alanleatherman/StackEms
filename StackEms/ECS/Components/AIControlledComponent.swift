import Foundation
import RealityKit

struct AIControlledComponent: Component {
    enum Behavior: String {
        case aggressive
        case defensive
        case balanced
    }

    var behavior: Behavior = .balanced
    var aggression: Float = 0.6
    var reactionTime: TimeInterval = 0.8
    var timeSinceLastDecision: TimeInterval = 0
    var timeSinceLastSwipe: TimeInterval = 0
    var targetEntity: Entity? = nil
}
