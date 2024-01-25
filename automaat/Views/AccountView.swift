import SwiftUI
import CoreData

struct AccountView: View {
    @EnvironmentObject var api: APIController
    
    var body: some View {
        if api.loggedIn && api.accountInfo != nil {
            NavigationView {
                VStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 50,height: 50)
                    Text("\(api.customerInfo?.firstName ?? "") \(api.customerInfo?.lastName ?? "")")
                        .padding()
                    
                    // Button("clear brand logo cache") {
                    //     let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ImageCache")
                    //     fetchRequest.predicate = NSPredicate(
                    //         format: "query CONTAINS %@", "logo"
                    //     )
                    //     let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                    //     try! PersistenceController.shared.container.viewContext.execute(batchDeleteRequest)
                    // }
                    
                    // Button("refresh backend data") {
                    //     Task {
                    //         try await api.refreshData()
                    //     }
                    // }
                    List {
                        ForEach(api.rentals.sorted(by: { rental1, rental2 in
                            rental1.backendId > rental2.backendId
                        })) { rental in
                            HStack {
                                let car = api.cars.first(where: { car in
                                    car.backendId == rental.car
                                })
                                
                                FetchedImage(preset: .Car, car: car)
                                    .frame(width: 50, height: 50)
                                Text("\(car?.brand ?? "") \(car?.model ?? "")")
                                    .frame(maxWidth: 200)
                                Spacer()
                                if rental.from != nil && rental.to != nil {
                                    Text(rental.from!.formatted(.dateTime.day().month()))
                                }
                            }
                        }
                    }
                    Spacer()
                }
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button("Logout") {
                            api.logout()
                        }
                        .buttonStyle(.bordered)
                    }
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
