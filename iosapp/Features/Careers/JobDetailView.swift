import SwiftUI

struct JobDetailView: View {
    let job: JobOffer
    let onApplyTapped: (JobOffer) -> Void

    @State private var safariDestination: SafariDestination?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(job.title)
                    .font(.title)
                    .fontWeight(.semibold)

                VStack(alignment: .leading, spacing: 8) {
                    JobDetailRow(label: "Departement", value: job.department, systemImage: "building.2")
                    JobDetailRow(label: "Localisation", value: job.location, systemImage: "mappin.and.ellipse")
                    JobDetailRow(label: "Publication", value: publishedDate, systemImage: "calendar")
                }

                Text(job.fullDescription)
                    .font(.body)
                    .foregroundStyle(.primary)

                if let applyDestination {
                    Button("Postuler") {
                        onApplyTapped(job)
                        if applyDestination.scheme?.lowercased() == "http" ||
                            applyDestination.scheme?.lowercased() == "https" {
                            safariDestination = SafariDestination(url: applyDestination)
                        } else {
                            openURL(applyDestination)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                    .accessibilityIdentifier("careers.apply")
                }
            }
            .padding(16)
        }
        .navigationTitle("Offre")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $safariDestination) { destination in
            SafariView(url: destination.url)
        }
    }

    @Environment(\.openURL) private var openURL

    private var applyDestination: URL? {
        let trimmed = job.applyURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return URL(string: trimmed)
    }

    private var publishedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: job.publishedAt)
    }
}

private struct JobDetailRow: View {
    let label: String
    let value: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage)
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline)
            }
        }
    }
}

private struct SafariDestination: Identifiable {
    let url: URL

    var id: String { url.absoluteString }
}

#Preview {
    NavigationStack {
        JobDetailView(job: .sample) { _ in }
    }
}
