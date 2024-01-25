import Foundation
import CoreData


class APIController: ObservableObject {
    let API_ROOT = "https://helped-clean-bream.ngrok-free.app/api/"
    
    @SecureStorage("jwtToken")
    private var jwtToken: String? = nil {
        didSet {
            loggedIn = accountInfo != nil && jwtToken != nil
        }
    }
    
    @SecureStorage("accountInfo")
    var accountInfo: AccountInfoResponse? = nil {
        didSet {
            loggedIn = accountInfo != nil && jwtToken != nil
        }
    }
    
    @SecureStorage("customerInfo")
    var customerInfo: CustomerInfoResponse? = nil
    
    @Published
    var loggedIn = false
    @Published
    var rentals: [Rental] = []
    @Published
    var cars: [Car] = []
    var refreshSemaphore = Semaphore(count: 1)
    
    init() {
        loggedIn = accountInfo != nil && jwtToken != nil
    }

    func waitForRefresh() async throws {
        await refreshSemaphore.wait()
        await refreshSemaphore.release()
    }
    
    func refreshData() async throws {
        await refreshSemaphore.wait()
        do {
            try refreshDataLocal()
            try await refreshDataBackend()
        } catch {
            // offline or backend error, ignore
        }
        // ensure the properties are up to date
        do {
            try refreshDataLocal()
            await refreshSemaphore.release()
        } catch {
            await refreshSemaphore.release()
            throw error
        }
    }
    
    func refreshDataBackend() async throws {
        let ctx = PersistenceController.shared.container.viewContext;

        if loggedIn {
            let rentalResponse: [RentalsResponseElement] = try await getData(endpoint: "rentals", queryData: [
                "customerId.equals": "\(customerInfo!.id!)"
            ])
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale.autoupdatingCurrent
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = "yyyy-MM-dd"
            try ctx.deleteAll(entity: "Rental")

            print("got \(rentalResponse.count) rentals")
            for rentalEl in rentalResponse {
                if rentalEl.car == nil {
                    // don't polute our database with fake entries
                    continue
                }
                let rental = Rental(context: ctx)
                rental.from = dateFormatter.date(from: rentalEl.fromDate)
                rental.to = dateFormatter.date(from: rentalEl.toDate)
                rental.backendId = rentalEl.id
                rental.car = (rentalEl.car?.id)!
                rental.state = rentalEl.state
                rental.latitude = NSDecimalNumber(value: rentalEl.latitude)
                rental.longitude = NSDecimalNumber(value: rentalEl.longitude)
            }

            try ctx.save()
        }

        // create list of favorites such that we won't delete them
        var favorites: [Int64] = []
        for car in cars {
            if car.favorite {
                favorites.append(car.backendId)
            }
        }
                
        let carList: CarListResponse = try await getData(endpoint: "cars")
        try ctx.deleteAll(entity: "Car")

        for car in carList {
            let c = Car(context: ctx)
            c.backendId = car.id
            c.brand = car.brand
            c.fuel = car.fuel?.rawValue
            c.licenseplate = car.licensePlate
            c.model = car.model
            c.options = car.options
            c.price = car.price!
            c.longitude = NSDecimalNumber(value: car.longitude!)
            c.latitude = NSDecimalNumber(value: car.latitude!)
            c.favorite = favorites.contains(car.id)
        }
        try ctx.save()
    }
    
    func refreshDataLocal() throws {
        let ctx = PersistenceController.shared.container.viewContext
    
        let fetchRequestCars = Car.fetchRequest()
        cars = try ctx.fetch(fetchRequestCars)
        let fetchRequestRentals = Rental.fetchRequest()
        rentals = try ctx.fetch(fetchRequestRentals)
        
    }
    
    func login(username: String, password: String) async throws {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Car")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try! PersistenceController.shared.container.viewContext.execute(batchDeleteRequest)
        
        let jwtResp: AuthenticateResponse = try await postData(endpoint: "authenticate", data: [
            "rememberMe": "true",
            "username": username,
            "password": password,
        ], auth: false)
        
        jwtToken = jwtResp.idToken
        let accResp: AccountInfoResponse = try await getData(endpoint: "account")
        let custResp: CustomerInfoResponse = try await getData(endpoint: "AM/me")
        accountInfo = accResp
        customerInfo = custResp
        
        try await refreshData()
    }

    func register(username: String, password: String, firstName: String, lastName: String, email: String) async throws {
        try await postData(endpoint: "AM/register", data: [
            "login": username,
            "password": password,
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
//            "activated": true,
            "langKey": "nl",
            "authorities": ["ROLE_USER"]
        ], auth: false)
    }
    
    func requestPasswordReset(email: String) async throws {
        let response = try await postRawData(endpoint: "account/reset-password/init", data: email)
        
        if response.contains("Bad Request") {
            throw URLError(.badServerResponse)
        }
    }

    func completePasswordReset(url: URL, newPassword: String) async throws {
        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            throw URLError(.badURL)
        }

        guard let key = queryItems.first(where: { $0.name == "key" })?.value else {
            throw URLError(.badURL)
        }

        let _ = try await postData(endpoint: "account/reset-password/finish", data: [
            "key": key,
            "newPassword": newPassword
        ])
    }

    func activateAccount(url: URL) async throws {
        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            throw URLError(.badURL)
        }

        guard let key = queryItems.first(where: { $0.name == "key" })?.value else {
            throw URLError(.badURL)
        }

        try await getData(endpoint: "activate", queryData: [
            "key": key
        ], auth: false)
    }
    
    func rentCar(car: Car, date: Date) async throws {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        let response: RentalsResponseElement = try await postData(endpoint: "rentals", data: [
            "fromDate": dateString,
            "toDate": dateString,
            "latitude": car.latitude!.doubleValue,
            "longitude": car.longitude!.doubleValue,
            "state": "ACTIVE",
            "car": [
                "id": car.backendId
            ]
        ])
        let ctx = PersistenceController.shared.container.viewContext
        let rental = Rental(context: ctx)
        rental.from = date
        rental.to = date
        rental.backendId = response.id
        rental.state = "ACTIVE"
        rental.car = car.backendId
        rental.latitude = car.latitude
        rental.longitude = car.longitude
        try ctx.save()
        try refreshDataLocal()
    }
    
    func stopRental(rental: Rental) async throws {
        let ctx = PersistenceController.shared.container.viewContext
        rental.state = "RETURNED"
        try await patchData(endpoint: "rentals/\(rental.backendId)", data: [
            "id": rental.backendId,
            "state": "RETURNED"
        ])

        try ctx.save()
        try refreshDataLocal()
    }

    func damageReport(rental: Rental, description: String, image: Data) async throws {
        let imageString = image.base64EncodedString()
        try await postData(endpoint: "inspections", data: [
            "result": description,
            "rental": [
                "id": rental.backendId
            ],
            "car": [
                "id": rental.car
            ],
            "photo": imageString
        ])
    }
    
    func logout() {
        jwtToken = nil
        accountInfo = nil
        customerInfo = nil
    }

    private func createSession() -> URLSession {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        return session
    }

    private func createRequest(endpoint: String, method: String, data: Data? = nil, auth: Bool = true, queryData: [String : String] = [:]) -> URLRequest {
        var url = URL(string: API_ROOT + endpoint)!
        url = url.appendingQueryParameters(queryData)

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        if auth && jwtToken != nil {
            request.addValue("Bearer \(jwtToken!)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = data
        return request
    }
    
    
    private func postData<T: Decodable>(endpoint: String, data: [String : Any], auth: Bool = true) async throws -> T {
        let request = createRequest(endpoint: endpoint, method: "POST", data: try JSONSerialization.data(withJSONObject: data), auth: auth)

        let (data, _) = try await createSession().data(for: request)
        let obj = try JSONDecoder().decode(T.self, from: data)
        return obj
    }

    private func postData(endpoint: String, data: [String : Any], auth: Bool = true) async throws {
        let request = createRequest(endpoint: endpoint, method: "POST", data: try JSONSerialization.data(withJSONObject: data), auth: auth)

        let (_, _) = try await createSession().data(for: request)
    }

    private func postRawData(endpoint: String, data: String, auth: Bool = true) async throws -> String {
        let request = createRequest(endpoint: endpoint, method: "POST", data: data.data(using: .utf8), auth: auth)
        
        let (data, _) = try await createSession().data(for: request)
        return String(data: data, encoding: .utf8)!
    }    
    
    private func getData<T: Decodable>(endpoint: String, queryData: [String : String] = [:], auth: Bool = true) async throws -> T {
        let request = createRequest(endpoint: endpoint, method: "GET", auth: auth, queryData: queryData)
        
        let (data, _) = try await createSession().data(for: request)
        let obj = try JSONDecoder().decode(T.self, from: data)
        return obj
    }
    private func getData(endpoint: String, queryData: [String : String] = [:], auth: Bool = true) async throws {
        let request = createRequest(endpoint: endpoint, method: "GET", auth: auth, queryData: queryData)
        
        let (_, _) = try await createSession().data(for: request)
    }

    private func patchData(endpoint: String, data: [String : Any], auth: Bool = true) async throws {
        let request = createRequest(endpoint: endpoint, method: "PATCH", data: try JSONSerialization.data(withJSONObject: data), auth: auth)

        let (_, _) = try await createSession().data(for: request)
    }

}
