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
    /// Throttle for success toast: show at most once per this interval (e.g. pull-to-refresh spam → one toast).
    private let successToastThrottleInterval: TimeInterval = 4
    private var lastSuccessToastTime: Date?
    var toastStore: ToastStore?
    private var loadMoreTask: Task<Void, Never>?
    private var successToastTask: Task<Void, Never>?
    private var loadGeneration = 0

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
        loadGeneration += 1
        let generation = loadGeneration
        loadMoreTask?.cancel()
        loadMoreTask = nil

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
            guard generation == loadGeneration else { return }

            if photos != fetchedPhotos {
                photos = fetchedPhotos
            }
            
            cacheService.save(fetchedPhotos)
            hasMore = fetchedPhotos.count >= pageSize
            error = nil
            showSuccessToast()
        } catch {
            guard generation == loadGeneration else { return }
            if photos.isEmpty {
                _ = errorService.handle(error)
                self.error = APIServiceError.from(error)
            } else {
                _ = errorService.handle(error)
            }
        }
    }
    
    private func showSuccessToast() {
        let now = Date()
        if let last = lastSuccessToastTime, now.timeIntervalSince(last) < successToastThrottleInterval {
            return
        }
        lastSuccessToastTime = now

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
        let generation = loadGeneration
        loadMoreTask?.cancel()
        
        loadMoreTask = Task { @MainActor in
            do {
                try await Task.sleep(for: .seconds(throttleInterval))
            } catch {
                return // Cancelled — expected when user scrolls away quickly
            }
            guard !Task.isCancelled else { return }
            
            await performLoadMore(expectedGeneration: generation)
        }
    }
    
    private func performLoadMore(expectedGeneration: Int) async {
        guard expectedGeneration == loadGeneration else { return }
        guard !isLoadingMore && hasMore else { return }
        
        isLoadingMore = true
        defer { isLoadingMore = false }
        
        currentPage += 1
        
        do {
            let fetchedPhotos = try await apiService.fetchPhotos(page: currentPage, limit: pageSize)
            guard expectedGeneration == loadGeneration else { return }

            let existingIds = Set(photos.map { $0.id.value })
            let uniqueFetchedPhotos = fetchedPhotos.filter { !existingIds.contains($0.id.value) }
            photos.append(contentsOf: uniqueFetchedPhotos)
            cacheService.save(fetchedPhotos)
            hasMore = fetchedPhotos.count >= pageSize
            error = nil
        } catch {
            guard expectedGeneration == loadGeneration else { return }
            _ = errorService.handle(error)
            self.error = APIServiceError.from(error)
            currentPage -= 1
        }
    }

    func cancelPendingWork() {
        loadMoreTask?.cancel()
        loadMoreTask = nil
        successToastTask?.cancel()
        successToastTask = nil
    }
}
