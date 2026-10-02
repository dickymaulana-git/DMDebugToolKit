import SwiftUI

enum DebugUIStyle {

    // MARK: - Layout

    static let screenPadding: CGFloat = 12
    static let sectionSpacing: CGFloat = 10

    static let rowHorizontalPadding: CGFloat = 12
    static let rowVerticalPadding: CGFloat = 7

    static let cardRadius: CGFloat = 12
    static let graphHeight: CGFloat = 140


    // MARK: - Typography

    static let sectionTitle: Font = .system(
        size: 14,
        weight: .semibold
    )

    static let body: Font = .system(
        size: 13
    )

    static let bodyMedium: Font = .system(
        size: 13,
        weight: .medium
    )

    static let caption: Font = .system(
        size: 11
    )

    static let captionMedium: Font = .system(
        size: 11,
        weight: .medium
    )


    // MARK: - Colors

    /// Main accent used throughout the toolkit.
    static let accent = Color(
        red: 0.35,
        green: 0.32,
        blue: 0.95
    )

    static let accentSoft = accent.opacity(0.12)


    /// Information / neutral action.
    static let info = Color(
        red: 0.20,
        green: 0.48,
        blue: 0.95
    )


    /// Healthy / successful state.
    static let success = Color(
        red: 0.16,
        green: 0.72,
        blue: 0.48
    )


    /// Warning state.
    static let warning = Color(
        red: 0.95,
        green: 0.60,
        blue: 0.18
    )


    /// Critical / error state.
    static let critical = Color(
        red: 0.94,
        green: 0.30,
        blue: 0.35
    )


    /// Graph color.
    static let graph = accent


    // MARK: - Backgrounds

    static let cardBackground =
        Color.primary.opacity(0.055)

    static let secondaryBackground =
        Color.primary.opacity(0.035)

    static let highlightedBackground =
        accent.opacity(0.08)


    // MARK: - Row

    static func rowBackground(
        index: Int
    ) -> Color {
        if index.isMultiple(of: 2) {
            return Color.primary.opacity(0.025)
        }

        return accent.opacity(0.045)
    }


    // MARK: - Status

    static func statusColor(
        _ statusCode: Int?
    ) -> Color {

        guard let statusCode else {
            return .secondary
        }

        if statusCode >= 500 {
            return critical
        }

        if statusCode >= 400 {
            return warning
        }

        if statusCode >= 200 &&
            statusCode < 300 {
            return success
        }

        return info
    }
}
