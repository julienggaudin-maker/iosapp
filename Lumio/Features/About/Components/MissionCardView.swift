import SwiftUI

struct MissionCardView: View {
    let mission: CompanyMission

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Text(mission.emoji)
                    .font(.system(size: 28))
                    .accessibilityLabel(mission.emojiAccessibilityLabel)
                VStack(alignment: .leading, spacing: 6) {
                    Text(mission.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(mission.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
    }
}

#Preview {
    MissionCardView(
        mission: CompanyContent.missions[0]
    )
    .padding()
}
