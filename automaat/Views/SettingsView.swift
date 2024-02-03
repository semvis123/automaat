import Foundation

import SwiftUI
import CoreData

struct SettingsView: View {
    @AppStorage("theme") private var themeId: ThemeId = .red
    @AppStorage("mock-api") private var mockedApi: Bool = false
    @AppStorage("mock-images") private var mockedImages: Bool = false
    
    @EnvironmentObject var api: APIController
    
    var body: some View {
        Form {
            Section {
                Picker("Thema", selection: $themeId) {
                    ForEach(ThemeId.allCases) { themeId in
                        Text(themeId.rawValue.capitalized)
                    }
                }
                .accentColor(.themedColor)
            }
            
            Section {
                Button("Leeg auto afbeelding cache") {
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ImageCache")
                    fetchRequest.predicate = NSPredicate(
                        format: "query NOT CONTAINS %@", "logo"
                    )
                    let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                    try! PersistenceController.shared.container.viewContext.execute(batchDeleteRequest)
                }
                
                Button("Leeg logo cache") {
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ImageCache")
                    fetchRequest.predicate = NSPredicate(
                        format: "query CONTAINS %@", "logo"
                    )
                    let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                    try! PersistenceController.shared.container.viewContext.execute(batchDeleteRequest)
                }
                
                Button("Ververs backend data") {
                    Task {
                        try await api.refreshData()
                    }
                }
            }
            
            Section {
                Toggle("Mock afbeeldingen", isOn: $mockedImages)
                Toggle("Mock api", isOn: $mockedApi)
            }
            if api.loggedIn {
                Section {
                    Button("Uitloggen") {
                        api.logout()
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
}
