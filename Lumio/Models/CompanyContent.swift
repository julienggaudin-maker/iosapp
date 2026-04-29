import Foundation

struct CompanyMission: Identifiable {
    let id = UUID()
    let emoji: String
    let emojiAccessibilityLabel: String
    let title: String
    let description: String
}

struct CompanyValue: Identifiable {
    let id = UUID()
    let emoji: String
    let emojiAccessibilityLabel: String
    let title: String
    let description: String
}

enum CompanyContent {
    static let missions: [CompanyMission] = [
        CompanyMission(
            emoji: "🎯",
            emojiAccessibilityLabel: "Cible",
            title: "Simplifier le quotidien",
            description: "Réduire la friction cognitive en offrant des outils intuitifs qui s'effacent au profit de l'essentiel."
        ),
        CompanyMission(
            emoji: "🌱",
            emojiAccessibilityLabel: "Jeune pousse",
            title: "Favoriser la croissance personnelle",
            description: "Accompagner chaque utilisateur dans son développement, à son propre rythme, sans jugement."
        ),
        CompanyMission(
            emoji: "🤝",
            emojiAccessibilityLabel: "Poignée de main",
            title: "Rendre la productivité accessible",
            description: "Concevoir une expérience inclusive, utilisable par tous, quelle que soit la familiarité avec la technologie."
        ),
        CompanyMission(
            emoji: "🔒",
            emojiAccessibilityLabel: "Cadenas",
            title: "Protéger la vie privée",
            description: "Garantir que les données personnelles restent privées, stockées localement et jamais monétisées."
        )
    ]

    static let values: [CompanyValue] = [
        CompanyValue(
            emoji: "✨",
            emojiAccessibilityLabel: "Étincelles",
            title: "Clarté",
            description: "Nous croyons en la simplicité radicale : chaque fonctionnalité doit avoir une raison d'être évidente."
        ),
        CompanyValue(
            emoji: "💙",
            emojiAccessibilityLabel: "Cœur",
            title: "Empathie",
            description: "Nous concevons pour des humains réels, avec leurs doutes, leurs contraintes et leurs ambitions."
        ),
        CompanyValue(
            emoji: "🏆",
            emojiAccessibilityLabel: "Trophée",
            title: "Excellence",
            description: "Chaque détail compte. Nous ne livrons que ce dont nous sommes fiers."
        ),
        CompanyValue(
            emoji: "🌍",
            emojiAccessibilityLabel: "Globe",
            title: "Transparence",
            description: "Nous communiquons ouvertement sur nos choix techniques, nos engagements et nos limites."
        )
    ]
}
