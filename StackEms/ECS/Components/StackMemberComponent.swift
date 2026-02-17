import RealityKit

struct StackMemberComponent: Component {
    var stackID: String
    var index: Int
    var blockType: BlockType
    var isAttached: Bool = true
}
