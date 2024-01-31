import Foundation
import CoreData

class APIControllerMock: APIController {
    var persistanceCtx: NSManagedObjectContext!
    
    var accountInfoMocked: AccountInfoResponse? = nil
    override var accountInfo: AccountInfoResponse? {
        get { accountInfoMocked }
        set { accountInfoMocked = newValue }
    }
    var customerInfoMocked: CustomerInfoResponse? = nil
    override var customerInfo: CustomerInfoResponse? {
        get { customerInfoMocked }
        set { customerInfoMocked = newValue }
    }
    
    override var loggedIn: Bool {
        get {
            accountInfo != nil
        }
        set {}
    }
    
    
    override init() {
    }
    
    init(persistanceCtx: NSManagedObjectContext) {
        self.persistanceCtx = persistanceCtx
    }
    
    override func waitForRefresh() async throws {
    }
    
    override func refreshData() async throws {
        try! refreshDataLocal()
    }
    
    override func refreshDataBackend() async throws {
    }
    
    override func refreshDataLocal() throws {
        let fetchRequestCars = Car.fetchRequest()
        cars = try persistanceCtx.fetch(fetchRequestCars)
        let fetchRequestRentals = Rental.fetchRequest()
        rentals = try persistanceCtx.fetch(fetchRequestRentals)
        
    }
    
    override func login(username: String, password: String) async throws {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Car")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try! persistanceCtx.execute(batchDeleteRequest)
        
        let accResp: AccountInfoResponse = AccountInfoResponse(id: 0, login: username, firstName: "John", lastName: "Doe", email: "johndoe@mail.com", imageURL: nil, activated: true, langKey: nil, createdBy: nil, createdDate: nil, lastModifiedBy: nil, lastModifiedDate: nil, authorities: [])
        let custResp: CustomerInfoResponse = CustomerInfoResponse(id: 0, nr: 0, lastName: "Doe", firstName: "John")
        accountInfo = accResp
        customerInfo = custResp
        
        try await refreshData()
    }
    
   override func register(username: String, password: String, firstName: String, lastName: String, email: String) async throws {
    }
    
    override func requestPasswordReset(email: String) async throws {
    }
    
   override func completePasswordReset(url: URL, newPassword: String) async throws {
        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            throw URLError(.badURL)
        }
        
        guard let key = queryItems.first(where: { $0.name == "key" })?.value else {
            throw URLError(.badURL)
        }
    }
    
   override func activateAccount(url: URL) async throws {
        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            throw URLError(.badURL)
        }
        
        guard let key = queryItems.first(where: { $0.name == "key" })?.value else {
            throw URLError(.badURL)
        }
    }
    
    override func rentCar(car: Car, date: Date) async throws {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        let rental = Rental(context: persistanceCtx)
        rental.from = date
        rental.to = date
        rental.backendId = Int64(rental.id.hashValue)
        rental.state = "ACTIVE"
        rental.car = car.backendId
        rental.latitude = car.latitude
        rental.longitude = car.longitude
        try persistanceCtx.save()
        try refreshDataLocal()
    }
    
   override func stopRental(rental: Rental) async throws {
        rental.state = "RETURNED"
        try persistanceCtx.save()
        try refreshDataLocal()
    }
    
   override func damageReport(rental: Rental, description: String, image: Data) async throws {
   }
    
   override func logout() {
        accountInfo = nil
        customerInfo = nil
    }
}
