import SwiftUI

struct RootView: View {
    @StateObject private var viewModel: HomeViewModel

    init(
        repository: HomeRepository = HomeAPIService(),
        networkMonitor: NetworkMonitor = .shared
    ) {
        _viewModel = StateObject(
            wrappedValue: HomeViewModel(
                repository: repository,
                networkMonitor: networkMonitor
            )
        )
    }

    var body: some View {
        NavigationStack {
            HomeView(viewModel: viewModel)
        }
    }
}

#Preview {
    RootView()
}
