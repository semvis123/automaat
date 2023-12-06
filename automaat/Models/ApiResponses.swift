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
    var id, nr: Int
    var lastName, firstName, from: String
}

struct CarResponseElement: Codable {
    var id: Int?
    var brand, model: String?
    var fuel: Fuel?
    var options, licensePlate: String?
    var engineSize, modelYear: Int?
    var since: String?
    var price, nrOfSeats: Int?
    var body: CarBody?
    var longitude, latitude: Float?
    var inspections, repairs, rentals: [String]? // guessed
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
