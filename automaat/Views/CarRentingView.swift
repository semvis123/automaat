import SwiftUI

struct CarRentingView: View {
    @StateObject var car: Car
    @State var carImage: Data? = nil
    @State var favorite = false
    @Binding var sheetPage: CarSheetPage
    @EnvironmentObject var imageFetcher: ImageFetcher
    @Binding var image: Data?
    
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
                    Text("€\(car.price ?? 0 ),-")
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
                DatePicker(selection: .constant(.now),
                           in: Date()...Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
                           displayedComponents: .date,
                           label: {}
                )
                .datePickerStyle(.graphical)
            }
            .padding()
            
            Spacer()
            Button(action: mapViewController.closeSheet){
                Text("Reserveer")
            }
            .buttonStyle(.borderedProminent)
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
