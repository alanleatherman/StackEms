import SwiftUI

struct BlockSelectorView: View {
    @Environment(\.appContainer) private var container

    private let gridColumns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(spacing: 16) {
            selectedBlocksSection
            blockTypeGrid
            compositionStats
        }
    }

    // MARK: - Selected Blocks

    private var selectedBlocksSection: some View {
        VStack(spacing: 8) {
            Text("Your Stack (\(container.appState.matchState.playerBlueprint.blocks.count)/\(StackBlueprint.maxBlocks))")
                .font(StackEmsTheme.Fonts.body)
                .foregroundStyle(StackEmsTheme.Colors.textSecondary)

            if container.appState.matchState.playerBlueprint.blocks.isEmpty {
                Text("Tap blocks below to add")
                    .font(StackEmsTheme.Fonts.caption)
                    .foregroundStyle(StackEmsTheme.Colors.textSecondary.opacity(0.6))
                    .frame(height: 36)
            } else {
                HStack(spacing: 6) {
                    ForEach(Array(container.appState.matchState.playerBlueprint.blocks.enumerated()), id: \.offset) { index, block in
                        blockChip(block: block, index: index)
                    }
                }
            }
        }
    }

    private func blockChip(block: BlockType, index: Int) -> some View {
        HStack(spacing: 3) {
            Text(block.shortName)
                .font(.system(size: 11))
                .lineLimit(1)

            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 12))
                .foregroundStyle(StackEmsTheme.Colors.textSecondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color(block.color).opacity(0.3))
        .foregroundStyle(StackEmsTheme.Colors.textPrimary)
        .clipShape(Capsule())
        .onTapGesture {
            container.stackBuilderInteractor.removeBlock(at: index)
        }
    }

    // MARK: - Block Type Grid

    private var blockTypeGrid: some View {
        LazyVGrid(columns: gridColumns, spacing: 8) {
            ForEach(BlockType.allCases) { blockType in
                blockButton(for: blockType)
            }
        }
        .padding(.horizontal)
    }

    private func blockButton(for blockType: BlockType) -> some View {
        Button {
            container.stackBuilderInteractor.addBlock(blockType)
        } label: {
            VStack(spacing: 4) {
                Image(blockType.textureName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                Text(blockType.displayName)
                    .font(.system(size: 11, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(StackEmsTheme.Colors.textPrimary)

                Text(blockType.subtitle)
                    .font(.system(size: 9))
                    .foregroundStyle(Color(blockType.color))

                HStack(spacing: 4) {
                    Text("M:\(String(format: "%.0f", blockType.mass))")
                    Text("HP:\(blockType.health)")
                }
                .font(.system(size: 9))
                .foregroundStyle(StackEmsTheme.Colors.textSecondary)
            }
            .padding(6)
            .background(StackEmsTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    // MARK: - Composition Stats

    private var compositionStats: some View {
        let bp = container.appState.matchState.playerBlueprint

        return VStack(spacing: 8) {
            HStack(spacing: 20) {
                statItem(label: "Mass", value: String(format: "%.1f", bp.totalMass))
                statItem(label: "HP", value: "\(bp.totalHealth)")
                statItem(label: "Blocks", value: "\(bp.blocks.count)")
                statItem(label: "Stability", value: stabilityRating(for: bp))
            }

            if !bp.blocks.isEmpty {
                HStack(spacing: 20) {
                    statItem(label: "Avg Mass", value: String(format: "%.1f", bp.totalMass / Float(bp.blocks.count)))
                    statItem(label: "Avg HP", value: "\(bp.totalHealth / bp.blocks.count)")
                }
            }

            HStack {
                Spacer()
                Button("Reset") {
                    container.stackBuilderInteractor.resetToDefault()
                }
                .font(StackEmsTheme.Fonts.caption)
                .foregroundStyle(StackEmsTheme.Colors.secondary)
            }
        }
        .padding(.horizontal)
    }

    private func statItem(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(StackEmsTheme.Fonts.body)
                .foregroundStyle(StackEmsTheme.Colors.textPrimary)
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(StackEmsTheme.Colors.textSecondary)
        }
    }

    private func stabilityRating(for blueprint: StackBlueprint) -> String {
        guard !blueprint.blocks.isEmpty else { return "-" }

        // Heavier blocks at the bottom = more stable
        var score: Float = 0
        let count = blueprint.blocks.count
        for (index, block) in blueprint.blocks.enumerated() {
            let positionWeight = Float(count - index) / Float(count)
            score += block.mass * positionWeight
        }

        let maxPossible = Float(count) * 4.0 // max mass is 4.0 (heavy)
        let ratio = score / maxPossible

        if ratio > 0.6 { return "High" }
        if ratio > 0.4 { return "Med" }
        return "Low"
    }
}
