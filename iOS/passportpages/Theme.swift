import SwiftUI

/// deep travel-document navy with a visa-stamp blue accent
enum Theme {
    static let background = Color(red: 0.055, green: 0.106, blue: 0.169)
    static let accent = Color(red: 0.18, green: 0.525, blue: 0.871)
    static let ink = Color(red: 0.953, green: 0.965, blue: 0.98)
    static let cardBackground = Color(red: 0.125, green: 0.176, blue: 0.239)
    static let secondaryInk = Color(red: 0.796, green: 0.808, blue: 0.824)

    static let titleFont = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let headingFont = Font.system(.headline, design: .rounded).weight(.semibold)
    static let bodyFont = Font.system(.body, design: .rounded)
    static let captionFont = Font.system(.caption, design: .rounded)

    static let cornerRadius: CGFloat = 18
}

extension View {
    func themedBackground() -> some View {
        self.background(Theme.background.ignoresSafeArea())
    }
}
