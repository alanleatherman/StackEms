import SwiftUI

struct MainMenuView: View {
    @Environment(\.appContainer) private var container

    var body: some View {
        ZStack {
            StackEmsTheme.Colors.background
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                VStack(spacing: 8) {
                    Text("STACK")
                        .font(StackEmsTheme.Fonts.title)
                        .foregroundStyle(StackEmsTheme.Colors.primary)
                    Text("EMS")
                        .font(StackEmsTheme.Fonts.title)
                        .foregroundStyle(StackEmsTheme.Colors.secondary)
                }

                VStack(spacing: 16) {
                    Button("Play") {
                        container.matchInteractor.goToPlanning()
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    Button("Quick Match") {
                        container.matchInteractor.startMatch()
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }

                Spacer()

                if container.appState.profileState.totalMatches > 0 {
                    VStack(spacing: 4) {
                        Text("Record: \(container.appState.profileState.wins)W - \(container.appState.profileState.losses)L")
                            .font(StackEmsTheme.Fonts.body)
                            .foregroundStyle(StackEmsTheme.Colors.textSecondary)
                    }
                    .padding(.bottom, 32)
                }
            }
            .padding()
        }
    }
}
