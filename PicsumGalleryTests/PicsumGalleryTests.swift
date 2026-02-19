import Foundation
import Testing
@testable import PicsumGallery

struct PicsumGalleryTests {

    @MainActor
    @Test func loadUsesFreshDataFromAPI() async throws {
        let cachedPhoto = makePhoto(id: 99)
        let apiPhotos = [makePhoto(id: 1), makePhoto(id: 2)]
        let api = TestAPIService(pages: [1: apiPhotos])
        let cache = TestCacheService(initial: [cachedPhoto])
        let vm = PhotosViewModel(
            apiService: api,
            errorService: ErrorService(),
            cacheService: cache
        )

        await vm.load()

        #expect(vm.photos == apiPhotos)
        #expect(vm.hasMore == false)
        if case .some = vm.error {
            Issue.record("Expected no error after successful load")
        }
    }

    @MainActor
    @Test func loadMoreSkipsDuplicateIDs() async throws {
        let page1 = [makePhoto(id: 1), makePhoto(id: 2)]
        let page2 = [makePhoto(id: 2), makePhoto(id: 3)]
        let api = TestAPIService(pages: [1: page1, 2: page2])
        let vm = PhotosViewModel(
            apiService: api,
            errorService: ErrorService(),
            cacheService: TestCacheService()
        )

        await vm.load()
        vm.loadMore()
        let expectedIDs = ["1", "2", "3"]
        let timeout = ContinuousClock.now.advanced(by: .seconds(2))
        while vm.photos.map(\.id.value) != expectedIDs && ContinuousClock.now < timeout {
            try await Task.sleep(for: .milliseconds(50))
        }

        #expect(vm.photos.map(\.id.value) == expectedIDs)
    }

    @Test func apiServiceErrorFromUnknownUsesMessage() {
        struct SampleError: LocalizedError {
            var errorDescription: String? { "sample failure" }
        }

        let mapped = APIServiceError.from(SampleError())

        switch mapped {
        case .unknown(let message):
            #expect(message == "sample failure")
        default:
            Issue.record("Expected .unknown(message:) mapping")
        }
    }
}

private func makePhoto(id: Int) -> PicsumPhoto {
    let url = URL(string: "https://picsum.photos/id/\(id)/200/200")!
    return PicsumPhoto(
        id: PicsumPhotoID(value: "\(id)"),
        author: "Author \(id)",
        width: 200,
        height: 200,
        url: url,
        downloadUrl: url
    )
}

private final class TestAPIService: PicsumAPIServiceProtocol {
    private let pages: [Int: [PicsumPhoto]]

    init(pages: [Int: [PicsumPhoto]]) {
        self.pages = pages
    }

    func fetchPhotos(page: Int, limit: Int) async throws -> [PicsumPhoto] {
        pages[page] ?? []
    }
}

private final class TestCacheService: PhotoCacheServiceProtocol {
    private var storage: [PicsumPhoto]

    init(initial: [PicsumPhoto] = []) {
        self.storage = initial
    }

    func save(_ photos: [PicsumPhoto]) {
        storage.append(contentsOf: photos)
    }

    func load(limit: Int) -> [PicsumPhoto] {
        Array(storage.prefix(limit))
    }

    func exists(id: String) -> Bool {
        storage.contains { $0.id.value == id }
    }

    func clearOld() async {}

    func clearAll() {
        storage.removeAll()
    }
}
