import SwiftUI

struct JobListView: View {
    @ObservedObject var viewModel: JobListViewModel

    var body: some View {
        ZStack(alignment: .top) {
            content

            if viewModel.showOfflineBanner && viewModel.state != .offline {
                HomeOfflineView(showCachedDataMessage: true)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut, value: viewModel.showOfflineBanner)
        .background(Color(.systemBackground))
        .navigationTitle("Nous recrutons")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            Task { await viewModel.onAppear() }
        }
        .onDisappear {
            hasScrolled = false
        }
        .refreshable {
            await viewModel.refresh()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            VStack(spacing: 12) {
                ProgressView()
                Text("Chargement des offres...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityIdentifier("careers.loading")
        case .success(let jobs):
            List(jobs) { job in
                NavigationLink {
                    JobDetailView(job: job, onApplyTapped: viewModel.trackApplyTap)
                } label: {
                    JobCardView(job: job)
                }
            }
            .listStyle(.insetGrouped)
            .accessibilityIdentifier("careers.loaded")
        case .empty:
            ContentUnavailableView(
                "Aucune offre active",
                systemImage: "briefcase",
                description: Text("Revenez bientot pour decouvrir nos opportunites.")
            )
            .accessibilityIdentifier("careers.empty")
        case .error(let message):
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(.secondary)
                Text("Une erreur est survenue")
                    .font(.headline)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Button("Reessayer") {
                    Task { await viewModel.retry() }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityIdentifier("careers.error")
        case .offline:
            HomeOfflineView(showCachedDataMessage: false) {
                Task { await viewModel.retry() }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityIdentifier("careers.offline")
        }
    }
}

#Preview("Loaded - iPhone SE") {
    NavigationStack {
        JobListView(viewModel: .previewLoaded())
    }
    .previewDisplayName("Loaded - SE")
    .previewDevice("iPhone SE (3rd generation)")
}

#Preview("Empty - iPad") {
    NavigationStack {
        JobListView(viewModel: .previewEmpty())
    }
    .previewDisplayName("Empty - iPad")
    .previewDevice("iPad Pro (11-inch) (4th generation)")
}
