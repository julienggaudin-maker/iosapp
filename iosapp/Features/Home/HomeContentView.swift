import SwiftUI

struct HomeContentView: View {
    let welcomeMessage: String
    let heroImageURL: String?
    let showsWaveIcon: Bool
    let sections: [HomeSection]
    let ctaTapped: (HomeSection, Int) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(welcomeMessage)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(Color.primary)
                    if showsWaveIcon {
                        Image(systemName: "hand.wave")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(Color.primary)
                            .accessibilityHidden(true)
                    }
                }
                .padding(.top, 8)

                if let heroImageURL, let url = URL(string: heroImageURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(UIColor.secondarySystemBackground))
                                .frame(height: 180)
                                .redacted(reason: .placeholder)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 180)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        case .failure:
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(UIColor.secondarySystemBackground))
                                .frame(height: 180)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }

                ForEach(Array(sections.enumerated()), id: \.element.id) { index, section in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .center, spacing: 12) {
                            Circle()
                                .fill(section.accentColor.opacity(0.2))
                                .frame(width: 42, height: 42)
                                .overlay(
                                    Image(systemName: section.iconName)
                                        .foregroundStyle(section.accentColor)
                                        .font(.headline)
                                )

                            VStack(alignment: .leading, spacing: 4) {
                                Text(section.title)
                                    .font(.headline)
                                    .foregroundStyle(Color.primary)
                                Text(section.subtitle)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.secondary)
                            }
                            Spacer(minLength: 8)
                        }

                        Button(action: { ctaTapped(section, index) }) {
                            Text(section.ctaTitle)
                                .font(.callout.weight(.semibold))
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(section.accentColor)
                        .contentShape(Rectangle())
                        .accessibilityLabel(section.ctaTitle)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(UIColor.secondarySystemBackground))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(UIColor.separator).opacity(0.4), lineWidth: 1)
                    )
                    .accessibilityElement(children: .contain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct HomeContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HomeContentView(
                welcomeMessage: "Bonjour Julien",
                heroImageURL: HomePayload.sample.heroImageURL,
                showsWaveIcon: true,
                sections: HomeSection.sampleSections(),
                ctaTapped: { _, _ in }
            )
            .padding()
            .previewDisplayName("Light")
            .preferredColorScheme(.light)

            HomeContentView(
                welcomeMessage: "Bonjour Julien",
                heroImageURL: HomePayload.sample.heroImageURL,
                showsWaveIcon: true,
                sections: HomeSection.sampleSections(),
                ctaTapped: { _, _ in }
            )
            .padding()
            .previewDisplayName("Dark")
            .preferredColorScheme(.dark)
        }
        .previewLayout(.sizeThatFits)
    }
}
