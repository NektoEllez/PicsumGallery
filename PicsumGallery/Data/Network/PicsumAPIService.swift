import Foundation

protocol PicsumAPIServiceProtocol: Sendable {
    func fetchPhotos(page: Int, limit: Int) async throws -> [PicsumPhoto]
}

final class PicsumAPIService: PicsumAPIServiceProtocol, Sendable {
    private let baseURL = "https://picsum.photos/v2/list"
    private let maxResponseSize: Int64 = 10 * 1024 * 1024 // 10 MB
    private let decoder = JSONDecoder()
    private let session: URLSession

    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30.0
        configuration.timeoutIntervalForResource = 60.0
        configuration.requestCachePolicy = .useProtocolCachePolicy
        configuration.urlCache = URLCache(memoryCapacity: 4 * 1024 * 1024,
                                          diskCapacity: 20 * 1024 * 1024)
        self.session = URLSession(configuration: configuration)
    }

    func fetchPhotos(page: Int = 1, limit: Int = 20) async throws -> [PicsumPhoto] {
        guard var components = URLComponents(string: baseURL) else {
            throw APIServiceError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "limit", value: String(limit))
        ]

        guard let url = components.url else {
            throw APIServiceError.invalidURL
        }

        do {
            let (data, response) = try await session.data(from: url)
            if data.count > maxResponseSize {
                throw APIServiceError.httpError(
                    statusCode: 413,
                    message: "Response too large"
                )
            }
            if let httpResponse = response as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode

                guard (200...299).contains(statusCode) else {
                    let errorMessage = HTTPURLResponse.localizedString(forStatusCode: statusCode)
                    throw APIServiceError.httpError(statusCode: statusCode, message: errorMessage)
                }
            }
            do {
                let photos = try decoder.decode([PicsumPhoto].self, from: data)
                return photos
            } catch let decodingError as DecodingError {
                throw APIServiceError.decodingError(decodingError)
            }
        } catch let urlError as URLError {
            throw APIServiceError.networkError(urlError)
        } catch let apiError as APIServiceError {
            throw apiError
        } catch {
            throw APIServiceError.from(error)
        }
    }
}
