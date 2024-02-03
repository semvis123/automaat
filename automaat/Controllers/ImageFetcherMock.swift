import Foundation
import UIKit
import CoreData

class ImageFetcherMock: ImageFetcher {
    override func getImage(query: String, cache: Bool, positive: [String] = [], negative: [String] = []) async -> Data {
        let fallbackImage = UIImage(systemName: "car.fill", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 200.0)))!.withTintColor(.white).pngData()!
        return fallbackImage
    }
    
    override func fetchCarImage(car: Car, cache: Bool = true) async -> Data {
        return await getImage(query: "", cache: false)
    }
    
    override func fetchCarImage(car: Car, cache: Bool = true, front: Bool = false, positive: [String] = [], negative: [String] = []) async -> Data {
        return await getImage(query: "", cache: false)
    }
    
    override func fetchBrandLogo(brand: String) async ->  Data {
        return await getImage(query: "", cache: false)
    }
}

