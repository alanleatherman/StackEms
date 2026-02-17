import RealityKit

struct TeamComponent: Component {
    enum Team: Int {
        case player = 1
        case opponent = 2
    }

    var team: Team

    var collisionGroup: CollisionGroup {
        switch team {
        case .player: CollisionGroup(rawValue: 1 << 0)
        case .opponent: CollisionGroup(rawValue: 1 << 1)
        }
    }
}
