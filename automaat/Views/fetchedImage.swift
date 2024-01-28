import SwiftUI

enum ImageFetchMode {
    case Query
    case Car
    case CarFront
    case BrandLogo
}

/*
    Fetches an image from the imagefetcher and displays it.
    Displays a progress bar while loading.
*/

struct FetchedImage: View {
    @EnvironmentObject var imageFetcher: ImageFetcher
    @Namespace var namespace
    var query: String = ""
    var preset: ImageFetchMode = .Query
    var car: Car? = nil
    var cache = true
    var sortUrls = false
    @State var imageNonBinding: Data? = nil
    @Binding var loadedImage: Data?

    init(query: String = "",
         preset: ImageFetchMode,
         car: Car? = nil,
         cache: Bool = true,
         sortUrls: Bool = false,
         animation: Namespace.ID? = nil,
         animationName: String = "fetchedImage",
         loadedImage: Binding<Data?> = .constant(nil)
    ) {
        self.query = query
        self.preset = preset
        self.car = car
        self.cache = cache
        self.sortUrls = sortUrls
        _loadedImage = loadedImage
    }
    
    
    var body: some View {
        if loadedImage != nil || imageNonBinding != nil {
            Image(uiImage: UIImage(data: loadedImage ?? imageNonBinding!)!)
                .resizable()
                .scaledToFit()
        } else {
            ProgressView()
                .onAppear{
                    Task {
                        do {
                            switch preset {
                            case .Car:
                                imageNonBinding = await imageFetcher.fetchCarImage(car: car!, cache: cache)
                            case .CarFront:
                                imageNonBinding = await imageFetcher.fetchCarImage(car: car!, cache: cache, front: true)
                            case .BrandLogo:
                                imageNonBinding = await imageFetcher.fetchBrandLogo(brand: car!.brand!)
                            default:
                                imageNonBinding = await imageFetcher.getImage(query: query, cache: cache)
                            }
                            loadedImage = imageNonBinding
                        }
                    }
                }
        }
    }
}
