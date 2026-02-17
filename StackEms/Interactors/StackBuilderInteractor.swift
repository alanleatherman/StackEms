import Foundation

@Observable
final class StackBuilderInteractor {
    private let matchState: MatchState

    init(matchState: MatchState) {
        self.matchState = matchState
    }

    func addBlock(_ type: BlockType) {
        guard matchState.playerBlueprint.blocks.count < StackBlueprint.maxBlocks else { return }
        matchState.playerBlueprint.blocks.append(type)
    }

    func removeBlock(at index: Int) {
        guard matchState.playerBlueprint.blocks.indices.contains(index) else { return }
        matchState.playerBlueprint.blocks.remove(at: index)
    }

    func replaceBlock(at index: Int, with type: BlockType) {
        guard matchState.playerBlueprint.blocks.indices.contains(index) else { return }
        matchState.playerBlueprint.blocks[index] = type
    }

    func resetToDefault() {
        matchState.playerBlueprint = .defaultBlueprint
    }

    func generateAIBlueprint(difficulty: DifficultyLevel) {
        var blocks: [BlockType] = []
        let count: Int

        switch difficulty {
        case .easy:
            count = 3
            blocks = [.tortodome, .cubeuin, .jellypop]
        case .normal:
            count = 4
            blocks = [.capyblocka, .tortodome, .jellypop, .cubeuin]
        case .hard:
            count = 5
            blocks = [.capyblocka, .tortodome, .triacera, .jellypop, .cubeuin]
        }

        // Add some randomness
        if Bool.random() && count >= 3 {
            let randomIndex = Int.random(in: 1..<count)
            blocks[randomIndex] = BlockType.allCases.randomElement()!
        }

        matchState.opponentBlueprint = StackBlueprint(blocks: blocks)
    }

    var isValidComposition: Bool {
        matchState.playerBlueprint.isValid
    }
}
