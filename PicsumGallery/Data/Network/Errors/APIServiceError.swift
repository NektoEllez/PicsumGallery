import Foundation

/// Typed API service errors.
///
/// **Purpose:** Instead of generic `Error`, we use specific error types.
/// This allows ViewModel and UI to properly handle different cases.
///
/// **Sendable:** Required for Swift 6+ concurrency - safe to pass between threads.
enum APIServiceError: Error, Sendable {
    case invalidURL
    case networkError(URLError)
    case httpError(statusCode: Int, message: String?)
    case decodingError(DecodingError)
    case unknown(message: String)
}

extension APIServiceError: LocalizedError {
    /// User-friendly error description for display in UI.
    var errorDescription: String? {
        switch self {
            case .invalidURL:
                return "Failed to create URL for request"
            case .networkError(let urlError):
                return "Network error: \(urlError.localizedDescription)"
            case .httpError(let statusCode, let message):
                let statusMessage = message ?? "Unknown server error"
                return "Server error (\(statusCode)): \(statusMessage)"
            case .decodingError(let decodingError):
                switch decodingError {
                    case .keyNotFound(let key, _):
                        return "Missing field '\(key.stringValue)' in API response"
                    case .typeMismatch(let type, let context):
                        let fieldName = context.codingPath.last?.stringValue ?? "unknown"
                        return "Invalid data type for field '\(fieldName)'. Expected \(type)"
                    case .valueNotFound(_, let context):
                        let fieldName = context.codingPath.last?.stringValue ?? "unknown"
                        return "Missing value for field '\(fieldName)'"
                    case .dataCorrupted(let context):
                        return "Corrupted data: \(context.debugDescription)"
                    @unknown default:
                        return "Data decoding error"
                }
            case .unknown(let message):
                return "Unknown error: \(message)"
        }
    }
    
    /// Error reason (more detailed description of why the error occurred).
    var failureReason: String? {
        switch self {
            case .invalidURL:
                return "URL string or components are invalid"
            case .networkError(let urlError):
                let nsError = urlError as NSError
                let reason = nsError.localizedFailureReason ?? "Unknown reason"
                return "Network error: \(reason)"
            case .httpError(let statusCode, _):
                switch statusCode {
                    case 400:
                        return "Invalid request to server"
                    case 401:
                        return "Authentication required"
                    case 403:
                        return "Access forbidden"
                    case 404:
                        return "Resource not found"
                    case 429:
                        return "Too many requests (rate limit)"
                    case 500...599:
                        return "Server-side error"
                    default:
                        return "HTTP error \(statusCode)"
                }
            case .decodingError(let decodingError):
                switch decodingError {
                    case .keyNotFound(let key, let context):
                        let path = context.codingPath.map { $0.stringValue }.joined(separator: ".")
                        return "Required field '\(key.stringValue)' is missing in API response at path \(path)"
                    case .typeMismatch(let type, let context):
                        let path = context.codingPath.map { $0.stringValue }.joined(separator: ".")
                        return "Data type does not match expected \(type) for field \(path)"
                    case .valueNotFound(let type, let context):
                        let path = context.codingPath.map { $0.stringValue }.joined(separator: ".")
                        return "Value of type \(type) is missing for field \(path)"
                    case .dataCorrupted(let context):
                        return "Data is corrupted or has invalid format: \(context.debugDescription)"
                    @unknown default:
                        return "Error decoding JSON response"
                }
            case .unknown(let message):
                return "Unexpected error: \(message)"
        }
    }
    
    /// Recovery suggestion (what the user can do).
    var recoverySuggestion: String? {
        switch self {
            case .invalidURL:
                return "Check your internet connection and try again"
            case .networkError(let urlError):
                switch urlError.code {
                    case .notConnectedToInternet, .networkConnectionLost:
                        return "Check your internet connection and try again"
                    case .timedOut:
                        return "Request took too long. Check your connection and try again"
                    case .cannotFindHost, .cannotConnectToHost:
                        return "Failed to connect to server. Check your internet connection"
                    default:
                        return "Check your internet connection and try again"
                }
            case .httpError(let statusCode, _):
                switch statusCode {
                    case 400, 404:
                        return "Try refreshing the data"
                    case 401, 403:
                        return "Check your access settings"
                    case 429:
                        return "Wait a moment and try again"
                    case 500...599:
                        return "Server-side issue. Please try again later"
                    default:
                        return "Try refreshing the data"
                }
            case .decodingError:
                return "Data has invalid format. Try refreshing the data or contact support"
                
            case .unknown:
                return "An unexpected error occurred. Try refreshing the data"
        }
    }
}

extension APIServiceError {
    static func from(_ error: Error) -> APIServiceError {
        if let apiServiceError = error as? APIServiceError {
            return apiServiceError
        }
        if let urlError = error as? URLError {
            return .networkError(urlError)
        }
        if let decodingError = error as? DecodingError {
            return .decodingError(decodingError)
        }
        return .unknown(message: error.localizedDescription)
    }
}
