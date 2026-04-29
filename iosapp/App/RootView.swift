import SwiftUI

struct RootView: View {
    @StateObject private var homeViewModel: HomeViewModel
    @StateObject private var jobListViewModel: JobListViewModel

    init(
        homeRepository: HomeRepository = HomeAPIService(),
        jobRepository: JobRepositoryProtocol = MockJobRepository(),
        networkMonitor: NetworkMonitor = .shared
    ) {
        _homeViewModel = StateObject(
            wrappedValue: HomeViewModel(
                repository: homeRepository,
                networkMonitor: networkMonitor
            )
        )
        _jobListViewModel = StateObject(
            wrappedValue: JobListViewModel(
                repository: jobRepository,
                networkMonitor: networkMonitor
            )
        )
    }

    var body: some View {
        TabView {
            NavigationStack {
                HomeView(viewModel: homeViewModel)
            }
            .tabItem {
                Label("Accueil", systemImage: "house")
            }

            NavigationStack {
                JobListView(viewModel: jobListViewModel)
            }
            .tabItem {
                Label("Carrières", systemImage: "briefcase")
            }
        }
    }
}

#Preview {
    RootView()
}
