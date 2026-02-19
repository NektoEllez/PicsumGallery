import Foundation

struct PicsumPhotoID: Hashable, Codable, Sendable {
    let value: String
    
    init(value: String) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        value = try container.decode(String.self)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}

struct PicsumPhoto: Codable, Identifiable, Equatable, Hashable, Sendable {
    let id: PicsumPhotoID
    let author: String
    let width: Int
    let height: Int
    let url: URL
    let downloadUrl: URL

    enum CodingKeys: String, CodingKey {
        case id, author, width, height, url
        case downloadUrl = "download_url"
    }
}
