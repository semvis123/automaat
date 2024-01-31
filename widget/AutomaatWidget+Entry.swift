import Foundation
import SwiftUI
import WidgetKit

extension AutomaatWidget {
    struct EntryView: View {
        let entry: Entry
        
        var body: some View {
            VStack(alignment: .center) {
                HStack {
                    if let image = entry.image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 110, height: 80)
                            .padding()
                    }
                    if let car = entry.car {
                        Text("\(car.brand ?? "") \(car.model ?? "")")
                            .font(.title3)
                    }
                    if entry.car == nil || entry.rental == nil {
                        Text("Geen geplande reserveringen")
                    }
                }
                if let rental = entry.rental, let fromDate = rental.from {
                    if Calendar.current.isDateInToday(fromDate) {
                        Text("Uw auto staat klaar!")
                            .font(.footnote)
                    } else {
                        Text("Beschikbaar vanaf \(fromDate.formatted(.dateTime.month().day()))")
                            .font(.footnote)
                    }
                }
            }
        }
    }
}

extension AutomaatWidget {
    struct Entry: TimelineEntry {
        var date: Date = .now
        var rental: Rental?
        var car: Car?
        var image: UIImage?
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

extension UIImage {
    func resized(toWidth width: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
}
