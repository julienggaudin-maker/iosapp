import SwiftUI

struct HomeSectionDetailView: View {
    let section: HomeSection

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: section.iconName)
                .font(.system(size: 48, weight: .semibold))
                .foregroundStyle(section.accentColor)
                .accessibilityHidden(true)

            Text(section.title)
                .font(.title2.weight(.semibold))
                .multilineTextAlignment(.center)

            Text(section.subtitle)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .navigationTitle(section.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        HomeSectionDetailView(section: .sampleSections()[0])
    }
}
