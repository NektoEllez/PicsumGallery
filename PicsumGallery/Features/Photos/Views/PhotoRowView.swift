import SwiftUI

struct PhotoRowView: View {
    let photo: PicsumPhoto
    let landscapeTitle: String
    let portraitTitle: String
    let squareTitle: String

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.medium) {
            photoThumbnail
                .glassStyleBackground(cornerRadius: DesignTokens.CornerRadius.card)
            contentColumn
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, DesignTokens.Spacing.medium)
        .padding(.vertical, DesignTokens.Spacing.medium)
    }

    private var contentColumn: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xSmall) {
            authorText
            metadataRow
        }
    }

    private var authorText: some View {
        Text(photo.author)
            .font(.headline)
            .foregroundStyle(.primary)
    }

    private var metadataRow: some View {
        HStack(spacing: DesignTokens.Spacing.small) {
            dimensionsLabel
            orientationLabel
        }
    }

    private var dimensionsLabel: some View {
        Label {
            Text("\(photo.width) × \(photo.height)")
                .font(.caption)
        } icon: {
            Image(systemName: "aspectratio")
                .font(.caption2)
        }
        .foregroundStyle(.secondary)
    }

    @ViewBuilder
    private var orientationLabel: some View {
        if photo.width > photo.height {
            Label(landscapeTitle, systemImage: "rectangle")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        } else if photo.height > photo.width {
            Label(portraitTitle, systemImage: "rectangle.portrait")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        } else {
            Label(squareTitle, systemImage: "square")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
    }

    private var photoThumbnail: some View {
        CachedAsyncImage(
            url: photo.downloadUrl,
            targetSize: CGSize(
                width: DesignTokens.Size.thumbnailSide,
                height: DesignTokens.Size.thumbnailSide
            )
        ) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            thumbnailPlaceholder
        }
        .frame(
            width: DesignTokens.Size.thumbnailSide,
            height: DesignTokens.Size.thumbnailSide
        )
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.card))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.card)
                .strokeBorder(
                    Color.secondary.opacity(DesignTokens.Opacity.subtleStroke),
                    lineWidth: DesignTokens.Border.subtleLineWidth
                )
        )
    }

    private var thumbnailPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.card)
                .fill(Color.secondary.opacity(DesignTokens.Opacity.subtleFill))
            ProgressView()
        }
    }

}

#Preview("Landscape") {
    List {
        PhotoRowView(
            photo: .previewLandscape,
            landscapeTitle: "Landscape",
            portraitTitle: "Portrait",
            squareTitle: "Square"
        )
        .listRowInsets(DesignTokens.Insets.photoRow)
    }
    .listStyle(.insetGrouped)
}

#Preview("Portrait Dark") {
    List {
        PhotoRowView(
            photo: .previewPortrait,
            landscapeTitle: "Landscape",
            portraitTitle: "Portrait",
            squareTitle: "Square"
        )
        .listRowInsets(DesignTokens.Insets.photoRow)
    }
    .listStyle(.insetGrouped)
    .preferredColorScheme(.dark)
}

#Preview("Square") {
    List {
        PhotoRowView(
            photo: .previewSquare,
            landscapeTitle: "Landscape",
            portraitTitle: "Portrait",
            squareTitle: "Square"
        )
        .listRowInsets(DesignTokens.Insets.photoRow)
    }
    .listStyle(.insetGrouped)
}

private extension PicsumPhoto {
    static var previewLandscape: PicsumPhoto {
        makePreview(id: "1", author: "John Appleseed", width: 1920, height: 1080)
    }

    static var previewPortrait: PicsumPhoto {
        makePreview(id: "2", author: "Mary Johnson", width: 1080, height: 1920)
    }

    static var previewSquare: PicsumPhoto {
        makePreview(id: "3", author: "Alex Brown", width: 1200, height: 1200)
    }

    static func makePreview(id: String, author: String, width: Int, height: Int) -> PicsumPhoto {
        guard let url = URL(string: "https://picsum.photos/id/\(id)/\(width)/\(height)"),
              let downloadUrl = URL(string: "https://picsum.photos/id/\(id)/200/200") else {
            fatalError("Preview: invalid URL for id=\(id) width=\(width) height=\(height)")
        }
        return PicsumPhoto(
            id: PicsumPhotoID(value: id),
            author: author,
            width: width,
            height: height,
            url: url,
            downloadUrl: downloadUrl
        )
    }
}
