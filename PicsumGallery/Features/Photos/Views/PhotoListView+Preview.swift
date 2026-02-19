import SwiftUI

extension PhotoListView {
    static var mockPhotos: [PicsumPhoto] {
        [
            URL(string: "https://picsum.photos/id/1/1920/1080"),
            URL(string: "https://picsum.photos/id/2/1080/1920"),
            URL(string: "https://picsum.photos/id/3/800/800"),
            URL(string: "https://picsum.photos/id/4/2560/1440"),
            URL(string: "https://picsum.photos/id/5/1200/800")
        ].compactMap { $0 }.enumerated().map { index, url in
            let authors = ["John Doe", "Jane Smith", "Bob Johnson", "Alice Williams", "Charlie Brown"]
            let dimensions = [(1920, 1080), (1080, 1920), (800, 800), (2560, 1440), (1200, 800)]
            let (width, height) = dimensions[index]
            
            return PicsumPhoto(
                id: PicsumPhotoID(value: "\(index + 1)"),
                author: authors[index],
                width: width,
                height: height,
                url: url,
                downloadUrl: URL(string: "https://picsum.photos/id/\(index + 1)/200/200") ?? url
            )
        }
    }
    
    static var mockCacheService: PhotoCacheServiceProtocol {
        MockPhotoCacheService(prefilledPhotos: mockPhotos)
    }
    
    static var mockAPIService: PicsumAPIServiceProtocol {
        MockPicsumAPIService()
    }
    
    static var mockErrorService: ErrorService {
        ErrorService()
    }
}
