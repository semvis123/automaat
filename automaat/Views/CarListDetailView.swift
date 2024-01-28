import Foundation
import SwiftUI

struct CarListDetailView: View {
    @Binding var car: Car
    @Binding var image: Data?
    @State var manualRand: Int = Int.random(in: 0...1)
    @State var speedRand: Int = Int.random(in: 130...300)
    
    var body: some View {
        ScrollView {
            Text("\(car.brand ?? "") \(car.model ?? "")")
            
            FetchedImage(preset: .Car, car: car, loadedImage: $image)
                .frame(width: 300, height: 200)
            
            Text("€\(car.price ),-")
                .font(.title)
                .bold()
                .fixedSize(horizontal: true, vertical: false)
            HStack {
                let iconSize = 40.00
                let feature = [
                    (Image("manual-gear"), ["Manual", "Automatic"][manualRand]),
                    (Image(systemName:"fuelpump"), car.fuel?.lowercased().capitalized ?? "Onbekend"),
                    (Image(systemName:"speedometer"), "\(speedRand) km/h"),
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
        .toolbar {
            Button {
                car.favorite = !car.favorite
                let backendId = car.backendId
                try? PersistenceController.shared.container.viewContext.save()
                PersistenceController.shared.container.viewContext.reset()
                // get new car
                let fetchRequest = Car.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "backendId = %ld", backendId)
                let cars = try? PersistenceController.shared.container.viewContext.fetch(fetchRequest)
                if let car = cars?.first {
                    self.car = car
                }
            } label: {
                Image(systemName: car.favorite ? "star.fill" :"star")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.themedColor)
            }
        }

    }
}
