import SwiftUI

struct ValueCardView: View {
    let value: CompanyValue

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Text(value.emoji)
                    .font(.system(size: 28))
                    .accessibilityLabel(value.emojiAccessibilityLabel)
                VStack(alignment: .leading, spacing: 6) {
                    Text(value.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(value.description)
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
    ValueCardView(value: CompanyContent.values[0])
        .padding()
}
