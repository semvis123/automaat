import SwiftUI

struct CarListItemView: View {
    @EnvironmentObject var imageFetcher: ImageFetcher
    @Environment(\.colorScheme) var colorScheme
    @State var carImage: Data? = nil
    @State var car: Car
    
    
    var body: some View {
        NavigationLink {
            CarListDetailView(car: $car, image: $carImage)
        } label: {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    if (colorScheme == .light) {
                        FetchedImage(preset: .BrandLogo, car: car)
                            .colorInvert()
                            .frame(width: 30, height: 30)
                            .padding(3)
                    } else {
                        FetchedImage(preset: .BrandLogo, car: car)
                            .frame(width: 30, height: 30)
                            .padding(3)
                    }
                    FetchedImage(preset: .Car, car: car, loadedImage: $carImage)
                        .frame(width: 130, height: 80)
                        .padding(.vertical, 3)
                    Text("**\(car.model ?? "")**")
                    Text("€\(car.price ) / dag")
                }
                .padding()
            }
            .frame(height: 200)
            .frame(maxWidth: .infinity)
            .background(colorScheme == .dark ? Color.init(hue: 0, saturation: 0, brightness: 0.16) : .init(hue: 0, saturation: 0, brightness: 0.95))
            .cornerRadius(10)
            .overlay {
                RoundedRectangle(cornerRadius: 10.0)
                    .stroke()
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
    @State private var filter = CarFilter(onlyFavorite: false, sortKey: CarSortOption(label: "ID", comparable: { $0.backendId }) )
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(cars.filter { car in
                        if filter.onlyFavorite {
                            return car.favorite
                        }
                        return true
                    }.sorted { car1, car2 in
                        filter.sortKey.comparable(car1) < filter.sortKey.comparable(car2)
                    }) { car in
                        CarListItemView(car: car)
                    }
                }
            }
            .navigationBarTitle("Auto's")
            .padding(.horizontal)
            .toolbar {
                NavigationLink {
                    CarFilterView(filter: $filter)
                } label: {
                    Image(systemName: "slider.horizontal.3")
                }
            }
        }
    }
}

