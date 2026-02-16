import Foundation
import SwiftUI

enum Route: Hashable {
    case photoList
    case photoDetail(PicsumPhoto)
    case settings
}

@Observable
@MainActor
final class Router {
    var path = NavigationPath()

    func navigate(to route: Route) {
        HapticManager.shared.lightImpact()
        path.append(route)
    }

    func navigateBack() {
        guard !path.isEmpty else { return }
        HapticManager.shared.lightImpact()
        path.removeLast()
    }

    func navigateToRoot() {
        guard !path.isEmpty else { return }
        HapticManager.shared.mediumImpact()
        path.removeLast(path.count)
    }
}