import SwiftUI

struct ToastModifier: ViewModifier {
    var alignment: Alignment = .top
    var store: ToastStore

    func body(content: Content) -> some View {
        content
            .overlay(alignment: alignment) {
                ToastOverlayContent(alignment: alignment, store: store)
            }
    }
}

/// Dedicated view that observes ToastStore directly so SwiftUI re-renders when message changes.
/// Pass the store from the parent (e.g. RouterView) so Observation tracks the same instance;
/// using only @Environment(\.toastStore) in overlays can fail to update in some navigation scenarios.
private struct ToastOverlayContent: View {
    var alignment: Alignment
    var store: ToastStore

    var body: some View {
        if let message = store.message {
            ToastView(message: message) {
                store.dismiss()
            }
            .padding(.horizontal, 20)
            .padding(alignment == .top ? .top : .bottom, 12)
            .transition(.asymmetric(
                insertion: .move(edge: alignment == .top ? .top : .bottom).combined(with: .opacity),
                removal: .move(edge: alignment == .top ? .top : .bottom).combined(with: .opacity)
            ))
            .animation(.snappy(duration: 0.25), value: message.text)
        }
    }
}

extension View {
    func toastOverlay(alignment: Alignment = .top, store: ToastStore) -> some View {
        modifier(ToastModifier(alignment: alignment, store: store))
    }
}
