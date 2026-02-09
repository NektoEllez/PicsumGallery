import SwiftUI

struct PhotoListView: View {
    @State private var viewModel: PhotosViewModel
    @Environment(\.router) private var router
    
    init(viewModel: PhotosViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        contentView
            .navigationTitle("Photos")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await viewModel.load()
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
            Text("Loading photos...")
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
                Text("No Photos Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Pull down to refresh and load photos")
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
                    NavigationLink(value: Route.photoDetail(photo)) {
                        photoRow(photo: photo)
                    }
                }
            } header: {
                Text("\(viewModel.photos.count) photo\(viewModel.photos.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .textCase(nil)
            }
        }
        .refreshable {
            await viewModel.load()
        }
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
                        Label("Landscape", systemImage: "rectangle")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    } else if photo.height > photo.width {
                        Label("Portrait", systemImage: "rectangle.portrait")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    } else {
                        Label("Square", systemImage: "square")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 8)
    }
    
    private func photoThumbnail(photo: PicsumPhoto) -> some View {
        AsyncImage(url: URL(string: photo.downloadUrl)) { phase in
            switch phase {
            case .empty:
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.secondary.opacity(0.1))
                    ProgressView()
                }
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .failure:
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.secondary.opacity(0.1))
                    Image(systemName: "photo")
                        .foregroundStyle(.secondary)
                }
            @unknown default:
                EmptyView()
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

#Preview {
    NavigationStack {
        PhotoListView(
            viewModel: PhotosViewModel(
                apiService: PicsumAPIService(),
                errorService: ErrorService()
            )
        )
    }
}
