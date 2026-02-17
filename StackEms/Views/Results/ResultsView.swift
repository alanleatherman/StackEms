import SwiftUI

struct ResultsView: View {
    @Environment(\.appContainer) private var container
    let result: MatchResult

    var body: some View {
        ZStack {
            StackEmsTheme.Colors.background
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                Text(result.playerWon ? "Victory!" : "Defeat")
                    .font(StackEmsTheme.Fonts.title)
                    .foregroundStyle(result.playerWon ? StackEmsTheme.Colors.accent : StackEmsTheme.Colors.secondary)

                VStack(spacing: 12) {
                    statRow(label: "Your Blocks", value: "\(result.playerBlocksRemaining)")
                    statRow(label: "Opponent Blocks", value: "\(result.opponentBlocksRemaining)")
                    statRow(label: "Duration", value: durationText)
                }
                .padding()
                .background(StackEmsTheme.Colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: StackEmsTheme.Layout.cornerRadius))

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

                Spacer()
            }
            .padding()
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
