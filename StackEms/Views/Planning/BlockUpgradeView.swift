import SwiftUI

struct BlockUpgradeView: View {
    @Environment(\.appContainer) private var container
    @Environment(\.dismiss) private var dismiss
    let blockType: BlockType

    private var upgrades: BlockStats {
        container.appState.profileState.upgradeLevel(for: blockType)
    }

    private var resolved: ResolvedBlockStats {
        container.upgradeInteractor.resolvedStats(for: blockType)
    }

    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(StackEmsTheme.Colors.textSecondary)
                }
            }

            // Block info
            VStack(spacing: 8) {
                Image(blockType.textureName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                Text(blockType.displayName)
                    .font(StackEmsTheme.Fonts.heading)
                    .foregroundStyle(StackEmsTheme.Colors.textPrimary)

                Text(blockType.subtitle)
                    .font(StackEmsTheme.Fonts.caption)
                    .foregroundStyle(Color(blockType.color))
            }

            // Coins
            HStack(spacing: 4) {
                Image(systemName: "circle.fill")
                    .foregroundStyle(.yellow)
                    .font(.system(size: 10))
                Text("\(container.appState.profileState.coins)")
                    .font(StackEmsTheme.Fonts.body)
                    .foregroundStyle(StackEmsTheme.Colors.textPrimary)
            }

            // Stat rows
            VStack(spacing: 12) {
                ForEach(StatType.allCases, id: \.rawValue) { stat in
                    statRow(stat: stat)
                }
            }
            .padding()
            .background(StackEmsTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: StackEmsTheme.Layout.cornerRadius))

            // Resolved stats preview
            VStack(spacing: 8) {
                Text("Effective Stats")
                    .font(StackEmsTheme.Fonts.caption)
                    .foregroundStyle(StackEmsTheme.Colors.textSecondary)

                HStack(spacing: 16) {
                    resolvedItem(label: "Bounce", value: String(format: "%.2f", resolved.restitution))
                    resolvedItem(label: "Mass", value: String(format: "%.1f", resolved.effectiveMass))
                    resolvedItem(label: "Speed", value: String(format: "%.2f", resolved.speedFactor))
                }
            }
            .padding()
            .background(StackEmsTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: StackEmsTheme.Layout.cornerRadius))

            Spacer()
        }
        .padding()
        .background(StackEmsTheme.Colors.background.ignoresSafeArea())
    }

    private func statRow(stat: StatType) -> some View {
        let level = upgrades.level(for: stat)
        let cost = container.upgradeInteractor.upgradeCost(blockType: blockType, stat: stat)
        let canUpgrade = container.upgradeInteractor.canUpgrade(blockType: blockType, stat: stat)
        let baseLevel = blockType.baseStats.level(for: stat)

        return HStack(spacing: 10) {
            Image(systemName: stat.icon)
                .foregroundStyle(statColor(stat))
                .frame(width: 20)

            Text(stat.displayName)
                .font(StackEmsTheme.Fonts.body)
                .foregroundStyle(StackEmsTheme.Colors.textPrimary)
                .frame(width: 60, alignment: .leading)

            // Level pips — show effective level (base + upgrade bonus) out of 10
            let effectiveLevel = min(baseLevel + level - 1, BlockStats.maxLevel)
            HStack(spacing: 2) {
                ForEach(0..<BlockStats.maxLevel, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(i < effectiveLevel ? statColor(stat) : StackEmsTheme.Colors.surface.opacity(0.5))
                        .frame(width: 8, height: 14)
                }
            }

            Spacer()

            if let cost {
                Button {
                    _ = container.upgradeInteractor.performUpgrade(blockType: blockType, stat: stat)
                } label: {
                    Text("\(cost)c")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(canUpgrade ? .white : StackEmsTheme.Colors.textSecondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(canUpgrade ? statColor(stat) : StackEmsTheme.Colors.surface)
                        .clipShape(Capsule())
                }
                .disabled(!canUpgrade)
            } else {
                Text("MAX")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(statColor(stat))
            }
        }
    }

    private func resolvedItem(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(StackEmsTheme.Fonts.body)
                .foregroundStyle(StackEmsTheme.Colors.textPrimary)
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(StackEmsTheme.Colors.textSecondary)
        }
    }

    private func statColor(_ stat: StatType) -> Color {
        switch stat {
        case .power: .orange
        case .defense: .blue
        case .speed: .green
        }
    }
}
