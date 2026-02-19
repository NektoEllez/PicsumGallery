import SwiftUI
import SwiftData
import OSLog

@main
struct PicsumGalleryApp: App {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "PicsumGallery",
        category: "App"
    )

    init() {
        configureURLCache()
    }
    
    var sharedModelContainer: ModelContainer = Self.makeSharedModelContainer()

    private static func makeSharedModelContainer() -> ModelContainer {
        let schema = Schema([
            PicsumPhotoCache.self
        ])
        
        let diskConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        ensureApplicationSupportDirectoryExists()

        do {
            return try ModelContainer(for: schema, configurations: [diskConfiguration])
        } catch {
            let errorDescription = error.localizedDescription
            logger.error(
                "ModelContainer init failed. Resetting cache store: \(errorDescription, privacy: .public)"
            )
            removeDefaultStoreFiles()

            do {
                return try ModelContainer(for: schema, configurations: [diskConfiguration])
            } catch {
                let errorDescription = error.localizedDescription
                logger.error(
                    "ModelContainer recovery failed. Using memory store: \(errorDescription, privacy: .public)"
                )
                let memoryConfiguration = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: true
                )
                do {
                    return try ModelContainer(for: schema, configurations: [memoryConfiguration])
                } catch {
                    fatalError("Could not create ModelContainer: \(error)")
                }
            }
        }
    }

    private static func ensureApplicationSupportDirectoryExists() {
        let fileManager = FileManager.default
        guard let appSupportURL = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else {
            return
        }

        do {
            try fileManager.createDirectory(
                at: appSupportURL,
                withIntermediateDirectories: true
            )
        } catch {
            logger.error(
                "Failed to create Application Support directory. Error: \(error.localizedDescription, privacy: .public)"
            )
        }
    }

    private static func removeDefaultStoreFiles() {
        let fileManager = FileManager.default
        guard let appSupportURL = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else {
            return
        }

        let storeURL = appSupportURL.appendingPathComponent("default.store")
        let storeURLs = [
            storeURL,
            storeURL.appendingPathExtension("shm"),
            storeURL.appendingPathExtension("wal"),
            storeURL.appendingPathExtension("journal")
        ]

        for storeFileURL in storeURLs where fileManager.fileExists(atPath: storeFileURL.path) {
            do {
                try fileManager.removeItem(at: storeFileURL)
            } catch {
                let filename = storeFileURL.lastPathComponent
                let errorDescription = error.localizedDescription
                logger.error(
                    "Failed to remove \(filename, privacy: .public): \(errorDescription, privacy: .public)"
                )
            }
        }
    }

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
