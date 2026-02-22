import SwiftUI

struct CombatHUDView: View {
    @Environment(\.appContainer) private var container

    var body: some View {
        ZStack {
            // Timer — absolutely centered
            Text(timerText)
                .font(StackEmsTheme.Fonts.heading)
                .foregroundStyle(.white)
                .shadow(color: .black, radius: 3)
                .monospacedDigit()

            // Side panels + menu button
            HStack {
                Button {
                    container.matchInteractor.returnToMenu()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.white)
                        .shadow(color: .black, radius: 3)
                }
                .padding(.trailing, 8)

                VStack(alignment: .leading, spacing: 4) {
                    Text("You")
                        .font(StackEmsTheme.Fonts.caption)
                        .foregroundStyle(.cyan)
                    Text("\(container.appState.matchState.playerBlocksRemaining) blocks")
                        .font(StackEmsTheme.Fonts.body)
                        .foregroundStyle(.white)
                        .shadow(color: .black, radius: 2)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Opponent")
                        .font(StackEmsTheme.Fonts.caption)
                        .foregroundStyle(.orange)
                    Text("\(container.appState.matchState.opponentBlocksRemaining) blocks")
                        .font(StackEmsTheme.Fonts.body)
                        .foregroundStyle(.white)
                        .shadow(color: .black, radius: 2)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .padding(.top, 44)
        .background(
            LinearGradient(
                colors: [.black.opacity(0.85), .black.opacity(0.4), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private var timerText: String {
        let remaining = max(0, GameConfiguration.Match.maxMatchDuration - container.appState.matchState.matchTimer)
        let minutes = Int(remaining) / 60
        let seconds = Int(remaining) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
