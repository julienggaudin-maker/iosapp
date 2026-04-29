import Foundation

struct JobOffer: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let department: String
    let location: String
    let shortDescription: String
    let fullDescription: String
    let publishedAt: Date
    let applyURL: String
    let isActive: Bool
}

extension JobOffer {
    static let sample = JobOffer(
        id: UUID(),
        title: "iOS Engineer",
        department: "Engineering",
        location: "Paris, France",
        shortDescription: "Construisez des experiences mobiles memorables.",
        fullDescription: "Vous travaillerez avec SwiftUI pour proposer des experiences rapides et fiables.",
        publishedAt: Date(),
        applyURL: "https://example.com/apply",
        isActive: true
    )

    static let sampleList: [JobOffer] = [
        .sample,
        JobOffer(
            id: UUID(),
            title: "Product Designer",
            department: "Design",
            location: "Remote",
            shortDescription: "Donnez vie aux parcours candidat.",
            fullDescription: "Vous collaborerez avec les equipes produit pour definir des interfaces claires.",
            publishedAt: Date().addingTimeInterval(-86400 * 3),
            applyURL: "mailto:jobs@example.com",
            isActive: true
        )
    ]
}
