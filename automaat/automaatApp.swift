import SwiftUI
import SwiftUITheme

@main
struct automaatApp: App {
    @AppStorage("theme") private var themeId: ThemeId = .teal
    let persistenceController = PersistenceController.shared
    let apiController = APIController()
    let imageFetcher = ImageFetcher()

    var body: some Scene {
        WindowGroup {
            SplashView()
                .theme(themeId.theme)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(apiController)
                .environmentObject(imageFetcher)
                .onAppear {
                    Task {
                        try await apiController.refreshData()
                        let success = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
                    }
                }
        }
    }
}
