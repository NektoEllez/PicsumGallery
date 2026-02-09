import SwiftUI

struct PhotoDetailView: View {
    let photo: PicsumPhoto
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                photoImage
                photoMetadata
            }
            .padding()
        }
        .navigationTitle("Photo")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var photoImage: some View {
        AsyncImage(url: URL(string: photo.downloadUrl)) { phase in
            switch phase {
            case .empty:
                loadingView
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            case .failure:
                errorView
            @unknown default:
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading image...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(minHeight: 300)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.secondary.opacity(0.1))
        )
    }
    
    private var errorView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.orange)
            Text("Failed to load image")
                .font(.headline)
                .foregroundStyle(.primary)
            Text("Please try again later")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(minHeight: 300)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.orange.opacity(0.1))
        )
    }
    
    private var photoMetadata: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader(title: "Information")
            
            VStack(spacing: 0) {
                metadataRow(
                    icon: "person.fill",
                    title: "Author",
                    value: photo.author
                )
                
                Divider()
                    .padding(.leading, 48)
                
                metadataRow(
                    icon: "ruler",
                    title: "Dimensions",
                    value: "\(photo.width) × \(photo.height) px"
                )
                
                Divider()
                    .padding(.leading, 48)
                
                metadataRow(
                    icon: "aspectratio",
                    title: "Aspect Ratio",
                    value: String(format: "%.2f", Double(photo.width) / Double(photo.height))
                )
            }
            .padding(.vertical, 8)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.secondary.opacity(0.1))
        )
    }
    
    private func sectionHeader(title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(.primary)
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 8)
    }
    
    private func metadataRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.secondary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    let mockPhoto = PicsumPhoto(
        id: PicsumPhotoID(value: "1"),
        author: "John Doe",
        width: 1920,
        height: 1080,
        url: URL(string: "https://picsum.photos/id/1/1920/1080")!,
        downloadUrl: "https://picsum.photos/id/1/1920/1080"
    )
    
    return NavigationStack {
        PhotoDetailView(photo: mockPhoto)
    }
}
