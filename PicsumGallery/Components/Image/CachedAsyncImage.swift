import SwiftUI
import ImageIO

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    let targetSize: CGSize?
    @ViewBuilder let content: (Image) -> Content
    @ViewBuilder let placeholder: () -> Placeholder

    @State private var phase: AsyncImagePhase = .empty
    @State private var loadedURL: String?

    @Environment(\.displayScale) private var displayScale

    init(
        url: URL?,
        targetSize: CGSize? = nil,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.targetSize = targetSize
        self.content = content
        self.placeholder = placeholder
    }

    var body: some View {
        Group {
            switch phase {
            case .empty:
                placeholder()
            case .success(let image):
                content(image)
                    .id(url?.absoluteString)
            case .failure:
                placeholder()
            @unknown default:
                placeholder()
            }
        }
        .task(id: url?.absoluteString) {
            await reloadForCurrentURL()
        }
    }

    @MainActor
    private func reloadForCurrentURL() async {
        let currentURLString = url?.absoluteString
        if currentURLString == loadedURL, case .success = phase {
            return
        }
        phase = .empty
        await loadImage()
    }

    @MainActor
    private func loadImage() async {
        guard let url else {
            phase = .failure(URLError(.badURL))
            return
        }

        let request = URLRequest(url: url)

        if let cachedResponse = URLCache.shared.cachedResponse(for: request) {
            if let image = await decodeImage(from: cachedResponse.data, targetSize: targetSize, scale: displayScale) {
                guard !Task.isCancelled else { return }
                phase = .success(image)
                loadedURL = url.absoluteString
                return
            }
        }

        guard !Task.isCancelled else { return }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard !Task.isCancelled else { return }

            URLCache.shared.storeCachedResponse(
                CachedURLResponse(response: response, data: data),
                for: request
            )

            if let image = await decodeImage(from: data, targetSize: targetSize, scale: displayScale) {
                guard !Task.isCancelled else { return }
                phase = .success(image)
                loadedURL = url.absoluteString
            } else {
                phase = .failure(URLError(.badServerResponse))
            }
        } catch {
            guard !Task.isCancelled else { return }
            phase = .failure(error)
        }
    }

    /// Декодирует изображение вне главного потока.
    ///
    /// Используем `nonisolated async` вместо `Task.detached` потому что:
    /// - Swift автоматически выполняет функцию в cooperative thread pool (не блокирует MainActor)
    /// - Отмена родительской задачи (.task modifier) распространяется сюда автоматически
    /// - Не нужно вручную делать `Task.detached { }.value` — проще и безопаснее
    nonisolated private func decodeImage(from data: Data, targetSize: CGSize?, scale: CGFloat) async -> Image? {
        guard !Task.isCancelled else { return nil }

        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }

        let options: [CFString: Any]
        let validTargetSize: CGSize? = {
            guard let size = targetSize, size.width > 0, size.height > 0 else { return nil }
            return size
        }()

        if let targetSize = validTargetSize {
            let maxDimension = max(targetSize.width, targetSize.height) * scale
            options = [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceThumbnailMaxPixelSize: maxDimension,
                kCGImageSourceCreateThumbnailWithTransform: true
            ]
        } else {
            options = [:]
        }

        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary)
                         ?? CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            return nil
        }

        return Image(uiImage: UIImage(cgImage: cgImage))
    }
}

// MARK: - Convenience Initializers

extension CachedAsyncImage where Content == Image, Placeholder == ProgressView<EmptyView, EmptyView> {
    init(url: URL?, targetSize: CGSize? = nil) {
        self.init(
            url: url,
            targetSize: targetSize,
            content: { $0 },
            placeholder: { ProgressView() }
        )
    }
}

extension CachedAsyncImage where Placeholder == ProgressView<EmptyView, EmptyView> {
    init(
        url: URL?,
        targetSize: CGSize? = nil,
        @ViewBuilder content: @escaping (Image) -> Content
    ) {
        self.init(
            url: url,
            targetSize: targetSize,
            content: content,
            placeholder: { ProgressView() }
        )
    }
}
