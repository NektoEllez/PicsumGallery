import Foundation
import SwiftUI

/// Navigation routes for the app.
///
/// **Purpose:** Type-safe navigation using enum routes.
/// Each case represents a destination in the app.
enum Route: Hashable {
    /// Photo list screen (root view).
    case photoList
    
    /// Photo detail screen.
    case photoDetail(PicsumPhoto)
}

/// Router manages navigation state and provides navigation utilities.
///
/// **Purpose:** Centralized navigation management using NavigationPath.
/// Follows Swift 6+ concurrency patterns with @MainActor.
@Observable
@MainActor
final class Router {
    /// Navigation path for managing navigation stack state.
    var path = NavigationPath()
    
    /// Navigate to a specific route.
    ///
    /// - Parameter route: Route to navigate to
    func navigate(to route: Route) {
        path.append(route)
    }
    
    /// Navigate back in the navigation stack.
    func navigateBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    /// Navigate to root (clear all navigation).
    func navigateToRoot() {
        path.removeLast(path.count)
    }
}
