import SwiftUI

enum StackEmsTheme {
    enum Colors {
        static let primary = Color(red: 0.2, green: 0.6, blue: 1.0)
        static let secondary = Color(red: 1.0, green: 0.4, blue: 0.3)
        static let accent = Color(red: 0.3, green: 0.9, blue: 0.5)
        static let background = Color(red: 0.08, green: 0.08, blue: 0.12)
        static let surface = Color(red: 0.12, green: 0.12, blue: 0.18)
        static let textPrimary = Color.white
        static let textSecondary = Color.white.opacity(0.7)
    }

    enum Fonts {
        static let title = Font.system(size: 36, weight: .black, design: .rounded)
        static let heading = Font.system(size: 24, weight: .bold, design: .rounded)
        static let body = Font.system(size: 16, weight: .medium, design: .rounded)
        static let caption = Font.system(size: 12, weight: .regular, design: .rounded)
        static let button = Font.system(size: 18, weight: .bold, design: .rounded)
    }

    enum Layout {
        static let cornerRadius: CGFloat = 16
        static let padding: CGFloat = 16
        static let spacing: CGFloat = 12
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(StackEmsTheme.Fonts.button)
            .foregroundStyle(StackEmsTheme.Colors.textPrimary)
            .padding(.horizontal, 32)
            .padding(.vertical, 14)
            .background(StackEmsTheme.Colors.primary)
            .clipShape(RoundedRectangle(cornerRadius: StackEmsTheme.Layout.cornerRadius))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(StackEmsTheme.Fonts.button)
            .foregroundStyle(StackEmsTheme.Colors.primary)
            .padding(.horizontal, 32)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: StackEmsTheme.Layout.cornerRadius)
                    .stroke(StackEmsTheme.Colors.primary, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
