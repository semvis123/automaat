import SwiftUI

struct CarRentingView: View {
    @Environment(\.theme) var theme: Theme
    @EnvironmentObject var api: APIController
    @EnvironmentObject var imageFetcher: ImageFetcher
    
    @StateObject var car: Car
    @State var carImage: Data? = nil
    @State var favorite = false
    @Binding var sheetPage: CarSheetPage
    @Binding var image: Data?
    @State var rentDate = Date.now
    @State var rentError = false
    
    let animation: Namespace.ID
    var mapViewController: MapPageViewController
    
    func cancelRent() {
        withAnimation {
            sheetPage = .detail
            mapViewController.lockSheetSize(large: false)
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                FetchedImage(preset: .Car, car: car, loadedImage: $image)
                    .matchedGeometryEffect(id: "carImage", in: animation)
                    .frame(width: 100, height: 80)
                VStack(alignment: .leading){
                    Text("\(car.brand ?? "") \(car.model ?? "")")
                        .font(.title2)
                        .matchedGeometryEffect(id: "carName", in: animation)
                    Text("€\(car.price)")
                        .matchedGeometryEffect(id: "carPrice", in: animation)
                }
                .padding([.leading])
                Spacer()
            }
            .padding([.top, .leading, .trailing])
            .padding(.top, 20)
            
            VStack(alignment: .leading){
                Text("Topkeuze! Kies alleen nog een datum en maak je klaar voor een geweldige rit.")
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom)
                DatePicker(selection: $rentDate,
                           in: Date()...Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
                           displayedComponents: .date,
                           label: {}
                )
                .datePickerStyle(.graphical)
                .accentColor(theme.color)
            }
            .padding()
            if rentError {
                Text("Reserveren mislukt")
                    .foregroundStyle(.red)
                    .padding()
            } else {
                Spacer()
            }
            Button(action: {
                Task {
                    do {
                        try await self.api.rentCar(car: car, date: rentDate)

                        // schedule notification for when the car is ready
                        let content = UNMutableNotificationContent()
                        content.title = "Uw auto staat klaar!"
                        content.subtitle = "\(car.brand ?? "") \(car.model ?? "")"

                        var timeInterval = rentDate.timeIntervalSinceNow
                        if timeInterval < 0 {
                            timeInterval = 10
                        }
                        
                        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
                        let request = UNNotificationRequest(identifier: "rentalReady", content: content, trigger: trigger)
                        try await UNUserNotificationCenter.current().add(request)
                        mapViewController.closeSheet()                        
                    } catch {
                        rentError = true
                    }
                }
            }) {
                Text("Reserveer")
            }
            .buttonStyle(.borderedProminent)
            .tint(theme.color)
            .font(.title2)
            .padding(.top, 20)
            .matchedGeometryEffect(id: "actionButton", in: animation)
            Button(action: cancelRent){
                Text("Annuleer")
            }
            .buttonStyle(.plain)
            .font(.footnote)
            .padding(.top)
            .padding(.bottom, 30)
        }
        
        .interactiveDismissDisabled()
    }
}
