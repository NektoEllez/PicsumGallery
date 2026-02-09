import SwiftUI

struct ToastModifier: ViewModifier {
    var alignment: Alignment = .top

    func body(content: Content) -> some View {
        content
            .overlay(alignment: alignment) {
                ToastOverlayContent(alignment: alignment)
            }
    }
}

/// Dedicated view so SwiftUI observes ToastStore and re-renders when message changes.
private struct ToastOverlayContent: View {
    @Environment(\.toastStore) private var toastStore
    var alignment: Alignment

    var body: some View {
        if let store = toastStore, let message = store.message {
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
    func toastOverlay(alignment: Alignment = .top) -> some View {
        modifier(ToastModifier(alignment: alignment))
    }
}
