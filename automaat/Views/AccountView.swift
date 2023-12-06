import SwiftUI
import CoreData

struct AccountView: View {
    @EnvironmentObject var api: APIController
    
    var body: some View {
        if api.loggedIn && api.accountInfo != nil {
            VStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 50,height: 50)
                Text("Account: \(api.accountInfo?.login ?? "")")
                Text("Voornaam: \(api.customerInfo?.firstName ?? "")")
                Text("Achternaam: \(api.customerInfo?.lastName ?? "")")
                Text("Email:  \(api.accountInfo?.email ?? "")")
                Text("Lid sinds:  \(api.customerInfo?.from ?? "")")
                Button("Logout") {
                    api.logout()
                }
                .buttonStyle(.bordered)
                Button("clear brand logo cache") {
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ImageCache")
                    fetchRequest.predicate = NSPredicate(
                        format: "query CONTAINS %@", "logo"
                    )
                    let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                    try! PersistenceController.shared.container.viewContext.execute(batchDeleteRequest)
                }
            }
        } else {
            LoginView()
        }
        
    }
}


#Preview {
    AccountView().environmentObject(APIController())
}
