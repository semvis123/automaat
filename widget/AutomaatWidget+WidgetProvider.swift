import Foundation
import WidgetKit
import CoreData

extension AutomaatWidget {
    struct Provider: TimelineProvider {
        let managedObjectContext = PersistenceController.shared.container.viewContext
        
        func placeholder(in context: Context) -> Entry {
            print("getting placeholder")
            return .placeholder
        }
        
        func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
            print("getting snapshot")
            completion(.placeholder)
        }
        
        func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
            guard let rental = fetchRental() else {
                print("could not find rental")
                completion(.init(entries: [.empty], policy: .never))
                return
            }
            guard let car = fetchCar(rental: rental) else {
                print("could not fetch car")
                completion(.init(entries: [.empty], policy: .never))
                return
            }
            Task {
                let entry = Entry(
                    rental: rental,
                    car: car,
                    image: await ImageFetcher().fetchCarImage(car: car)
                )
                completion(.init(entries: [entry], policy: .never))
            }
        }
    }
}

// MARK: - Helpers

extension AutomaatWidget.Provider {
    private func fetchRental() -> Rental? {
        let request = Rental.fetchRequest()
        guard let rentals = try? managedObjectContext.fetch(request) else {
            return nil
        }
        let rental = rentals.first(where: {
            $0.from != nil && (Calendar.current.isDateInToday($0.from!) || $0.from! > .now) &&
            $0.state == "ACTIVE"
        })
        return rental
    }
    
    private func fetchCar(rental: Rental) -> Car? {
        let request = Car.fetchRequest()
        request.predicate = NSPredicate(format: "backendId == %ld", rental.car)
        guard let cars = try? managedObjectContext.fetch(request) else {
            return nil
        }
        if cars.count > 0 {
            return cars[0]
        }
        return nil
    }
}
