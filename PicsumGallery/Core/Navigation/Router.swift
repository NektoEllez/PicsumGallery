import Foundation
import SwiftUI

enum Route: Hashable {
    case photoList
    case photoDetail(PicsumPhoto)
    case settings
}@Observable
@MainActor
final class Router {
    var path = NavigationPath()

    func navigate(to route: Route) {
        path.append(route)
    }

    func navigateBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func navigateToRoot() {
        path.removeLast(path.count)
    }
}
