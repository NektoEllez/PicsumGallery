import Foundation
import SwiftData

@Model
final class PicsumPhotoCache {
    @Attribute(.unique) var id: String
    var author: String
    var width: Int
    var height: Int
    var url: URL
    var downloadUrl: String
    var cachedAt: Date
    
    init(
        id: String,
        author: String,
        width: Int,
        height: Int,
        url: URL,
        downloadUrl: String,
        cachedAt: Date = Date()
    ) {
        self.id = id
        self.author = author
        self.width = width
        self.height = height
        self.url = url
        self.downloadUrl = downloadUrl
        self.cachedAt = cachedAt
    }
    
    func toPicsumPhoto() -> PicsumPhoto {
        let resolvedDownloadURL = URL(string: downloadUrl) ?? url
        return PicsumPhoto(
            id: PicsumPhotoID(value: id),
            author: author,
            width: width,
            height: height,
            url: url,
            downloadUrl: resolvedDownloadURL
        )
    }
    
    static func from(_ photo: PicsumPhoto) -> PicsumPhotoCache {
        PicsumPhotoCache(
            id: photo.id.value,
            author: photo.author,
            width: photo.width,
            height: photo.height,
            url: photo.url,
            downloadUrl: photo.downloadUrl.absoluteString
        )
    }
}
