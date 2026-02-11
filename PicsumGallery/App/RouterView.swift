import SwiftUI
import SwiftData

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
    @State private var appSettings = AppSettings.shared
    @State private var photosViewModel: PhotosViewModel?
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack(path: $router.path) {
            destinationView(for: .photoList)
                .navigationDestination(for: Route.self) { route in
                    destinationView(for: route)
                }
        }
        .preferredColorScheme(appSettings.colorScheme)
        .environment(\.router, router)
        .environment(\.toastStore, toastStore)
        .environment(\.appSettings, appSettings)
        .environment(errorService)
        .toastOverlay(alignment: .top, store: toastStore)
        .task {
            if photosViewModel == nil {
                let cacheService = PhotoCacheService(modelContext: modelContext)
                let viewModel = PhotosViewModel(
                    apiService: apiService,
                    errorService: errorService,
                    cacheService: cacheService,
                    localizer: appSettings
                )
                viewModel.toastStore = toastStore
                photosViewModel = viewModel
            }
            errorService.toastStore = toastStore
        }
    }
    
    @ViewBuilder
    private func destinationView(for route: Route) -> some View {
        sharedEnvironment {
            switch route {
            case .photoList:
                if let viewModel = photosViewModel {
                    PhotoListView(viewModel: viewModel)
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            case .photoDetail(let photo):
                PhotoDetailView(photo: photo)
            case .settings:
                SettingsView()
            }
        }
    }

    /// Single composition root: injects shared dependencies into every navigation destination
    /// so that pushed views (e.g. from navigationDestination) receive the same environment.
    private func sharedEnvironment<V: View>(@ViewBuilder content: () -> V) -> some View {
        content()
            .environment(\.toastStore, toastStore)
    }
}

#Preview {
    RouterView()
}
