import RealityKit
import Foundation

struct SwipeableComponent: Component {
    var cooldown: TimeInterval = 0.5
    var forceMultiplier: Float = 1.0
    var pendingImpulse: SIMD3<Float>? = nil
    var lastSwipeTime: TimeInterval = 0
}
