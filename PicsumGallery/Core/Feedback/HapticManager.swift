import UIKit

/// Haptic feedback manager adapted from Court360.
@MainActor
final class HapticManager {
    static let shared = HapticManager()

    private init() {}

    private var isHapticFeedbackAvailable: Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        return UIDevice.current.userInterfaceIdiom == .phone
        #endif
    }

    nonisolated func lightImpact() {
        Task { @MainActor in
            guard isHapticFeedbackAvailable else { return }
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.prepare()
            generator.impactOccurred()
        }
    }

    nonisolated func mediumImpact() {
        Task { @MainActor in
            guard isHapticFeedbackAvailable else { return }
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred()
        }
    }

    nonisolated func selectionChanged() {
        Task { @MainActor in
            guard isHapticFeedbackAvailable else { return }
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
        }
    }

    nonisolated func success() {
        Task { @MainActor in
            guard isHapticFeedbackAvailable else { return }
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(.success)
        }
    }

    nonisolated func warning() {
        Task { @MainActor in
            guard isHapticFeedbackAvailable else { return }
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(.warning)
        }
    }

    nonisolated func error() {
        Task { @MainActor in
            guard isHapticFeedbackAvailable else { return }
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(.error)
        }
    }
}
