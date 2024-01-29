import Foundation

struct AuthenticateResponse: Codable {
    let idToken: String

    enum CodingKeys: String, CodingKey {
        case idToken = "id_token"
    }
}

struct AccountInfoResponse: Codable {
    let id: Int
    let login, firstName, lastName, email: String?
    let imageURL: String?
    let activated: Bool
    let langKey, createdBy, createdDate, lastModifiedBy: String?
    let lastModifiedDate: String?
    let authorities: [String]

    enum CodingKeys: String, CodingKey {
        case id, login, firstName, lastName, email
        case imageURL = "imageUrl"
        case activated, langKey, createdBy, createdDate, lastModifiedBy, lastModifiedDate, authorities
    }
}

struct CustomerInfoResponse: Codable {
    var id, nr: Int?
    var lastName, firstName, from: String?
}

struct InspectionResponseElement: Codable {
    var id: Int
    var code: String?
    var odometer: Int?
    var result: String?
    var photo: String?
    var photoContentType: String?
    var photos: [String]?
    var repairs: [String]?
    var cars: [CarResponseElement]?
}

struct OptionalRepairResponse: Codable {
    var id: Int?
    var description: String?
    var repairStatus: String?
    var dateCompleted: String?
    var car: CarResponseElement?
    var employee: CustomerInfoResponse?
    var inspection: InspectionResponseElement?
}

struct CarResponseElement: Codable {
    var id: Int64
    var brand, model: String?
    var fuel: Fuel?
    var options, licensePlate: String?
    var engineSize, modelYear: Int?
    var since: String?
    var price, nrOfSeats: Int64?
    var body: CarBody?
    var longitude, latitude: Float?
    var inspections: [InspectionResponseElement]?
    var repairs: [OptionalRepairResponse]?
    var rentals: [OptionalRentalResponse]?
}

struct OptionalRentalResponse: Codable {
    var id: Int64
    var code: String?
    var longitude, latitude: Double?
    var fromDate, toDate: String?
    var state: String?
    var inspections: [InspectionResponseElement]?
    var customer : CustomerInfoResponse?
    var car: CarResponseElement?
}

struct RentalsResponseElement: Codable  {
    var id: Int64
    var code: String?
    var longitude, latitude: Double
    var fromDate, toDate: String
    var state: String?
    var inspections: [InspectionResponseElement]?
    var customer: CustomerInfoResponse?
    var car: CarResponseElement?
}

enum CarBody: String, Codable {
    case hatchback = "HATCHBACK"
    case sedan = "SEDAN"
    case stationwagon = "STATIONWAGON"
    case suv = "SUV"
    case truck = "TRUCK"
}

enum Fuel: String, Codable {
    case diesel = "DIESEL"
    case electric = "ELECTRIC"
    case gasoline = "GASOLINE"
    case hybrid = "HYBRID"
}

typealias CarListResponse = [CarResponseElement]
