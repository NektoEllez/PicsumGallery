import Foundation
import SwiftUI
import os.log

/// Service for centralized error handling in the application.
///
/// **Purpose:** Single point of error handling.
/// - Maps errors to user-friendly messages
/// - Logs errors for debugging via OS Log
/// - Centralized management of error display in UI
///
/// **@MainActor:** All UI updates must be on the main thread.
/// **@Observable:** SwiftUI will track changes to display errors.
@Observable
@MainActor
final class ErrorService {
    /// Logger for error logging via unified logging system.
    ///
    /// **Subsystem:** Identifies the application (reverse DNS notation).
    /// **Category:** Log category for filtering (ErrorService).
    ///
    /// **Why OS Log instead of print:**
    /// - Logs are saved by the system and accessible via Console.app
    /// - Can filter by subsystem/category
    /// - Proper logging levels (error, debug, info)
    /// - Performance: debug logs only in memory, error - to disk
    private static let logger = Logger(
        subsystem: "com.PicsumGallery",
        category: "ErrorService"
    )
    
    /// Current error for display in UI (optional).
    var currentError: APIServiceError?
    
    /// Toast store for showing non-blocking error messages.
    var toastStore: ToastStore?

    /// Handles error and returns user-friendly message.
    ///
    /// - Parameter error: Error to handle
    /// - Returns: User-friendly error message
    func handle(_ error: Error) -> String {
        let apiError = mapToAPIServiceError(error)
        currentError = apiError
        log(apiError, level: .error)
        
        // Show toast notification instead of blocking alert
        showErrorToast(apiError)
        
        return apiError.localizedDescription
    }
    
    /// Shows error as toast notification.
    ///
    /// - Parameter error: Error to display
    private func showErrorToast(_ error: APIServiceError) {
        let message = ToastMessage(
            text: error.localizedDescription,
            icon: "exclamationmark.triangle.fill",
            style: .error
        )
        toastStore?.show(message, autoDismissAfter: 4)
    }

    /// Converts any error to APIServiceError.
    private func mapToAPIServiceError(_ error: Error) -> APIServiceError {
        if let urlError = error as? URLError {
            return .networkError(urlError)
        } else if let decodingError = error as? DecodingError {
            return .decodingError(decodingError)
        } else if let apiServiceError = error as? APIServiceError {
            return apiServiceError
        } else {
            return .unknown(error)
        }
    }

    /// Logs error without saving to currentError.
    ///
    /// - Parameters:
    ///   - error: Error to log
    ///   - level: Logging level (default .debug)
    func logOnly(_ error: Error, level: OSLogType = .debug) {
        let apiError = mapToAPIServiceError(error)
        log(apiError, level: level)
    }

    /// Logs error via unified logging system.
    ///
    /// - Parameters:
    ///   - error: Error to log
    ///   - level: Logging level (.error for critical, .debug for details)
    private func log(_ error: APIServiceError, level: OSLogType) {
        logMessage(error, level: level)
        #if DEBUG
        logErrorDetails(error)
        #endif
    }

    /// Logs main error message with specified level.
    private func logMessage(_ error: APIServiceError, level: OSLogType) {
        let message = "❌ \(error.localizedDescription)"
        logMessageWithLevel(message, level: level)
    }

    /// Logs message with specified logging level.
    private func logMessageWithLevel(_ message: String, level: OSLogType) {
        switch level {
        case .error:
            Self.logger.error("\(message)")
        case .debug:
            #if DEBUG
            Self.logger.debug("\(message)")
            #endif
        case .info:
            Self.logger.info("\(message)")
        case .fault:
            Self.logger.fault("\(message)")
        default:
            Self.logger.debug("\(message)")
        }
    }

    private func logErrorDetails(_ error: APIServiceError) {
        switch error {
        case .networkError(let urlError):
            logNetworkErrorDetails(urlError)
        case .httpError(let statusCode, let message):
            logHTTPErrorDetails(statusCode: statusCode, message: message)
        case .decodingError(let decodingError):
            logDecodingError(decodingError)
        case .invalidURL:
            Self.logger.debug("Invalid URL - failed to create URL from string or components")
        case .unknown(let underlyingError):
            logUnknownError(underlyingError)
        }
    }
    
    /// Logs network error details.
    private func logNetworkErrorDetails(_ urlError: URLError) {
        Self.logger.debug("URLError code: \(urlError.code.rawValue, privacy: .public)")
        Self.logger.debug("URLError description: \(urlError.localizedDescription, privacy: .public)")
        let nsError = urlError as NSError
        if let failureReason = nsError.localizedFailureReason {
            Self.logger.debug("URLError failure reason: \(failureReason, privacy: .public)")
        }
    }
    
    /// Logs HTTP error details.
    private func logHTTPErrorDetails(statusCode: Int, message: String?) {
        Self.logger.debug("HTTP Status: \(statusCode, privacy: .public)")
        if let message = message {
            Self.logger.debug("HTTP Message: \(message, privacy: .public)")
        }
    }
    
    /// Logs decoding error details.
    private func logDecodingError(_ decodingError: DecodingError) {
        #if DEBUG
        switch decodingError {
        case .keyNotFound(let key, let context):
            Self.logger.debug("Decoding key not found: \(key.stringValue, privacy: .public)")
            let path = context.codingPath.map { $0.stringValue }.joined(separator: ".")
            Self.logger.debug("Coding path: \(path, privacy: .public)")
        case .typeMismatch(let type, let context):
            let typeDescription = String(describing: type)
            Self.logger.debug("Decoding type mismatch: expected \(typeDescription, privacy: .public)")
            let path = context.codingPath.map { $0.stringValue }.joined(separator: ".")
            Self.logger.debug("Coding path: \(path, privacy: .public)")
        case .valueNotFound(let type, let context):
            let typeDescription = String(describing: type)
            Self.logger.debug("Decoding value not found: \(typeDescription, privacy: .public)")
            let path = context.codingPath.map { $0.stringValue }.joined(separator: ".")
            Self.logger.debug("Coding path: \(path, privacy: .public)")
        case .dataCorrupted(let context):
            Self.logger.debug("Decoding data corrupted: \(context.debugDescription, privacy: .public)")
        @unknown default:
            let errorDescription = String(describing: decodingError)
            Self.logger.debug("Decoding error: \(errorDescription, privacy: .public)")
        }
        #endif
    }
    
    /// Logs unknown error details.
    private func logUnknownError(_ underlyingError: Error) {
        #if DEBUG
        let errorType = String(describing: type(of: underlyingError))
        Self.logger.debug("Unknown error type: \(errorType, privacy: .public)")
        Self.logger.debug("Unknown error: \(underlyingError.localizedDescription, privacy: .public)")
        if let failureReason = (underlyingError as? LocalizedError)?.failureReason {
            Self.logger.debug("Unknown error failure reason: \(failureReason, privacy: .public)")
        }
        #endif
    }
    
    /// Clears current error.
    func clearError() {
        currentError = nil
    }
}
