import SwiftUI

struct ResultsView: View {
    @Environment(\.appContainer) private var container
    let result: MatchResult

    private var rewards: MatchRewards? {
        container.appState.profileState.lastMatchRewards
    }

    var body: some View {
        ZStack {
            StackEmsTheme.Colors.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    Spacer().frame(height: 20)

                    // Victory / Defeat header
                    Text(result.playerWon ? "Victory!" : "Defeat")
                        .font(StackEmsTheme.Fonts.title)
                        .foregroundStyle(result.playerWon ? StackEmsTheme.Colors.accent : StackEmsTheme.Colors.secondary)

                    // Match stats
                    VStack(spacing: 12) {
                        statRow(label: "Your Blocks", value: "\(result.playerBlocksRemaining)")
                        statRow(label: "Opponent Blocks", value: "\(result.opponentBlocksRemaining)")
                        statRow(label: "Duration", value: durationText)
                    }
                    .padding()
                    .background(StackEmsTheme.Colors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: StackEmsTheme.Layout.cornerRadius))

                    // Rewards section
                    if let rewards {
                        VStack(spacing: 16) {
                            // Coins breakdown
                            rewardSection(title: "Coins Earned", total: rewards.coinsEarned, lines: rewards.coinBreakdown, color: .yellow)

                            // XP breakdown
                            rewardSection(title: "XP Earned", total: rewards.xpEarned, lines: rewards.xpBreakdown, color: .cyan)

                            // Win streak
                            if rewards.winStreak > 1 {
                                HStack {
                                    Image(systemName: "flame.fill")
                                        .foregroundStyle(.orange)
                                    Text("\(rewards.winStreak) Win Streak!")
                                        .font(StackEmsTheme.Fonts.heading)
                                        .foregroundStyle(.orange)
                                }
                            }

                            // Level progress
                            levelProgressView

                            // Level up callout
                            if rewards.leveledUp {
                                Text("Level Up!")
                                    .font(StackEmsTheme.Fonts.heading)
                                    .foregroundStyle(StackEmsTheme.Colors.accent)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 24)
                                    .background(StackEmsTheme.Colors.accent.opacity(0.2))
                                    .clipShape(Capsule())
                            }
                        }
                        .padding()
                        .background(StackEmsTheme.Colors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: StackEmsTheme.Layout.cornerRadius))
                    }

                    // Buttons
                    VStack(spacing: 16) {
                        Button("Play Again") {
                            container.matchInteractor.goToPlanning()
                        }
                        .buttonStyle(PrimaryButtonStyle())

                        Button("Main Menu") {
                            container.matchInteractor.returnToMenu()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }

                    Spacer().frame(height: 20)
                }
                .padding()
            }
        }
    }

    private func rewardSection(title: String, total: Int, lines: [MatchRewards.RewardLine], color: Color) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text(title)
                    .font(StackEmsTheme.Fonts.heading)
                    .foregroundStyle(color)
                Spacer()
                Text("+\(total)")
                    .font(StackEmsTheme.Fonts.heading)
                    .foregroundStyle(color)
            }

            ForEach(lines) { line in
                HStack {
                    Text(line.label)
                        .font(StackEmsTheme.Fonts.caption)
                        .foregroundStyle(StackEmsTheme.Colors.textSecondary)
                    Spacer()
                    Text("+\(line.amount)")
                        .font(StackEmsTheme.Fonts.caption)
                        .foregroundStyle(StackEmsTheme.Colors.textSecondary)
                }
            }
        }
    }

    private var levelProgressView: some View {
        let profile = container.appState.profileState
        return VStack(spacing: 6) {
            HStack {
                Text("Level \(profile.level)")
                    .font(StackEmsTheme.Fonts.body)
                    .foregroundStyle(StackEmsTheme.Colors.textPrimary)
                Spacer()
                Text("\(profile.xpIntoCurrentLevel) / \(profile.xpForCurrentLevel) XP")
                    .font(StackEmsTheme.Fonts.caption)
                    .foregroundStyle(StackEmsTheme.Colors.textSecondary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(StackEmsTheme.Colors.surface.opacity(0.5))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(LinearGradient(colors: [.cyan, .blue], startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * max(0, min(1, profile.levelProgress)), height: 8)
                }
            }
            .frame(height: 8)
        }
    }

    private func statRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(StackEmsTheme.Fonts.body)
                .foregroundStyle(StackEmsTheme.Colors.textSecondary)
            Spacer()
            Text(value)
                .font(StackEmsTheme.Fonts.body)
                .foregroundStyle(StackEmsTheme.Colors.textPrimary)
        }
    }

    private var durationText: String {
        let minutes = Int(result.matchDuration) / 60
        let seconds = Int(result.matchDuration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
