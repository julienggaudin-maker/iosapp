import SwiftUI

struct HomeSkeletonView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var isAnimating = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            RoundedRectangle(cornerRadius: 14)
                .fill(skeletonGradient)
                .frame(height: 28)

            ForEach(0..<3) { _ in
                RoundedRectangle(cornerRadius: 16)
                    .fill(skeletonGradient)
                    .frame(height: 140)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .redacted(reason: .placeholder)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
        .accessibilityLabel("Chargement")
    }

    private var skeletonGradient: LinearGradient {
        let base = colorScheme == .dark ? Color.gray.opacity(0.6) : Color.gray.opacity(0.2)
        let highlight = colorScheme == .dark ? Color.gray.opacity(0.3) : Color.gray.opacity(0.4)
        let start = isAnimating ? UnitPoint(x: -0.5, y: 0.3) : UnitPoint(x: 1.1, y: 0.7)
        let end = isAnimating ? UnitPoint(x: 1.4, y: 0.8) : UnitPoint(x: -0.3, y: 0.2)
        return LinearGradient(colors: [base, highlight, base], startPoint: start, endPoint: end)
    }
}

#Preview("Loading") {
    HomeSkeletonView()
        .preferredColorScheme(.light)
}
