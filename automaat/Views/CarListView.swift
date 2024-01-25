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
                
                Text("€\(car.price ),-")
                    .font(.title)
                    .bold()
                    .fixedSize(horizontal: true, vertical: false)
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
                Image(systemName: car.favorite ? "star.fill" :"star")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white )
                    .onTapGesture {
                        car.favorite = !car.favorite
                        try? PersistenceController.shared.container.viewContext.save()
                    }
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
                    Text("€\(car.price ) / dag")
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

