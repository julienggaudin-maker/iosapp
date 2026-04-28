import SwiftUI

struct HomeEmptyView: View {
    let onPrimaryAction: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 40, weight: .medium))
                .foregroundStyle(.secondary)
            Text("Rien a afficher pour l'instant")
                .font(.title3.weight(.semibold))
                .multilineTextAlignment(.center)
            Text("Decouvrez les sections principales pour bien demarrer.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button(action: onPrimaryAction) {
                Text("Explorer")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .accessibilityIdentifier("home.empty.cta")
        }
        .padding(.horizontal, 32)
    }
}

#Preview {
    HomeEmptyView(onPrimaryAction: {})
}
