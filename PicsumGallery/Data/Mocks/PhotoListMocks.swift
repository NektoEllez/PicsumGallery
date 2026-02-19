import Foundation

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

final class MockPicsumAPIService: PicsumAPIServiceProtocol, Sendable {
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
