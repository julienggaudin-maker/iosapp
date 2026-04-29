# iosapp

Minimal SwiftUI iOS 16+ app scaffolded for a Home screen MVP.

## Requirements
- Xcode 15+
- iOS 16+ deployment target

## How to run
1. Open `iosapp.xcodeproj` in Xcode.
2. Select the `iosapp` scheme and run on any iPhone simulator.

## How to test
### Simulator
- Launch the app; you should see the Home screen with loading, then loaded or error state.
- Toggle Airplane Mode to confirm the offline screen and banner behavior.
- If you need to override the endpoint, set `HOME_API_BASE_URL` in `iosapp/App/Info.plist`.
- Pull to refresh to confirm it re-fetches from the network.
- Open the "Carrières" tab (briefcase) to view the "Nous recrutons" list with 10+ offers.
- Tap an offer to open the detail screen and verify the "Postuler" CTA opens Safari for https links or Mail for mailto links.
- Verify the offer with an empty applyURL hides the "Postuler" button.

### Previews (all states)
- Open `iosapp/Features/Home/HomeView.swift` in Xcode to view Loading, Loaded, Empty, Error, and Offline previews for iPhone SE + iPhone 16 Pro Max, in light/dark mode with Dynamic Type XL.

### Optional: force specific states
To force a scenario on-device, temporarily update `RootView` to pass a `HomeMockService`:
```swift
RootView(
    homeRepository: HomeMockService(response: .loaded(.sample)),
    networkMonitor: NetworkMonitor(isConnected: true, monitor: nil)
)
```
Swap `.loaded` for `.empty`, `.error(.unknown)`, or set `isConnected` to `false` to see offline. For careers scenarios, pass a custom `jobRepository` (e.g. `MockJobRepository(resourceName: "jobs_mock")`) or a stub repository in previews/tests.
