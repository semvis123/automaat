import SwiftUI

struct CarListItemView: View {
    @EnvironmentObject var imageFetcher: ImageFetcher
    var car: Car
    
    
    var body: some View {
        NavigationLink {
            ScrollView {
                Text("\(car.brand ?? "") \(car.model ?? "")")
                
                FetchedImage(preset: .Car, car: car)
                    .frame(width: 300, height: 200)
            }
        } label: {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    FetchedImage(preset: .BrandLogo, car: car)
                            .frame(width: 30, height: 30)
                            .padding(3)
                    FetchedImage(preset: .Car, car: car)
                        .frame(width: 130, height: 80)
                        .padding(.vertical, 3)
                    Text("**\(car.model ?? "")**")
                        .foregroundStyle(.white)
                    Text("€\(car.price ?? 0) / dag")
                        .foregroundStyle(.white)
                }
                .padding()
            }
            .frame(height: 200)
            .frame(maxWidth: .infinity)
            .background(Color.init(hue: 0, saturation: 0, brightness: 0.16))
            .cornerRadius(10)
            .overlay {
                RoundedRectangle(cornerRadius: 10.0)
                    .stroke(.accent)
            }
        }
    }
}

struct CarListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var imageFetcher: ImageFetcher
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Car.timestamp, ascending: true)],
        animation: .default)
    private var cars: FetchedResults<Car>
    @State private var showingAlert = false
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(cars) { (car: Car) in
                        CarListItemView(car: car)
                    }
                }
            }
            .navigationBarTitle("Auto's")
        }
        .padding(.horizontal)
    }
}

#Preview {
    CarListView()
}
