import Foundation

import SwiftUI
import CoreData

struct SettingsView: View {
    @AppStorage("theme") private var themeId: ThemeId = .red
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
                Button("Uitloggen") {
                    api.logout()
                }
                .foregroundColor(.red)
            }
        }
    }
}
