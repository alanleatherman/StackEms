import SwiftUI

struct PlanningView: View {
    @Environment(\.appContainer) private var container

    var body: some View {
        ZStack {
            StackEmsTheme.Colors.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    Text("Build Your Stack")
                        .font(StackEmsTheme.Fonts.heading)
                        .foregroundStyle(StackEmsTheme.Colors.textPrimary)

                    StackPreviewView(blueprint: container.appState.matchState.playerBlueprint)
                        .frame(height: 140)

                    BlockSelectorView()

                    opponentHint

                    HStack(spacing: 16) {
                        Button("Back") {
                            container.matchInteractor.returnToMenu()
                        }
                        .buttonStyle(SecondaryButtonStyle())

                        Button("Ready!") {
                            container.stackBuilderInteractor.generateAIBlueprint(
                                difficulty: container.appState.settingsState.difficulty
                            )
                            container.matchInteractor.startMatch()
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(!container.stackBuilderInteractor.isValidComposition)
                    }

                    Spacer()
                }
                .padding()
            }
        }
    }

    private var opponentHint: some View {
        let difficulty = container.appState.settingsState.difficulty
        let hint: String = switch difficulty {
        case .easy:
            "Opponent: 3 blocks, lightweight build"
        case .normal:
            "Opponent: 4 blocks, balanced build"
        case .hard:
            "Opponent: 5 blocks, heavy fortified build"
        }

        return HStack(spacing: 8) {
            Image(systemName: "eye.fill")
                .foregroundStyle(StackEmsTheme.Colors.secondary)
            Text(hint)
                .font(StackEmsTheme.Fonts.caption)
                .foregroundStyle(StackEmsTheme.Colors.textSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(StackEmsTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
