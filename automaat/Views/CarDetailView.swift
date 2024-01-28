import SwiftUI
import MapKit

struct CarDetailView: View {
    @StateObject var car: Car
    @State var carImage: Data? = nil
    @Binding var sheetPage: CarSheetPage
    @Binding var etaData: EtaData?
    @Binding var image: Data?
    @EnvironmentObject var imageFetcher: ImageFetcher
    @Environment(\.theme) var theme: Theme
    
    let animation: Namespace.ID
    var mapViewController: MapPageViewController
    
    func openRentPage() {
        withAnimation {
            sheetPage = .renting
            mapViewController.lockSheetSize(large: true)
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: car.favorite ? "star.fill" :"star")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.themedColor)
                    .onTapGesture {
                        car.favorite = !car.favorite
                        try? PersistenceController.shared.container.viewContext.save()
                    }
                Spacer()
                Button(action: {
                    mapViewController.closeSheet()
                }) {
                    ZStack {
                        Circle()
                            .fill(Color(white: 0.19))
                        Image(systemName: "xmark")
                            .resizable()
                            .scaledToFit()
                            .font(Font.body.weight(.bold))
                            .scaleEffect(0.416)
                            .foregroundColor(Color(white: 0.62))
                    }
                    .frame(width: 30,height: 30)
                }
            }
            .padding([.leading, .trailing, .top], 30)
            VStack {
                FetchedImage(preset: .Car, car: car, loadedImage: $image)
                    .matchedGeometryEffect(id: "carImage", in: animation)
                    .scaledToFit()
                    .frame(width: 250, height: 150)
                Text("\(car.brand ?? "") \(car.model ?? "")")
                    .font(.title2)
                    .matchedGeometryEffect(id: "carName", in: animation)
                    .padding(.bottom, 0.2)
                if etaData != nil {
                    let time = etaData!.time
                    let distance = etaData!.distance
                    Text("\(Int(time)) minuten lopen (\(Int(distance))m)")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.bottom, 30)
                } else {
                    Text("")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.bottom, 30)
                }
                HStack {
                    VStack(alignment: .leading) {
                        Text("Per dag")
                            .font(.footnote)
                        Text("€\(car.price ),-")
                            .font(.title)
                            .bold()
                            .fixedSize(horizontal: true, vertical: false)
                            .matchedGeometryEffect(id: "carPrice", in: animation)
                    }
                    Spacer()
                    Button(action: openRentPage){
                        Text("Reserveer nu")
                            .fixedSize(horizontal: true, vertical: false)
                    }
                    .matchedGeometryEffect(id: "actionButton", in: animation)
                    .buttonStyle(.borderedProminent)
                    .font(.title2)
                    .tint(theme.color)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .padding()
            }
            
            Spacer()
            HStack {
                VStack {
                    HStack {
                        let iconSize = 40.00
                        let feature = [
                            (Image("manual-gear"), ["Manual", "Automatic"][Int.random(in: 0...1)]),
                            (Image(systemName:"fuelpump"), car.fuel?.lowercased().capitalized ?? "Onbekend"),
                            (Image(systemName:"speedometer"), "\(Int.random(in: 130...300)) km/h"),
                        ]
                        ForEach(feature, id:\.1) { (f: (Image, String)) in
                            ZStack {
                                Color.init(hue: 0, saturation: 0, brightness: 0.17)
                                VStack {
                                    f.0
                                        .resizable()
                                        .frame(width: iconSize, height: iconSize)
                                        .foregroundStyle(.white)
                                        .padding(.bottom)
                                    Text(f.1)
                                        .foregroundStyle(.white)
                                }
                            }
                            .frame(width: 100, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.white, lineWidth: 1)
                            )
                        }
                    }
                    
                }
                .padding(.top, 40)
            }.frame(minHeight: 0, maxHeight: .infinity, alignment: .top)
        }
        
    }
}
