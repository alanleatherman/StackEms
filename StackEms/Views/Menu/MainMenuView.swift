import SwiftUI

struct MainMenuView: View {
    @Environment(\.appContainer) private var container

    private var profile: ProfileState {
        container.appState.profileState
    }

    var body: some View {
        ZStack {
            StackEmsTheme.Colors.background
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // Title
                VStack(spacing: 8) {
                    Text("STACK")
                        .font(StackEmsTheme.Fonts.title)
                        .foregroundStyle(StackEmsTheme.Colors.primary)
                    Text("EMS")
                        .font(StackEmsTheme.Fonts.title)
                        .foregroundStyle(StackEmsTheme.Colors.secondary)
                }

                // Buttons
                VStack(spacing: 16) {
                    Button("Play") {
                        container.matchInteractor.goToPlanning()
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    Button("Quick Match") {
                        container.matchInteractor.startMatch()
                    }
                    .buttonStyle(SecondaryButtonStyle())

                    Button("Default Squad") {
                        container.stackBuilderInteractor.resetToDefault()
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }

                Spacer()

                // Player info footer
                VStack(spacing: 12) {
                    // Level with XP bar + coins
                    HStack(spacing: 20) {
                        VStack(spacing: 4) {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundStyle(.cyan)
                                Text("Lv. \(profile.level)")
                                    .font(StackEmsTheme.Fonts.body)
                                    .foregroundStyle(StackEmsTheme.Colors.textPrimary)
                            }

                            // Mini XP bar
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(StackEmsTheme.Colors.surface)
                                        .frame(height: 4)
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(.cyan)
                                        .frame(width: geo.size.width * max(0, min(1, profile.levelProgress)), height: 4)
                                }
                            }
                            .frame(width: 60, height: 4)
                        }

                        HStack(spacing: 4) {
                            Image(systemName: "circle.fill")
                                .foregroundStyle(.yellow)
                                .font(.system(size: 10))
                            Text("\(profile.coins)")
                                .font(StackEmsTheme.Fonts.body)
                                .foregroundStyle(StackEmsTheme.Colors.textPrimary)
                        }
                    }

                    // Stats row
                    if profile.totalMatches > 0 {
                        HStack(spacing: 16) {
                            footerStat(label: "Record", value: "\(profile.wins)W-\(profile.losses)L")
                            footerStat(label: "Win Rate", value: "\(Int(profile.winRate * 100))%")
                            if profile.bestWinStreak > 0 {
                                footerStat(label: "Best Streak", value: "\(profile.bestWinStreak)")
                            }
                        }
                    }

                    // Current squad chips
                    let blocks = container.appState.matchState.playerBlueprint.blocks
                    if !blocks.isEmpty {
                        HStack(spacing: 4) {
                            Text("Squad:")
                                .font(StackEmsTheme.Fonts.caption)
                                .foregroundStyle(StackEmsTheme.Colors.textSecondary)
                            ForEach(Array(blocks.enumerated()), id: \.offset) { _, block in
                                Text(block.shortName)
                                    .font(.system(size: 10))
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(Color(block.color).opacity(0.3))
                                    .clipShape(Capsule())
                                    .foregroundStyle(StackEmsTheme.Colors.textPrimary)
                            }
                        }
                    }
                }
                .padding(.bottom, 32)
            }
            .padding()
        }
    }

    private func footerStat(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(StackEmsTheme.Fonts.body)
                .foregroundStyle(StackEmsTheme.Colors.textPrimary)
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(StackEmsTheme.Colors.textSecondary)
        }
    }
}
