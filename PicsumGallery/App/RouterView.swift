import SwiftUI

private enum RouterKey: EnvironmentKey {
    static let defaultValue: Router? = nil
}

extension EnvironmentValues {
    var router: Router? {
        get { self[RouterKey.self] }
        set { self[RouterKey.self] = newValue }
    }
}

struct RouterView: View {
    @State private var router = Router()
    @State private var errorService = ErrorService()
    @State private var toastStore = ToastStore()
    @State private var apiService = PicsumAPIService()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            destinationView(for: .photoList)
                .navigationDestination(for: Route.self) { route in
                    destinationView(for: route)
                }
        }
        .environment(\.router, router)
        .environment(\.toastStore, toastStore)
        .environment(errorService)
        .toastOverlay(alignment: .top)
        .onAppear {
            errorService.toastStore = toastStore
        }
    }
    
    @ViewBuilder
    private func destinationView(for route: Route) -> some View {
        switch route {
        case .photoList:
            PhotoListView(
                viewModel: PhotosViewModel(
                    apiService: apiService,
                    errorService: errorService
                )
            )
        case .photoDetail(let photo):
            PhotoDetailView(photo: photo)
                .environment(\.toastStore, toastStore)
        }
    }
}

#Preview {
    RouterView()
}
