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
                    
                    List {
                        ForEach(api.rentals.sorted(by: { rental1, rental2 in
                            rental1.backendId > rental2.backendId
                        })) { rental in
                            HStack {
                                if let car = api.cars.first(where: { car in
                                    car.backendId == rental.car
                                }) {
                                    FetchedImage(preset: .Car, car: car)
                                        .frame(width: 50, height: 50)
                                    Text("\(car.brand ?? "") \(car.model ?? "")")
                                        .frame(maxWidth: 200)
                                    Spacer()
                                    if rental.from != nil && rental.to != nil {
                                        Text(rental.from!.formatted(.dateTime.day().month()))
                                    }
                                } else {
                                    // assume it is still loading
                                    ProgressView()
                                        .progressViewStyle(LinearProgressViewStyle())
                                }
                            }
                        }
                        if api.rentals.isEmpty {
                            Text("Geen historie gevonden, reserveer je eerste rit!")
                        }
                    }
                    Spacer()
                }
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        NavigationLink {
                            SettingsView()
                        } label: {
                            Image(systemName: "gear")
                        }
                    }
                }
            }
        } else {
            LoginView()
        }
        
    }
}


#Preview {
    AccountView().environmentObject(APIControllerMock(persistanceCtx: PersistenceController(inMemory: true).container.viewContext))
}
