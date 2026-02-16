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
        .buttonStyle(.plain)
        .padding(.horizontal, DesignTokens.Spacing.large)
        .padding(.vertical, DesignTokens.Spacing.xSmall)
        .glassStyleBackground(cornerRadius: DesignTokens.CornerRadius.button)
        .modifier(LoadMorePressAnimation(isLoading: isLoading))
        .disabled(isLoading)
        .opacity(isLoading ? DesignTokens.Opacity.disabledControl : 1)
        .accessibilityIdentifier("photos.loadMoreButton")
    }
}

private struct LoadMorePressAnimation: ViewModifier {
    let isLoading: Bool
    @State private var isPressed = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.985 : 1.0)
            .opacity(isPressed ? 0.94 : 1.0)
            .animation(.spring(response: 0.24, dampingFraction: 0.72), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        guard !isLoading else { return }
                        isPressed = true
                    }
                    .onEnded { _ in
                        isPressed = false
                    }
            )
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
