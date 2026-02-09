import SwiftUI

struct PhotoDetailView: View {
    let photo: PicsumPhoto
    @Environment(\.appSettings) private var appSettings

    private var L: (LocalizedString) -> String {
        { $0.localized(for: appSettings.languageCode) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                photoImage
                photoMetadata
            }
            .padding()
        }
        .navigationTitle(L(.photo))
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var photoImage: some View {
        CachedAsyncImage(url: URL(string: photo.downloadUrl)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        } placeholder: {
            loadingView
        }
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.2)
            Text(L(.loadingImage))
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
    
    private var photoMetadata: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader(title: L(.information))
            
            VStack(spacing: 0) {
                metadataRow(
                    icon: "person.fill",
                    title: L(.author),
                    value: photo.author
                )
                
                Divider()
                    .padding(.leading, 48)
                
                metadataRow(
                    icon: "ruler",
                    title: L(.dimensions),
                    value: "\(photo.width) × \(photo.height) px"
                )
                
                Divider()
                    .padding(.leading, 48)
                
                metadataRow(
                    icon: "aspectratio",
                    title: L(.aspectRatio),
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
    guard let url = URL(string: "https://picsum.photos/id/1/1920/1080") else {
        return Text(LocalizedString.invalidUrl.localized(for: "en"))
    }
    let mockPhoto = PicsumPhoto(
        id: PicsumPhotoID(value: "1"),
        author: "John Doe",
        width: 1920,
        height: 1080,
        url: url,
        downloadUrl: "https://picsum.photos/id/1/1920/1080"
    )
    return NavigationStack {
        PhotoDetailView(photo: mockPhoto)
            .environment(\.appSettings, AppSettings.shared)
    }
}
