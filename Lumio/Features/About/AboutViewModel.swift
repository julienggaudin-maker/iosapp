import Foundation

final class AboutViewModel: ObservableObject {
    let appName = "Lumio"
    let tagline = "Organisez votre vie, libérez votre potentiel"
    let description = "Lumio est une application de productivité personnelle conçue pour vous aider à clarifier vos priorités, atteindre vos objectifs et vivre chaque journée avec intention."
    let missions: [CompanyMission]
    let values: [CompanyValue]
    let appVersion: String

    init(
        missions: [CompanyMission] = CompanyContent.missions,
        values: [CompanyValue] = CompanyContent.values,
        appVersion: String = AboutViewModel.resolveAppVersion()
    ) {
        self.missions = missions
        self.values = values
        self.appVersion = appVersion
    }

    private static func resolveAppVersion() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        return version ?? "1.0"
    }
}
