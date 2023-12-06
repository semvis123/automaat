import Foundation

// MARK: - ImageFetcherResponse
struct ImageFetcherResponse: Codable {
    let kind: String?
    let url: URLClass?
    let queries: Queries
    let context: ContextItem
    let searchInformation: SearchInformation
    let items: [ImageResponseItem]
}

// MARK: - Context
struct ContextItem: Codable {
    let title: String
}

// MARK: - Item
struct ImageResponseItem: Codable {
    let kind: String?
    let title, htmlTitle: String?
    let link: String
    let displayLink, snippet, htmlSnippet: String?
    let mime, fileFormat: String?
    let image: ImageResponseData
}

// MARK: - Image
struct ImageResponseData: Codable {
    let contextLink: String
    let height, width, byteSize: Int
    let thumbnailLink: String
    let thumbnailHeight, thumbnailWidth: Int
}

// MARK: - Queries
struct Queries: Codable {
    let request, nextPage: [NextPage]
}

// MARK: - NextPage
struct NextPage: Codable {
    let title, totalResults, searchTerms: String
    let count, startIndex: Int
    let inputEncoding, outputEncoding, safe, cx: String
    let fileType, searchType, imgColorType: String?
}

// MARK: - SearchInformation
struct SearchInformation: Codable {
    let searchTime: Double
    let formattedSearchTime, totalResults, formattedTotalResults: String
}

// MARK: - URLClass
struct URLClass: Codable {
    let type, template: String
}
