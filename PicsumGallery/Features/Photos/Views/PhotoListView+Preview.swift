import SwiftUI
import SwiftData

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
                downloadUrl: "https://picsum.photos/id/\(index + 1)/200/200"
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

@MainActor
final class MockPhotoCacheService: PhotoCacheServiceProtocol {
    private var mockPhotos: [PicsumPhoto]
    
    init(prefilledPhotos: [PicsumPhoto] = []) {
        self.mockPhotos = prefilledPhotos
    }
    
    func save(_ photos: [PicsumPhoto]) {
        mockPhotos.append(contentsOf: photos)
    }
    
    func load(limit: Int = 20) -> [PicsumPhoto] {
        Array(mockPhotos.prefix(limit))
    }
    
    func exists(id: String) -> Bool {
        mockPhotos.contains { $0.id.value == id }
    }
    
    func clearOld() async {}
    
    func clearAll() {
        mockPhotos.removeAll()
    }
}

final class MockPicsumAPIService: PicsumAPIServiceProtocol {
    func fetchPhotos(page: Int, limit: Int) async throws -> [PicsumPhoto] {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        let allMockPhotos = PhotoListView.mockPhotos
        let startIndex = (page - 1) * limit
        let endIndex = min(startIndex + limit, allMockPhotos.count)
        
        guard startIndex < allMockPhotos.count else {
            return []
        }
        
        return Array(allMockPhotos[startIndex..<endIndex])
    }
}
