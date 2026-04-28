import SwiftUI

@main
struct iosappApp: App {
    init() {
        HomeMetricsReporter.shared.start()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
