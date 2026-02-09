import SwiftUI

// MARK: - DI: custom EnvironmentKey

private enum ToastStoreKey: EnvironmentKey {
    static let defaultValue: ToastStore? = nil
}

extension EnvironmentValues {
    var toastStore: ToastStore? {
        get { self[ToastStoreKey.self] }
        set { self[ToastStoreKey.self] = newValue }
    }
}

// MARK: - Store

@Observable
@MainActor
final class ToastStore {
    var message: ToastMessage?
    private var dismissTask: Task<Void, Never>?

    func show(_ message: ToastMessage, autoDismissAfter seconds: Double = 3) {
        dismissTask?.cancel()
        self.message = message
        dismissTask = Task {
            do {
                try await Task.sleep(for: .seconds(seconds))
                if !Task.isCancelled {
                    dismiss()
                }
            } catch {}
        }
    }

    func dismiss() {
        dismissTask?.cancel()
        dismissTask = nil
        withAnimation(.snappy(duration: 0.25)) {
            message = nil
        }
    }
}

struct ToastMessage: Equatable {
    let text: String
    let icon: String?
    let style: ToastStyle

    init(text: String, icon: String? = nil, style: ToastStyle = .default) {
        self.text = text
        self.icon = icon
        self.style = style
    }
}

enum ToastStyle {
    case `default`
    case success
    case warning
    case error
}
