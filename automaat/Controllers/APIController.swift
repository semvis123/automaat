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
    
    init() {
        loggedIn = accountInfo != nil && jwtToken != nil
    }
    
    func login(username: String, password: String) async throws {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Car")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try! PersistenceController.shared.container.viewContext.execute(batchDeleteRequest)

        let jwtResp: AuthenticateResponse = try await postData(endpoint: "authenticate", data: [
            "rememberMe": "true",
            "username": username,
            "password": password
        ], auth: false)
        
        jwtToken = jwtResp.idToken
        let accResp: AccountInfoResponse = try await getData(endpoint: "account")
        let custResp: CustomerInfoResponse = try await getData(endpoint: "customers/\(accResp.id)", queryData: [:])
        accountInfo = accResp
        customerInfo = custResp
        
        print(try! await getCars())
    }
    
    func getCars() async throws -> CarListResponse {
        let carList: CarListResponse = try await getData(endpoint: "cars")
        let ctx = PersistenceController.shared.container.viewContext;
        for car in carList {
            let c = Car(context: ctx)
            c.brand = car.brand
            c.fuel = car.fuel?.rawValue
            c.licenseplate = car.licensePlate
            c.model = car.model
            c.options = car.options
            c.price = NSDecimalNumber(value: car.price!)
            c.longitude = NSDecimalNumber(value: car.longitude!)
            c.latitude = NSDecimalNumber(value: car.latitude!)
        }
        try ctx.save()
        return carList
    }
    
    func logout() {
        jwtToken = nil
        accountInfo = nil
        customerInfo = nil
    }
    
    private func postData<T: Decodable>(endpoint: String, data: [String : Any], auth: Bool = true) async throws -> T {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        var request = URLRequest(url: URL(string: API_ROOT + endpoint)!)
        request.httpMethod = "POST"
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        if auth && jwtToken != nil {
            request.addValue("Bearer \(jwtToken!)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = try! JSONSerialization.data(withJSONObject: data, options: [])
        
        let (data, _) = try await session.data(for: request)
        let obj = try JSONDecoder().decode(T.self, from: data)
        return obj
    }
    
    private func getData<T: Decodable>(endpoint: String, queryData: [String : String] = [:], auth: Bool = true) async throws -> T {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        var url = URL(string: API_ROOT + endpoint)!
        url = url.appendingQueryParameters(queryData)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        if auth && jwtToken != nil {
            request.addValue("Bearer \(jwtToken!)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, _) = try await session.data(for: request)
        let obj = try JSONDecoder().decode(T.self, from: data)
        return obj
    }
    
}
