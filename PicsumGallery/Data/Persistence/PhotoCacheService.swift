import Foundation
import SwiftData

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

            if let existing = try? modelContext.fetch(descriptor).first {
                existing.author = photo.author
                existing.width = photo.width
                existing.height = photo.height
                existing.url = photo.url
                existing.downloadUrl = photo.downloadUrl
                existing.cachedAt = Date()
            } else {
                modelContext.insert(PicsumPhotoCache.from(photo))
            }
        }

        try? modelContext.save()

        Task {
            await clearOld()
        }
    }
    
    func load(limit: Int = 20) -> [PicsumPhoto] {
        var descriptor = FetchDescriptor<PicsumPhotoCache>(
            sortBy: [SortDescriptor(\.cachedAt, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        
        guard let cached = try? modelContext.fetch(descriptor) else {
            return []
        }
        
        return cached.map { $0.toPicsumPhoto() }
    }
    
    func exists(id: String) -> Bool {
        var descriptor = FetchDescriptor<PicsumPhotoCache>(
            predicate: #Predicate<PicsumPhotoCache> { $0.id == id }
        )
        descriptor.fetchLimit = 1
        
        guard let count = try? modelContext.fetchCount(descriptor) else {
            return false
        }
        
        return count > 0
    }
    
    func clearOld() async {
        let cutoffDate = Date().addingTimeInterval(-cacheTTL)
        let descriptor = FetchDescriptor<PicsumPhotoCache>(
            predicate: #Predicate<PicsumPhotoCache> { $0.cachedAt < cutoffDate }
        )
        
        guard let oldEntries = try? modelContext.fetch(descriptor) else {
            return
        }
        
        for entry in oldEntries {
            modelContext.delete(entry)
        }
        
        try? modelContext.save()
    }
    
    func clearAll() {
        let descriptor = FetchDescriptor<PicsumPhotoCache>()
        
        guard let allEntries = try? modelContext.fetch(descriptor) else {
            return
        }
        
        for entry in allEntries {
            modelContext.delete(entry)
        }
        
        try? modelContext.save()
    }
}
