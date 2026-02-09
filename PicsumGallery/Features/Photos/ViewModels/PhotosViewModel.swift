import SwiftUI

@Observable
@MainActor
final class PhotosViewModel {
    var photos: [PicsumPhoto] = []
    var isLoading = false
    var isLoadingMore = false
    var error: APIServiceError?
    var hasMore = true
    
    private let apiService: PicsumAPIServiceProtocol
    private let errorService: ErrorService
    private let cacheService: PhotoCacheServiceProtocol
    private weak var localizer: Localizing?
    private var currentPage = 1
    private let pageSize = 20
    
    private let throttleInterval: TimeInterval = 0.5
    var toastStore: ToastStore?
    
    private var loadMoreTask: Task<Void, Never>? {
        get { _loadMoreTask }
        set { _loadMoreTask = newValue }
    }
    
    private var successToastTask: Task<Void, Never>? {
        get { _successToastTask }
        set { _successToastTask = newValue }
    }
    
    nonisolated(unsafe) private var _loadMoreTask: Task<Void, Never>?
    nonisolated(unsafe) private var _successToastTask: Task<Void, Never>?
    
    nonisolated(unsafe) deinit {
        _loadMoreTask?.cancel()
        _successToastTask?.cancel()
    }

    init(
        apiService: PicsumAPIServiceProtocol,
        errorService: ErrorService,
        cacheService: PhotoCacheServiceProtocol,
        localizer: Localizing? = nil
    ) {
        self.apiService = apiService
        self.errorService = errorService
        self.cacheService = cacheService
        self.localizer = localizer
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        
        currentPage = 1
        hasMore = true
        
        let cachedPhotos = cacheService.load(limit: pageSize)
        if !cachedPhotos.isEmpty && photos.isEmpty {
            photos = cachedPhotos
            error = nil
        }
        
        do {
            let fetchedPhotos = try await apiService.fetchPhotos(page: currentPage, limit: pageSize)
            
            let oldPhotoIds = Set(photos.map { $0.id.value })
            let newPhotoIds = Set(fetchedPhotos.map { $0.id.value })
            
            if oldPhotoIds != newPhotoIds {
                photos = fetchedPhotos
            }
            
            cacheService.save(fetchedPhotos)
            hasMore = fetchedPhotos.count >= pageSize
            error = nil
            
            if oldPhotoIds != newPhotoIds {
                showSuccessToast()
            }
        } catch {
            if photos.isEmpty {
                _ = errorService.handle(error)
                if let apiError = error as? APIServiceError {
                    self.error = apiError
                }
            } else {
                _ = errorService.handle(error)
            }
        }
    }
    
    private func showSuccessToast() {
        successToastTask?.cancel()
        
        successToastTask = Task { @MainActor in
            do {
                try await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                
                let text = localizer?.string(.photosUpdated) ?? "Photos updated"
                let message = ToastMessage(
                    text: text,
                    icon: "checkmark.circle.fill",
                    style: .success
                )
                toastStore?.show(message, autoDismissAfter: 2)
            } catch {
                // Task cancelled
            }
        }
    }
    
    func loadMore() {
        loadMoreTask?.cancel()
        
        loadMoreTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(throttleInterval))
            guard !Task.isCancelled else { return }
            
            await performLoadMore()
        }
    }
    
    private func performLoadMore() async {
        guard !isLoadingMore && hasMore else { return }
        
        isLoadingMore = true
        defer { isLoadingMore = false }
        
        currentPage += 1
        
        do {
            let fetchedPhotos = try await apiService.fetchPhotos(page: currentPage, limit: pageSize)
            
            photos.append(contentsOf: fetchedPhotos)
            cacheService.save(fetchedPhotos)
            hasMore = fetchedPhotos.count >= pageSize
            error = nil
        } catch {
            _ = errorService.handle(error)
            if let apiError = error as? APIServiceError {
                self.error = apiError
            }
            currentPage -= 1
        }
    }
}
