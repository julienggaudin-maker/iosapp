import SwiftUI

struct HomeErrorView: View {
    let message: String
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundStyle(.orange)
                .accessibilityHidden(true)

            Text("Une erreur est survenue")
                .font(.headline)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Reessayer", action: retryAction)
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

struct HomeErrorView_Previews: PreviewProvider {
    static var previews: some View {
        HomeErrorView(message: "Impossible de charger la page d'accueil.", retryAction: {})
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
