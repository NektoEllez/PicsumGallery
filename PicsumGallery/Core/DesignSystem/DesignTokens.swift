import SwiftUI

enum DesignTokens {
    enum Spacing {
        static let xSmall: CGFloat = 8
        static let small: CGFloat = 12
        static let medium: CGFloat = 16
        static let large: CGFloat = 20
        static let bottomSafeSpacing: CGFloat = 8
    }

    enum Size {
        static let minimumTapTarget: CGFloat = 44
        static let thumbnailSide: CGFloat = 80
    }

    enum CornerRadius {
        static let card: CGFloat = 12
        static let button: CGFloat = 32
    }

    enum Border {
        static let subtleLineWidth: CGFloat = 0.5
    }

    enum Opacity {
        static let disabledControl: Double = 0.8
        static let subtleFill: Double = 0.1
        static let subtleStroke: Double = 0.2
        static let cardLightBackground: Double = 0.92
        static let cardDarkBorder: Double = 0.16
        static let cardLightBorder: Double = 0.06
    }

    enum Insets {
        static let photoRow = EdgeInsets(
            top: Spacing.xSmall,
            leading: Spacing.xSmall,
            bottom: Spacing.xSmall,
            trailing: Spacing.medium
        )

        static let loadMoreRow = EdgeInsets(
            top: Spacing.bottomSafeSpacing,
            leading: Spacing.medium,
            bottom: Spacing.medium,
            trailing: Spacing.medium
        )
    }
}
