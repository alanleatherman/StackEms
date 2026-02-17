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
        static let blockDetachDistance: Float = 3.0
        static let blockFallThreshold: Float = -0.5
        static let blockTiltThreshold: Float = 60.0
        static let minBlocksToSurvive: Int = 2
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
}
