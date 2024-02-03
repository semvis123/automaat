import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        let car1 = Car(context: viewContext)
        car1.brand = "Honda"
        car1.model = "Civic"
        car1.licenseplate = "1-ABC-123"
        car1.price = 100
        car1.latitude = 53.22
        car1.longitude = 6.56
        car1.options = "RGB"
        car1.backendId = 5
        car1.fuel = "Diesel"

        let car2 = Car(context: viewContext)
        car2.brand = "Toyota"
        car2.model = "Corolla"
        car2.licenseplate = "2-DEF-456"
        car2.price = 200
        car2.latitude = 53.15
        car2.longitude = 6.45
        car2.options = "Turbo"
        car2.backendId = 6
        car2.fuel = "Diesel"

        let car3 = Car(context: viewContext)
        car3.brand = "Mazda"
        car3.model = "MX-5"
        car3.licenseplate = "3-GHI-789"
        car3.price = 300
        car3.latitude = 53.2
        car3.longitude = 6.6
        car3.options = "V8"
        car3.backendId = 7
        car3.fuel = "Diesel"

        let car4 = Car(context: viewContext)
        car4.brand = "Ford"
        car4.model = "Mustang"
        car4.licenseplate = "4-JKL-012"
        car4.price = 400
        car4.latitude = 53.27
        car4.longitude = 6.47
        car4.options = "V12"
        car4.backendId = 8
        car4.fuel = "Diesel"

        let rent1 = Rental(context: viewContext)
        rent1.from = Date().addingTimeInterval(-3600)
        rent1.to = rent1.from
        rent1.car = car1.backendId
        rent1.state = "RETURNED"
        rent1.backendId = 1
        
        let rent2 = Rental(context: viewContext)
        rent2.from = Date()
        rent2.to = rent2.from
        rent2.car = car2.backendId
        rent2.state = "ACTIVE"
        rent2.backendId = 2


        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "automaat")
        let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.semvis123.automaat")!.appendingPathComponent("automaat.sqlite").absoluteURL
        let persistantDescription = NSPersistentStoreDescription(url: url)
        container.persistentStoreDescriptions = [persistantDescription]
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
