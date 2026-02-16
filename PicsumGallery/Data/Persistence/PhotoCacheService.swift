import Foundation
import OSLog
import SwiftData

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "PicsumGallery", category: "PhotoCache")

protocol PhotoCacheServiceProtocol {
    func save(_ photos: [PicsumPhoto])
    func load(limit: Int) -> [PicsumPhoto]
    func exists(id: String) -> Bool
    func clearOld() async
    func clearAll()
}

@Observable
@MainActor
final class PhotoCacheService: PhotoCacheServiceProtocol {
    private let modelContext: ModelContext
    private let cacheTTL: TimeInterval = 7 * 24 * 60 * 60
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func save(_ photos: [PicsumPhoto]) {
        for photo in photos {
            let id = photo.id.value
            var descriptor = FetchDescriptor<PicsumPhotoCache>(
                predicate: #Predicate<PicsumPhotoCache> { $0.id == id }
            )
            descriptor.fetchLimit = 1

            do {
                if let existing = try modelContext.fetch(descriptor).first {
                    existing.author = photo.author
                    existing.width = photo.width
                    existing.height = photo.height
                    existing.url = photo.url
                    existing.downloadUrl = photo.downloadUrl
                    existing.cachedAt = Date()
                } else {
                    modelContext.insert(PicsumPhotoCache.from(photo))
                }
            } catch {
                logger.error("Cache save: fetch failed for id \(photo.id.value): \(error)")
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
    
    func clearAll() {
        let descriptor = FetchDescriptor<PicsumPhotoCache>()
        
        let allEntries: [PicsumPhotoCache]
        do {
            allEntries = try modelContext.fetch(descriptor)
        } catch {
            logger.error("Cache clearAll: fetch failed: \(error)")
            return
        }

        for entry in allEntries {
            modelContext.delete(entry)
        }

        do {
            try modelContext.save()
        } catch {
            logger.error("Cache clearAll: save failed: \(error)")
        }
    }
}
