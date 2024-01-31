import SwiftUI
import SwiftUITheme

@main
struct automaatApp: App {
    @AppStorage("theme") private var themeId: ThemeId = .teal
    @StateObject var api = APIController()
    @StateObject var imageFetcher = ImageFetcher()
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            SplashView()
                .theme(themeId.theme)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(api)
                .environmentObject(imageFetcher)
                .onAppear {
                    Task {
                        try await api.refreshData()
                        try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
                    }
                }
        }
    }
}
