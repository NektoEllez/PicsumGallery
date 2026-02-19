import SwiftUI

struct LoadMoreRowView: View {
    let title: String
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        Button {
            guard !isLoading else { return }
            HapticManager.shared.mediumImpact()
            action()
        } label: {
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
        .buttonStyle(LoadMorePressButtonStyle(isLoading: isLoading))
        .padding(.horizontal, DesignTokens.Spacing.large)
        .padding(.vertical, DesignTokens.Spacing.xSmall)
        .glassStyleBackground(cornerRadius: DesignTokens.CornerRadius.button)
        .disabled(isLoading)
        .opacity(isLoading ? DesignTokens.Opacity.disabledControl : 1)
        .accessibilityIdentifier("photos.loadMoreButton")
    }
}

private struct LoadMorePressButtonStyle: ButtonStyle {
    let isLoading: Bool

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed && !isLoading
        return configuration.label
            .scaleEffect(pressed ? 0.985 : 1.0)
            .opacity(pressed ? 0.94 : 1.0)
            .animation(.spring(response: 0.24, dampingFraction: 0.72), value: pressed)
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
