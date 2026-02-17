import RealityKit

struct StackControllerComponent: Component {
    var memberEntityNames: [String] = []
    var movementInput: SIMD2<Float> = .zero
    var hasToppled: Bool = false
    var attachedBlockCount: Int = 0
    var team: Team = .player

    enum Team: String {
        case player
        case opponent
    }
}
