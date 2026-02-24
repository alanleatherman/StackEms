import SwiftUI

struct SquadView: View {
    @Environment(\.appContainer) private var container
    @State private var selectedBlockForUpgrade: BlockType?

    private var blueprint: StackBlueprint {
        container.appState.matchState.playerBlueprint
    }

    private var profile: ProfileState {
        container.appState.profileState
    }

    var body: some View {
        ZStack {
            StackEmsTheme.Colors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        container.matchInteractor.returnToMenu()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(StackEmsTheme.Fonts.body)
                        .foregroundStyle(StackEmsTheme.Colors.textSecondary)
                    }

                    Spacer()

                    // Coins display
                    HStack(spacing: 4) {
                        Image(systemName: "circle.fill")
                            .foregroundStyle(.yellow)
                            .font(.system(size: 10))
                        Text("\(profile.coins)")
                            .font(StackEmsTheme.Fonts.heading)
                            .foregroundStyle(StackEmsTheme.Colors.textPrimary)
                    }
                }
                .padding()

                ScrollView {
                    VStack(spacing: 24) {
                        Text("Your Squad")
                            .font(StackEmsTheme.Fonts.heading)
                            .foregroundStyle(StackEmsTheme.Colors.textPrimary)

                        // Current squad lineup
                        squadLineup

                        // Squad stats overview
                        squadStatsCard

                        // All blocks grid — tap to upgrade
                        allBlocksSection

                        // Actions
                        VStack(spacing: 12) {
                            Button("Reset to Default") {
                                container.stackBuilderInteractor.resetToDefault()
                            }
                            .buttonStyle(SecondaryButtonStyle())
                        }
                        .padding(.top, 8)

                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal)
                }
            }
        }
        .sheet(item: $selectedBlockForUpgrade) { blockType in
            BlockUpgradeView(blockType: blockType)
                .appEnvironment(container)
        }
    }

    // MARK: - Squad Lineup

    private var squadLineup: some View {
        VStack(spacing: 12) {
            if blueprint.blocks.isEmpty {
                Text("No blocks selected")
                    .font(StackEmsTheme.Fonts.body)
                    .foregroundStyle(StackEmsTheme.Colors.textSecondary)
                    .frame(height: 80)
            } else {
                HStack(spacing: 12) {
                    ForEach(Array(blueprint.blocks.enumerated()), id: \.offset) { index, block in
                        squadMemberCard(block: block, index: index)
                    }
                }
            }

            Text("Tap a block above to remove, or tap any block below to upgrade")
                .font(.system(size: 10))
                .foregroundStyle(StackEmsTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(StackEmsTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: StackEmsTheme.Layout.cornerRadius))
    }

    private func squadMemberCard(block: BlockType, index: Int) -> some View {
        VStack(spacing: 4) {
            Image(block.textureName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 6))

            Text(block.shortName)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(StackEmsTheme.Colors.textPrimary)

            // Position indicator
            Text("#\(index + 1)")
                .font(.system(size: 9))
                .foregroundStyle(StackEmsTheme.Colors.textSecondary)
        }
        .padding(6)
        .background(Color(block.color).opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .onTapGesture {
            container.stackBuilderInteractor.removeBlock(at: index)
        }
    }

    // MARK: - Squad Stats

    private var squadStatsCard: some View {
        let blocks = blueprint.blocks
        guard !blocks.isEmpty else {
            return AnyView(EmptyView())
        }

        let avgPower = blocks.map { Float($0.baseStats.power + profile.upgradeLevel(for: $0).power - 1) }
            .reduce(0, +) / Float(blocks.count)
        let avgDefense = blocks.map { Float($0.baseStats.defense + profile.upgradeLevel(for: $0).defense - 1) }
            .reduce(0, +) / Float(blocks.count)
        let avgSpeedFactor = blocks.map {
            BlockStatsConfig.resolve(blockType: $0, upgrades: profile.upgradeLevel(for: $0)).speedFactor
        }.reduce(0, +) / Float(blocks.count)
        let totalMass = blocks.map {
            BlockStatsConfig.resolve(blockType: $0, upgrades: profile.upgradeLevel(for: $0)).effectiveMass
        }.reduce(0, +)
        let computedSpeed = GameConfiguration.Movement.forwardSpeed * avgSpeedFactor

        return AnyView(
            VStack(spacing: 12) {
                Text("Squad Stats")
                    .font(StackEmsTheme.Fonts.body)
                    .foregroundStyle(StackEmsTheme.Colors.textSecondary)

                HStack(spacing: 20) {
                    squadStat(icon: "bolt.fill", label: "Power", value: String(format: "%.1f", avgPower), color: .orange)
                    squadStat(icon: "shield.fill", label: "Defense", value: String(format: "%.1f", avgDefense), color: .blue)
                    squadStat(icon: "hare.fill", label: "Speed", value: String(format: "%.1f", computedSpeed), color: .green)
                    squadStat(icon: "scalemass.fill", label: "Mass", value: String(format: "%.1f", totalMass), color: .gray)
                }
            }
            .padding()
            .background(StackEmsTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: StackEmsTheme.Layout.cornerRadius))
        )
    }

    private func squadStat(icon: String, label: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.system(size: 16))
            Text(value)
                .font(StackEmsTheme.Fonts.body)
                .foregroundStyle(StackEmsTheme.Colors.textPrimary)
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(StackEmsTheme.Colors.textSecondary)
        }
    }

    // MARK: - All Blocks Grid

    private var allBlocksSection: some View {
        VStack(spacing: 12) {
            Text("All Blocks")
                .font(StackEmsTheme.Fonts.body)
                .foregroundStyle(StackEmsTheme.Colors.textSecondary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(BlockType.allCases) { blockType in
                    blockDetailCard(for: blockType)
                }
            }
        }
    }

    private func blockDetailCard(for blockType: BlockType) -> some View {
        let upgrades = profile.upgradeLevel(for: blockType)
        let base = blockType.baseStats
        let resolved = BlockStatsConfig.resolve(blockType: blockType, upgrades: upgrades)
        let inSquad = blueprint.blocks.contains(blockType)

        return VStack(spacing: 6) {
            HStack {
                Image(blockType.textureName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                VStack(alignment: .leading, spacing: 2) {
                    Text(blockType.displayName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(StackEmsTheme.Colors.textPrimary)
                        .lineLimit(1)

                    Text(blockType.subtitle)
                        .font(.system(size: 10))
                        .foregroundStyle(Color(blockType.color))
                }

                Spacer()
            }

            // Stat bars
            HStack(spacing: 8) {
                miniStatBar(icon: "bolt.fill", value: base.power + upgrades.power - 1, color: .orange)
                miniStatBar(icon: "shield.fill", value: base.defense + upgrades.defense - 1, color: .blue)
                miniStatBar(icon: "hare.fill", value: base.speed + upgrades.speed - 1, color: .green)
            }

            // Resolved physics values
            HStack(spacing: 12) {
                Text("Bounce: \(String(format: "%.2f", resolved.restitution))")
                Text("Mass: \(String(format: "%.1f", resolved.effectiveMass))")
                Text("Spd: \(String(format: "%.2f", resolved.speedFactor))")
            }
            .font(.system(size: 8))
            .foregroundStyle(StackEmsTheme.Colors.textSecondary)

            // Actions
            HStack(spacing: 8) {
                Button {
                    selectedBlockForUpgrade = blockType
                } label: {
                    Text("Upgrade")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(StackEmsTheme.Colors.accent)
                        .clipShape(Capsule())
                }

                Button {
                    container.stackBuilderInteractor.addBlock(blockType)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(inSquad ? StackEmsTheme.Colors.textSecondary : StackEmsTheme.Colors.accent)
                }
            }
        }
        .padding(10)
        .background(StackEmsTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(inSquad ? Color(blockType.color).opacity(0.5) : .clear, lineWidth: 2)
        )
    }

    private func miniStatBar(icon: String, value: Int, color: Color) -> some View {
        HStack(spacing: 2) {
            Image(systemName: icon)
                .font(.system(size: 8))
                .foregroundStyle(color)
            // Mini bar
            HStack(spacing: 1) {
                ForEach(0..<10, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(i < value ? color : color.opacity(0.15))
                        .frame(width: 4, height: 8)
                }
            }
        }
    }
}
