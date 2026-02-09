import SwiftUI
import ImageIO

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    let targetSize: CGSize?
    @ViewBuilder let content: (Image) -> Content
    @ViewBuilder let placeholder: () -> Placeholder
    
    @State private var phase: AsyncImagePhase = .empty
    @State private var loadTask: Task<Void, Never>?
    
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
                    .task(id: url?.absoluteString) {
                        await loadImage()
                    }
            case .success(let image):
                content(image)
                    .id(url?.absoluteString)
            case .failure:
                placeholder()
            @unknown default:
                placeholder()
            }
        }
        .onDisappear {
            loadTask?.cancel()
            loadTask = nil
        }
    }
    
    @MainActor
    private func loadImage() async {
        guard let url = url else {
            phase = .failure(URLError(.badURL))
            return
        }
        
        loadTask?.cancel()
        
        loadTask = Task { @MainActor in
            let request = URLRequest(url: url)
            if let cachedResponse = URLCache.shared.cachedResponse(for: request) {
                if !Task.isCancelled,
                   let image = await image(from: cachedResponse.data, targetSize: targetSize) {
                    phase = .success(image)
                    return
                }
            }
            
            guard !Task.isCancelled else { return }
            
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                
                guard !Task.isCancelled else { return }
                
                let cachedResponse = CachedURLResponse(response: response, data: data)
                URLCache.shared.storeCachedResponse(cachedResponse, for: request)
                
                guard !Task.isCancelled else { return }
                
                if let image = await image(from: data, targetSize: targetSize) {
                    guard !Task.isCancelled else { return }
                    phase = .success(image)
                } else {
                    phase = .failure(URLError(.badServerResponse))
                }
            } catch {
                if !Task.isCancelled {
                    phase = .failure(error)
                }
            }
        }
        
        await loadTask?.value
    }
    
    private func image(from data: Data, targetSize: CGSize?) async -> Image? {
        await Task.detached {
            guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
                return nil
            }
            
            let options: [CFString: Any]
            if let targetSize = targetSize {
                let maxDimension = max(targetSize.width, targetSize.height) * 2
                options = [
                    kCGImageSourceCreateThumbnailFromImageAlways: true,
                    kCGImageSourceThumbnailMaxPixelSize: maxDimension,
                    kCGImageSourceCreateThumbnailWithTransform: true
                ]
            } else {
                options = [:]
            }
            
            guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) ??
                               CGImageSourceCreateImageAtIndex(source, 0, nil) else {
                return nil
            }
            
            let uiImage = UIImage(cgImage: cgImage)
            return Image(uiImage: uiImage)
        }.value
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
