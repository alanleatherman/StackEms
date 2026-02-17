import Foundation

struct StackBlueprint: Equatable {
    var blocks: [BlockType]

    static let maxBlocks = 5

    var isValid: Bool {
        !blocks.isEmpty && blocks.count <= Self.maxBlocks
    }

    var totalMass: Float {
        blocks.reduce(0) { $0 + $1.mass }
    }

    var totalHealth: Int {
        blocks.reduce(0) { $0 + $1.health }
    }

    static let defaultBlueprint = StackBlueprint(blocks: [
        .capyblocka, .tortodome, .jellypop, .cubeuin, .triacera
    ])

    static let empty = StackBlueprint(blocks: [])
}
