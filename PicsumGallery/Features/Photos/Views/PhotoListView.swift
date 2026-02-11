import SwiftUI

struct PhotoListView: View {
    @State private var viewModel: PhotosViewModel
    @Environment(\.router) private var router
    @Environment(\.appSettings) private var appSettings

    private var L: (LocalizedString) -> String {
        { $0.localized(for: appSettings.languageCode) }
    }

    init(viewModel: PhotosViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        contentView
            .navigationTitle(L(.photos))
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
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.2)
            Text(L(.loadingPhotos))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 64))
                .foregroundStyle(.tertiary)
            
            VStack(spacing: 8) {
                Text(L(.noPhotosYet))
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(L(.pullToRefresh))
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
                ForEach(viewModel.photos, id: \.id) { photo in
                    NavigationLink(value: Route.photoDetail(photo)) {
                        photoRow(photo: photo)
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .onAppear {
                        let isLastPhoto = photo.id == viewModel.photos.last?.id
                        if isLastPhoto && viewModel.hasMore && !viewModel.isLoadingMore {
                            viewModel.loadMore()
                        }
                    }
                }
                
                if viewModel.hasMore {
                    loadMoreButton
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }
            } header: {
                Text("\(viewModel.photos.count) \(viewModel.photos.count == 1 ? L(.photoSingular) : L(.photoPlural))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .textCase(nil)
            }
        }
        .listStyle(.insetGrouped)
        .refreshable {
            await viewModel.load()
        }
    }
    
    private var loadMoreButton: some View {
        Button {
            viewModel.loadMore()
        } label: {
            HStack {
                if viewModel.isLoadingMore {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Text(L(.loadMore))
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .disabled(viewModel.isLoadingMore)
        .foregroundStyle(viewModel.isLoadingMore ? .secondary : .primary)
        .accessibilityIdentifier("photos.loadMoreButton")
    }
    
    private func photoRow(photo: PicsumPhoto) -> some View {
        HStack(spacing: 16) {
            photoThumbnail(photo: photo)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(photo.author)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                HStack(spacing: 12) {
                    Label {
                        Text("\(photo.width) × \(photo.height)")
                            .font(.caption)
                    } icon: {
                        Image(systemName: "aspectratio")
                            .font(.caption2)
                    }
                    .foregroundStyle(.secondary)
                    
                    if photo.width > photo.height {
                        Label(L(.landscape), systemImage: "rectangle")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    } else if photo.height > photo.width {
                        Label(L(.portrait), systemImage: "rectangle.portrait")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    } else {
                        Label(L(.square), systemImage: "square")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
    
    private func photoThumbnail(photo: PicsumPhoto) -> some View {
        CachedAsyncImage(
            url: URL(string: photo.downloadUrl),
            targetSize: CGSize(width: 80, height: 80)
        ) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.secondary.opacity(0.1))
                ProgressView()
            }
        }
        .frame(width: 80, height: 80)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.secondary.opacity(0.2), lineWidth: 0.5)
        )
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
