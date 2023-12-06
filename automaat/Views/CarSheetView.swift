import SwiftUI
import MapKit

enum CarSheetPage {
    case detail, renting
}

struct CarSheetView: View {
    @StateObject var car: Car
    @State var favorite = false
    @State var page = CarSheetPage.detail
    @Binding var etaData: EtaData?
    var imageFetcher: ImageFetcher
    let animation: Namespace.ID
    @State var loadedCarImage: Data? = nil
    var mapViewController: MapPageViewController
    
    var body: some View {
        ZStack {
            if page == .detail {
                CarDetailView(
                    car: car,
                    sheetPage: $page,
                    etaData: $etaData,
                    image: $loadedCarImage,
                    animation: animation,
                    mapViewController: mapViewController
                )
            }
            else {
                CarRentingView(
                    car: car,
                    sheetPage: $page,
                    image: $loadedCarImage,
                    animation: animation,
                    mapViewController: mapViewController
                )
            }
        }.animation(.default, value: page)
            .environmentObject(imageFetcher)
    }
}
