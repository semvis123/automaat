import Foundation
import SwiftUI
import WidgetKit

extension AutomaatWidget {
    struct EntryView: View {
        let entry: Entry
        
        var body: some View {
            VStack(alignment: .leading) {
                Spacer()
                HStack {
                    if let image = entry.image {
                        Image(uiImage: UIImage(data: image)!)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 110, height: 110)
                    }
                    if let car = entry.car {
                        Text("\(car.brand ?? "") \(car.model ?? "")")
                            .font(.title2)
                        Spacer()
                    }
                    if entry.car == nil && entry.rental == nil {
                        Text("Geen geplande reserveringen")
                    }
                }
                
                HStack {
                    Spacer()
                    if let rental = entry.rental, rental.from != nil {
                        if Calendar.current.isDateInToday(rental.from!) {
                            Text("Auto staat klaar!")
                                .font(.footnote)
                        } else {
                            Text("Beschikbaar vanaf \(rental.from!.formatted(.dateTime.month().day()))")
                                .font(.footnote)
                        }
                    }
                    Spacer()
                }
                Spacer()
            }
        }
    }
}

extension AutomaatWidget {
    struct Entry: TimelineEntry {
        var date: Date = .now
        var rental: Rental?
        var car: Car?
        var image: Data?
    }
}

extension AutomaatWidget.Entry {
    static var empty: Self {
        .init()
    }
    
    static var placeholder: Self {
        .init()
    }
}
