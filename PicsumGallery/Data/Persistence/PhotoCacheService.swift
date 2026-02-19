import Foundation
import OSLog
import SwiftData

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "PicsumGallery", category: "PhotoCache")

/// Protocol for persisting and loading Picsum photos (e.g. SwiftData-backed cache).
protocol PhotoCacheServiceProtocol {
    func save(_ photos: [PicsumPhoto])
    func load(limit: Int) -> [PicsumPhoto]
    func exists(id: String) -> Bool
    func clearOld() async
    func clearAll()
}

/// SwiftData-backed cache for Picsum photos with TTL; logs errors and keeps recent entries.
@Observable
@MainActor
final class PhotoCacheService: PhotoCacheServiceProtocol {
    private let modelContext: ModelContext
    private let cacheTTL: TimeInterval = 7 * 24 * 60 * 60
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Upserts photos into the cache (update existing by id, insert new) and triggers cleanup of old entries.
    func save(_ photos: [PicsumPhoto]) {
        guard !photos.isEmpty else { return }

        let ids = photos.map(\.id.value)
        let descriptor = FetchDescriptor<PicsumPhotoCache>(
            predicate: #Predicate<PicsumPhotoCache> { ids.contains($0.id) }
        )

        let existingById: [String: PicsumPhotoCache]
        do {
            let existing = try modelContext.fetch(descriptor)
            existingById = Dictionary(uniqueKeysWithValues: existing.map { ($0.id, $0) })
        } catch {
            logger.error("Cache save: batch fetch failed: \(error)")
            existingById = [:]
        }

        let now = Date()
        for photo in photos {
            if let existing = existingById[photo.id.value] {
                existing.author = photo.author
                existing.width = photo.width
                existing.height = photo.height
                existing.url = photo.url
                existing.downloadUrl = photo.downloadUrl.absoluteString
                existing.cachedAt = now
            } else {
                modelContext.insert(PicsumPhotoCache.from(photo))
            }
        }

        do {
            try modelContext.save()
        } catch {
            logger.error("Cache save: save failed: \(error)")
        }

        Task {
            await clearOld()
        }
    }

    /// Returns up to `limit` most recently cached photos, or empty array on fetch error.
    func load(limit: Int = 20) -> [PicsumPhoto] {
        var descriptor = FetchDescriptor<PicsumPhotoCache>(
            sortBy: [SortDescriptor(\.cachedAt, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        
        let cached: [PicsumPhotoCache]
        do {
            cached = try modelContext.fetch(descriptor)
        } catch {
            logger.error("Cache load: fetch failed: \(error)")
            return []
        }
        
        return cached.map { $0.toPicsumPhoto() }
    }

    /// Returns whether a cached entry exists for the given photo id.
    func exists(id: String) -> Bool {
        var descriptor = FetchDescriptor<PicsumPhotoCache>(
            predicate: #Predicate<PicsumPhotoCache> { $0.id == id }
        )
        descriptor.fetchLimit = 1
        
        let count: Int
        do {
            count = try modelContext.fetchCount(descriptor)
        } catch {
            logger.error("Cache exists: fetchCount failed: \(error)")
            return false
        }
        
        return count > 0
    }

    /// Removes cache entries older than TTL (e.g. 7 days).
    func clearOld() async {
        let cutoffDate = Date().addingTimeInterval(-cacheTTL)
        let descriptor = FetchDescriptor<PicsumPhotoCache>(
            predicate: #Predicate<PicsumPhotoCache> { $0.cachedAt < cutoffDate }
        )
        
        let oldEntries: [PicsumPhotoCache]
        do {
            oldEntries = try modelContext.fetch(descriptor)
        } catch {
            logger.error("Cache clearOld: fetch failed: \(error)")
            return
        }

        for entry in oldEntries {
            modelContext.delete(entry)
        }

        do {
            try modelContext.save()
        } catch {
            logger.error("Cache clearOld: save failed: \(error)")
        }
    }

    /// Deletes all cached entries (e.g. for logout or reset).
    func clearAll() {
        do {
            try modelContext.delete(model: PicsumPhotoCache.self)
            try modelContext.save()
        } catch {
            logger.error("Cache clearAll: delete failed: \(error)")
        }
    }
}
