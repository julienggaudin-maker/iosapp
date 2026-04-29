import SwiftUI

enum HomeAccentColorProvider {
    static func color(for name: String) -> Color {
        switch name {
        case "indigo":
            return .indigo
        case "teal":
            return .teal
        case "orange":
            return .orange
        case "pink":
            return .pink
        default:
            return .blue
        }
    }
}

extension HomeSection {
    var accentColor: Color {
        HomeAccentColorProvider.color(for: accentColorName)
    }
}
