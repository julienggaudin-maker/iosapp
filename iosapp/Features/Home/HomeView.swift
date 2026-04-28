import SwiftUI

struct HomeView: View {
    @Environment(\.scenePhase) private var scenePhase
    @ObservedObject var viewModel: HomeViewModel
    @State private var selectedSection: HomeSection?

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
        .navigationTitle("Accueil")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            Task { await viewModel.onAppear() }
        }
        .refreshable {
            await viewModel.refresh()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                viewModel.onForeground()
            }
        }
        .alert("Erreur", isPresented: $viewModel.shouldPresentAuth) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Votre session a expire. Merci de vous reconnecter.")
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            HomeSkeletonView()
                .accessibilityIdentifier("home.loading")
        case .loaded(let payload):
            HomeContentView(
                welcomeMessage: viewModel.welcomeMessage,
                heroImageURL: payload.heroImageURL,
                showsWaveIcon: viewModel.showWaveIcon,
                sections: payload.sections,
                ctaTapped: { section, index in
                    if viewModel.handleCtaTap(section: section, position: index) {
                        selectedSection = section
                    }
                }
            )
            .accessibilityIdentifier("home.loaded")
        case .empty:
            HomeEmptyView(onPrimaryAction: {
                let emptySection = HomeSection(
                    id: UUID(),
                    title: "Explorer",
                    subtitle: "",
                    ctaTitle: "Explorer",
                    ctaName: "empty"
                )
                if viewModel.handleCtaTap(section: emptySection, position: 0) {
                    selectedSection = emptySection
                }
            })
            .accessibilityIdentifier("home.empty")
        case .error(let error):
            HomeErrorView(message: error.userMessage) {
                Task { await viewModel.retry() }
            }
            .accessibilityIdentifier("home.error")
        case .offline:
            HomeOfflineView(showCachedDataMessage: false) {
                Task { await viewModel.retry() }
            }
            .accessibilityIdentifier("home.offline")
        }
    }
}

#Preview("Loading - iPhone SE") {
    NavigationStack {
        HomeView(viewModel: .previewLoading())
    }
    .previewDisplayName("Loading - SE Light")
    .preferredColorScheme(.light)
    .environment(\.dynamicTypeSize, .accessibility2)
    .previewDevice("iPhone SE (3rd generation)")
}

#Preview("Loading - Pro Max") {
    NavigationStack {
        HomeView(viewModel: .previewLoading())
    }
    .previewDisplayName("Loading - Pro Max Dark")
    .preferredColorScheme(.dark)
    .environment(\.dynamicTypeSize, .accessibility2)
    .previewDevice("iPhone 16 Pro Max")
}

#Preview("Loaded - iPhone SE") {
    NavigationStack {
        HomeView(viewModel: .previewLoaded())
    }
    .previewDisplayName("Loaded - SE Light")
    .preferredColorScheme(.light)
    .environment(\.dynamicTypeSize, .accessibility2)
    .previewDevice("iPhone SE (3rd generation)")
}

#Preview("Loaded - Pro Max") {
    NavigationStack {
        HomeView(viewModel: .previewLoaded())
    }
    .previewDisplayName("Loaded - Pro Max Dark")
    .preferredColorScheme(.dark)
    .environment(\.dynamicTypeSize, .accessibility2)
    .previewDevice("iPhone 16 Pro Max")
}

#Preview("Empty - iPhone SE") {
    NavigationStack {
        HomeView(viewModel: .previewEmpty())
    }
    .previewDisplayName("Empty - SE Light")
    .preferredColorScheme(.light)
    .environment(\.dynamicTypeSize, .accessibility2)
    .previewDevice("iPhone SE (3rd generation)")
}

#Preview("Empty - Pro Max") {
    NavigationStack {
        HomeView(viewModel: .previewEmpty())
    }
    .previewDisplayName("Empty - Pro Max Dark")
    .preferredColorScheme(.dark)
    .environment(\.dynamicTypeSize, .accessibility2)
    .previewDevice("iPhone 16 Pro Max")
}

#Preview("Error - iPhone SE") {
    NavigationStack {
        HomeView(viewModel: .previewError())
    }
    .previewDisplayName("Error - SE Light")
    .preferredColorScheme(.light)
    .environment(\.dynamicTypeSize, .accessibility2)
    .previewDevice("iPhone SE (3rd generation)")
}

#Preview("Error - Pro Max") {
    NavigationStack {
        HomeView(viewModel: .previewError())
    }
    .previewDisplayName("Error - Pro Max Dark")
    .preferredColorScheme(.dark)
    .environment(\.dynamicTypeSize, .accessibility2)
    .previewDevice("iPhone 16 Pro Max")
}

#Preview("Offline - iPhone SE") {
    NavigationStack {
        HomeView(viewModel: .previewOffline())
    }
    .previewDisplayName("Offline - SE Light")
    .preferredColorScheme(.light)
    .environment(\.dynamicTypeSize, .accessibility2)
    .previewDevice("iPhone SE (3rd generation)")
}

#Preview("Offline - Pro Max") {
    NavigationStack {
        HomeView(viewModel: .previewOffline())
    }
    .previewDisplayName("Offline - Pro Max Dark")
    .preferredColorScheme(.dark)
    .environment(\.dynamicTypeSize, .accessibility2)
    .previewDevice("iPhone 16 Pro Max")
}
