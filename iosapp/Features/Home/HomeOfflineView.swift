import SwiftUI

struct HomeOfflineView: View {
    let showCachedDataMessage: Bool
    var retryAction: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 42, weight: .semibold))
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            Text(showCachedDataMessage ? "Pas de connexion - donnees en cache" : "Pas de connexion")
                .font(.headline)
                .multilineTextAlignment(.center)

            if !showCachedDataMessage {
                Text("Verifiez votre reseau et reessayez.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                if let retryAction {
                    Button("Reessayer", action: retryAction)
                        .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding()
        .accessibilityElement(children: .combine)
    }
}

struct HomeOfflineView_Previews: PreviewProvider {
    static var previews: some View {
        HomeOfflineView(showCachedDataMessage: true)
            .previewDisplayName("Offline Cached")
        HomeOfflineView(showCachedDataMessage: false)
            .previewDisplayName("Offline No Cache")
            .preferredColorScheme(.dark)
    }
}
