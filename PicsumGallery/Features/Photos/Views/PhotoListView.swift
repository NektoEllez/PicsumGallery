import SwiftUI

struct PhotoListView: View {
    @State private var viewModel: PhotosViewModel
    @Environment(\.router) private var router
    @Environment(\.appSettings) private var appSettings

    private var localized: (LocalizedString) -> String {
        { $0.localized(for: appSettings.languageCode) }
    }

    init(viewModel: PhotosViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        contentView
            .navigationTitle(localized(.photos))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        router?.navigate(to: .settings)
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("photos.settingsButton")
                }
            }
            .task {
                if viewModel.photos.isEmpty {
                    await viewModel.load()
                }
            }
            .onDisappear {
                viewModel.cancelPendingWork()
            }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading && viewModel.photos.isEmpty {
            loadingView
        } else if viewModel.photos.isEmpty {
            emptyStateView
        } else {
            photoList
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: DesignTokens.Spacing.large) {
            ProgressView()
                .scaleEffect(1.2)
            Text(localized(.loadingPhotos))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: DesignTokens.Spacing.large) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 64))
                .foregroundStyle(.tertiary)
            
            VStack(spacing: DesignTokens.Spacing.xSmall) {
                Text(localized(.noPhotosYet))
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(localized(.pullToRefresh))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var photoList: some View {
        List {
            Section {
                ForEach(viewModel.photos) { photo in
                    let isLastPhoto = photo.id == viewModel.photos.last?.id
                    NavigationLink(value: Route.photoDetail(photo)) {
                        PhotoRowView(
                            photo: photo,
                            landscapeTitle: localized(.landscape),
                            portraitTitle: localized(.portrait),
                            squareTitle: localized(.square)
                        )
                    }
                    .listRowInsets(DesignTokens.Insets.photoRow)
                    .listRowSeparator(
                        (viewModel.hasMore && isLastPhoto) ? .hidden : .visible,
                        edges: .bottom
                    )
                }

                if viewModel.hasMore {
                    LoadMoreRowView(
                        title: localized(.loadMore),
                        isLoading: viewModel.isLoadingMore
                    ) {
                        viewModel.loadMore()
                    }
                    .listRowInsets(DesignTokens.Insets.loadMoreRow)
                }
            } header: {
                Text("\(viewModel.photos.count) " +
                     (viewModel.photos.count == 1
                      ? localized(.photoSingular)
                      : localized(.photoPlural)))
                .font(.caption)
                .foregroundStyle(.secondary)
                .textCase(nil)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .refreshable {
            await viewModel.load()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

}

#Preview("With Photos") {
    NavigationStack {
        let cacheService = MockPhotoCacheService(prefilledPhotos: PhotoListView.mockPhotos)
        let viewModel = PhotosViewModel(
            apiService: PhotoListView.mockAPIService,
            errorService: PhotoListView.mockErrorService,
            cacheService: cacheService,
            localizer: AppSettings.shared
        )
        PhotoListView(viewModel: viewModel)
            .environment(\.appSettings, AppSettings.shared)
            .task {
                viewModel.photos = PhotoListView.mockPhotos
                viewModel.hasMore = true
            }
    }
}

#Preview("Loading") {
    NavigationStack {
        let viewModel = PhotosViewModel(
            apiService: PhotoListView.mockAPIService,
            errorService: PhotoListView.mockErrorService,
            cacheService: MockPhotoCacheService()
        )
        PhotoListView(viewModel: viewModel)
            .environment(\.appSettings, AppSettings.shared)
            .task {
                viewModel.isLoading = true
            }
    }
}

#Preview("Empty") {
    NavigationStack {
        let viewModel = PhotosViewModel(
            apiService: PhotoListView.mockAPIService,
            errorService: PhotoListView.mockErrorService,
            cacheService: MockPhotoCacheService()
        )
        PhotoListView(viewModel: viewModel)
            .environment(\.appSettings, AppSettings.shared)
    }
}

#Preview {
    RouterView()
}
