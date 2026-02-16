import SwiftUI

struct LoadMoreRowView: View {
    @Environment(\.colorScheme) private var colorScheme

    let title: String
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                        .tint(.primary)
                } else {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: DesignTokens.Size.minimumTapTarget)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, DesignTokens.Spacing.xSmall)
        .padding(.vertical, DesignTokens.Spacing.xSmall)
        .glassStyleBackground(cornerRadius: DesignTokens.CornerRadius.card)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.card, style: .continuous)
                .fill(baseBackgroundColor)
        )
        .disabled(isLoading)
        .opacity(isLoading ? DesignTokens.Opacity.disabledControl : 1)
        .accessibilityIdentifier("photos.loadMoreButton")
    }

    private var baseBackgroundColor: Color {
        if colorScheme == .dark {
            return .clear
        }
        return Color(
            red: 236.0 / 255.0,
            green: 234.0 / 255.0,
            blue: 232.0 / 255.0
        )
    }

    private var borderColor: Color {
        if colorScheme == .dark {
            return .white.opacity(0.18)
        }
        return .black.opacity(0.08)
    }
}

#Preview("Default") {
    List {
        LoadMoreRowView(
            title: "Load More",
            isLoading: false,
            action: {}
        )
        .listRowInsets(DesignTokens.Insets.loadMoreRow)
    }
    .listStyle(.insetGrouped)
}

#Preview("Loading") {
    List {
        LoadMoreRowView(
            title: "Load More",
            isLoading: true,
            action: {}
        )
        .listRowInsets(DesignTokens.Insets.loadMoreRow)
    }
    .listStyle(.insetGrouped)
}

#Preview("Dark") {
    List {
        LoadMoreRowView(
            title: "Load More",
            isLoading: false,
            action: {}
        )
        .listRowInsets(DesignTokens.Insets.loadMoreRow)
    }
    .listStyle(.insetGrouped)
    .preferredColorScheme(.dark)
}
