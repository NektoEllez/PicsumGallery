import SwiftUI

@Observable
@MainActor
final class PhotosViewModel {
    var photos: [PicsumPhoto] = []
    var isLoading = false
    var error: APIServiceError?

    private let apiService: PicsumAPIServiceProtocol
    private let errorService: ErrorService

    init(apiService: PicsumAPIService,
         errorService: ErrorService) {
        self.apiService = apiService
        self.errorService = errorService
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }

        do {
            photos = try await apiService.fetchPhotos(page: 1, limit: 20)
            error = nil
        } catch {
            _ = errorService.handle(error)
            if let apiError = error as? APIServiceError {
                self.error = apiError
            }
        }
    }
}
