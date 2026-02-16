import SwiftUI

/// Section displaying photo metadata (author, dimensions, aspect ratio) in a card layout.
struct PhotoMetadataSection: View {
    let photo: PicsumPhoto
    let sectionTitle: String
    let authorTitle: String
    let dimensionsTitle: String
    let aspectRatioTitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader(title: sectionTitle)

            VStack(spacing: 0) {
                metadataRow(icon: "person.fill", title: authorTitle, value: photo.author)
                Divider().padding(.leading, 48)
                metadataRow(
                    icon: "ruler",
                    title: dimensionsTitle,
                    value: "\(photo.width) × \(photo.height) px"
                )
                Divider().padding(.leading, 48)
                metadataRow(
                    icon: "aspectratio",
                    title: aspectRatioTitle,
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
