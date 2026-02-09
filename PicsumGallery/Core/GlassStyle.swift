import SwiftUI

// MARK: - View + glass style background

extension View {
    /// Glass background: iOS 26+ uses glassEffect(in:), otherwise falls back to .regularMaterial.
    @ViewBuilder
    func glassStyleBackground(cornerRadius: CGFloat = 12) -> some View {
        if #available(iOS 26, *) {
            self
                .glassEffect(in: .rect(cornerRadius: cornerRadius))
        } else {
            self
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
    }

    /// Glass style for bars (footer/toolbar): iOS 26+ uses glassEffect(), otherwise falls back to .bar.
    @ViewBuilder
    func glassStyleBar() -> some View {
        if #available(iOS 26, *) {
            self
                .glassEffect()
        } else {
            self
                .background(.bar)
        }
    }
}
