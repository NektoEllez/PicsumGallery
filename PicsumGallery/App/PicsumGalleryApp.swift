import SwiftUI
import SwiftData

@main
struct PicsumGalleryApp: App {
    init() {
        configureURLCache()
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            PicsumPhotoCache.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RouterView()
        }
        .modelContainer(sharedModelContainer)
    }
    
    private func configureURLCache() {
        let memoryCapacity = 50 * 1024 * 1024
        let diskCapacity = 200 * 1024 * 1024
        
        URLCache.shared = URLCache(
            memoryCapacity: memoryCapacity,
            diskCapacity: diskCapacity,
            diskPath: "picsum_gallery_cache"
        )
    }
}
