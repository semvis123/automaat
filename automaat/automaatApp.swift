import SwiftUI
import WidgetKit
import SwiftUITheme

@main
struct automaatApp: App {
    @AppStorage("theme") private var themeId: ThemeId = .teal
    @AppStorage("mock-api") private var mockedApi: Bool = false
    @AppStorage("mock-images") private var mockedImages: Bool = false
    @StateObject var api = APIController()
    @StateObject var imageFetcher = ImageFetcher()
    var persistenceController = PersistenceController.shared
    
    
    init() {
        if mockedApi {
            persistenceController = PersistenceController.preview
            _api = StateObject(wrappedValue: APIControllerMock(persistanceCtx: PersistenceController.preview.container.viewContext))
        }
        if mockedImages {
            _imageFetcher = StateObject(wrappedValue: ImageFetcherMock())
        }
    }
    
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
                    WidgetCenter.shared.reloadAllTimelines()
                }
        }
    }
}
