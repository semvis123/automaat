import Foundation
import UIKit
import CoreData

enum ImageFetchingError: Error {
    case API_ERROR
}

class ImageFetcher: ObservableObject {

    // NOTE: This api key has been revoked, replace before actual usage.
    // Normally you do this server-side, but for this project it is fine.
    let API_URL = "https://customsearch.googleapis.com/customsearch/v1"
    let API_KEY = "AIzaSyDSLLmKNRoeVs1-0B5soQD9L52Uoi7_EN8"
    let API_ID = "e6f6b09c0a11944db"
    
    let semaphoreMapSemaphore = Semaphore()
    var semaphores: [String: Semaphore] = [:]
    
    private func getImageUrls(query: String) async throws -> [String] {
        let sessionConfig = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        guard var url = URL(string: API_URL) else {throw ImageFetchingError.API_ERROR}
        let URLParams = [
            "key": API_KEY,
            "q": query,
            "imgColorType": "trans",
            "cx": API_ID,
            "gl": "nl",
            "searchType": "image",
        ]
        url = url.appendingQueryParameters(URLParams)
        
        do {
            let (data, _) = try await session.data(from: url)
            
            let decoder = JSONDecoder()
            let resp = try decoder.decode(ImageFetcherResponse.self, from: data)
            print(resp.items)
            return resp.items.map { $0.link }
        } catch {
            print("Error info: \(error)")
            throw ImageFetchingError.API_ERROR
        }
    }
    
    private func urlScore(url: String, query: String, positive: [String] = [], negative: [String] = []) -> Int {
        var score = 0
        let lUrl = url.lowercased()
        for keyword in positive {
            score += lUrl.contains(keyword) ? 5 : 0
        }
        
        for keyword in negative {
            score -= lUrl.contains(keyword) ? 2 : 0
        }
        
        if lUrl.contains(query.split(separator: " ")[0].lowercased()) {
            score += 2
        }
        
        return score
    }
    
    
    private func sortUrls(urls: [String], query: String, positive: [String] = [], negative: [String] = []) -> [String] {
        return urls.sorted {
            return self.urlScore(url: $0, query: query, positive: positive) > self.urlScore(url: $1, query: query, negative: negative)
        }
    }
    
    func getImage(query: String, cache: Bool, positive: [String] = [], negative: [String] = [], skipN: Int = 0) async -> Data {
        
        // only fetch the query once, let the other threads wait
        await semaphoreMapSemaphore.wait()
        var querySemaphore = semaphores[query]
        if querySemaphore == nil {
            semaphores[query] = Semaphore()
            querySemaphore = semaphores[query]!
        }
        guard let querySemaphore = querySemaphore else {
            fatalError()
        }
        
        await semaphoreMapSemaphore.release()
        await querySemaphore.wait()
        
        let vCtx = PersistenceController.shared.container.viewContext
        let request = ImageCache.fetchRequest()
        request.predicate = NSPredicate(
            format: "query = %@", query
        )
        request.fetchLimit = 1
        
        
        let entry = try? vCtx.fetch(request)
        if entry != nil && entry!.count > 0 && entry![0].imageBlob != nil && cache {
            await querySemaphore.release()
            return entry![0].imageBlob!
        }
        
        let fallbackImage = UIImage(systemName: "exclamationmark.triangle.fill", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 200.0)))!.withTintColor(.white).pngData()!
        
        guard var urls = try? await getImageUrls(query: query) else {
            await querySemaphore.release()
            return fallbackImage
        }
        
        if positive.count != 0 || negative.count != 0 {
            urls = sortUrls(urls: urls, query: query, positive: positive, negative: negative)
        }
        
        var toSkip = skipN
        for url in urls {
            guard let data = try? Data(contentsOf: URL(string: url)!) else {
                continue
            }
            guard let cleanData = UIImage(data: data)?.trimmingTransparentPixels()?.pngData() else {
                continue
            }
            
            if toSkip != 0 {
                toSkip -= 1
                continue
            }

            // delete old cache entries
            if entry != nil && entry!.count > 0 {
                for e in entry! {
                    vCtx.delete(e)
                }
            }
            
            let cacheEntry = ImageCache(context: vCtx)
            cacheEntry.imageBlob = cleanData
            cacheEntry.query = query
            try? vCtx.save()
            
            await querySemaphore.release()
            return cleanData
        }
        
        await querySemaphore.release()
        return fallbackImage
    }
    
    func fetchCarImage(car: Car, cache: Bool = true, skipN: Int = 0) async -> Data {
        let positive = ["vehicle", "dealer", ".com", "stock", "front", "images", "assets", "file", "resources", "carsized"]
        let negative = ["part", "repair", "shop", "clutch", "products", "http://"]
        return await fetchCarImage(car: car, cache: cache, front: false, positive: positive, negative: negative, skipN: skipN)
    }
    
    func fetchCarImage(car: Car, cache: Bool = true, front: Bool = false, positive: [String] = [], negative: [String] = [], skipN: Int = 0) async -> Data {
        return await getImage(query: "\(car.brand ?? "") \(car.model ?? "")\(front ? " front view" : "")", cache: cache, skipN: skipN)
    }
    
    func fetchBrandLogo(brand: String, cache: Bool = true, skipN: Int = 0) async ->  Data {
        let positive = ["Subaru-Logo-White-Transparent-BG-Web-Res.png?ssl=1", "dealers-honda-logo-png-white.png", "nissan-logo-2020-white.png", "Audi-Logo-White-Transparent-BG-Web-Res.png?ssl=1"]
        let negative: [String] = []
        
        return await getImage(query: "\"\(brand) logo\" inurl:white transparent -color", cache: cache, positive: positive, negative: negative, skipN: skipN)
    }
}

