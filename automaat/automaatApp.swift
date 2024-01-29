import SwiftUI
import SwiftUITheme

@main
struct automaatApp: App {
    @AppStorage("theme") private var themeId: ThemeId = .teal
    @StateObject var apiController = APIController()
    @StateObject var imageFetcher = ImageFetcher()
    let persistenceController = PersistenceController.shared
    
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
