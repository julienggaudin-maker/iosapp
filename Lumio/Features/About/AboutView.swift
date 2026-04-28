import SwiftUI

struct AboutView: View {
    @StateObject private var viewModel: AboutViewModel

    init(viewModel: AboutViewModel = AboutViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                heroSection
                descriptionSection
                missionsSection
                valuesSection
                versionSection
            }
            .padding(20)
        }
        .navigationTitle("À propos")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(uiColor: .systemGroupedBackground))
        .onAppear {
            AnalyticsService.track(event: "about_screen_opened")
        }
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.appName)
                .font(.largeTitle.bold())
                .foregroundColor(.primary)
            Text(viewModel.tagline)
                .font(.title3)
                .foregroundColor(.secondary)
        }
    }

    private var descriptionSection: some View {
        Text(viewModel.description)
            .font(.body)
            .foregroundColor(.primary)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var missionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Nos missions")
                .font(.title2.bold())
                .foregroundColor(.primary)
            ForEach(viewModel.missions) { mission in
                MissionCardView(mission: mission)
            }
        }
    }

    private var valuesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Nos valeurs")
                .font(.title2.bold())
                .foregroundColor(.primary)
            ForEach(viewModel.values) { value in
                ValueCardView(value: value)
            }
        }
    }

    private var versionSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Version de l'application")
                .font(.footnote)
                .foregroundColor(.secondary)
            Text(viewModel.appVersion)
                .font(.footnote.bold())
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 8)
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}
