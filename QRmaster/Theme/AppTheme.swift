import SwiftUI
import UIKit

/// Palette professionnelle adaptive (clair / sombre).
enum AppTheme {
    // MARK: - Brand (bleu slate pro)
    static let brand = adaptive(
        light: UIColor(red: 0.15, green: 0.39, blue: 0.92, alpha: 1),   // #2563EB
        dark: UIColor(red: 0.38, green: 0.58, blue: 0.98, alpha: 1)     // #6094FA
    )
    static let brandDeep = adaptive(
        light: UIColor(red: 0.12, green: 0.29, blue: 0.72, alpha: 1),
        dark: UIColor(red: 0.28, green: 0.48, blue: 0.92, alpha: 1)
    )

    // MARK: - Surfaces
    static let background = adaptive(
        light: UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1),   // #F5F7FA
        dark: UIColor(red: 0.07, green: 0.09, blue: 0.12, alpha: 1)     // #12171F
    )
    static let backgroundSecondary = adaptive(
        light: UIColor(red: 0.93, green: 0.94, blue: 0.96, alpha: 1),
        dark: UIColor(red: 0.10, green: 0.12, blue: 0.16, alpha: 1)
    )
    static let card = adaptive(
        light: UIColor.white,
        dark: UIColor(red: 0.13, green: 0.15, blue: 0.20, alpha: 1)     // #212633
    )
    static let field = adaptive(
        light: UIColor(red: 0.94, green: 0.95, blue: 0.97, alpha: 1),   // #F0F2F7
        dark: UIColor(red: 0.18, green: 0.20, blue: 0.26, alpha: 1)     // #2E3442
    )
    static let fieldBorder = adaptive(
        light: UIColor(red: 0.86, green: 0.88, blue: 0.92, alpha: 1),
        dark: UIColor(red: 0.28, green: 0.31, blue: 0.38, alpha: 1)
    )
    static let segment = adaptive(
        light: UIColor(red: 0.90, green: 0.92, blue: 0.95, alpha: 1),
        dark: UIColor(red: 0.16, green: 0.18, blue: 0.24, alpha: 1)
    )
    static let segmentSelected = adaptive(
        light: UIColor.white,
        dark: UIColor(red: 0.22, green: 0.25, blue: 0.32, alpha: 1)
    )

    // MARK: - Text (contraste AA)
    static let ink = adaptive(
        light: UIColor(red: 0.10, green: 0.12, blue: 0.16, alpha: 1),   // #1A1F29
        dark: UIColor(red: 0.95, green: 0.96, blue: 0.98, alpha: 1)     // #F2F4F8
    )
    static let inkSecondary = adaptive(
        light: UIColor(red: 0.40, green: 0.44, blue: 0.52, alpha: 1),   // #667085
        dark: UIColor(red: 0.68, green: 0.72, blue: 0.78, alpha: 1)     // #ADB8C7
    )
    static let inkTertiary = adaptive(
        light: UIColor(red: 0.55, green: 0.58, blue: 0.65, alpha: 1),
        dark: UIColor(red: 0.52, green: 0.56, blue: 0.64, alpha: 1)
    )
    static let placeholder = adaptive(
        light: UIColor(red: 0.55, green: 0.58, blue: 0.65, alpha: 1),
        dark: UIColor(red: 0.55, green: 0.58, blue: 0.66, alpha: 1)
    )

    static let shadow = adaptive(
        light: UIColor(red: 0.15, green: 0.20, blue: 0.35, alpha: 0.10),
        dark: UIColor(red: 0, green: 0, blue: 0, alpha: 0.35)
    )

    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [background, backgroundSecondary],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // Compat anciens noms
    static var backgroundTop: Color { background }
    static var backgroundBottom: Color { backgroundSecondary }
    static var brandDeepCompat: Color { brandDeep }

    private static func adaptive(light: UIColor, dark: UIColor) -> Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? dark : light
        })
    }
}

struct ThemeCard: View {
    var cornerRadius: CGFloat = 20

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(AppTheme.card)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(AppTheme.fieldBorder.opacity(0.7), lineWidth: 1)
            )
            .shadow(color: AppTheme.shadow, radius: 12, y: 4)
    }
}

typealias PastelCardBackground = ThemeCard

/// Champ texte lisible en clair et sombre.
struct ThemedField: View {
    let title: String?
    let placeholder: String
    @Binding var text: String
    var axis: Axis = .horizontal
    var lineLimit: ClosedRange<Int>? = nil
    var isSecure: Bool = false

    init(
        _ placeholder: String,
        text: Binding<String>,
        title: String? = nil,
        axis: Axis = .horizontal,
        lineLimit: ClosedRange<Int>? = nil,
        isSecure: Bool = false
    ) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.axis = axis
        self.lineLimit = lineLimit
        self.isSecure = isSecure
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let title {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.inkSecondary)
            }

            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else if axis == .vertical {
                    TextField(placeholder, text: $text, axis: .vertical)
                        .lineLimit(lineLimit ?? 3...6)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .foregroundStyle(AppTheme.ink)
            .tint(AppTheme.brand)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(AppTheme.field)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(AppTheme.fieldBorder, lineWidth: 1)
                    )
            )
        }
    }
}

struct ThemedSectionLabel: View {
    let title: String
    var systemImage: String? = nil
    var color: Color = AppTheme.brand

    var body: some View {
        Group {
            if let systemImage {
                Label(title, systemImage: systemImage)
            } else {
                Text(title)
            }
        }
        .font(.headline)
        .foregroundStyle(color)
    }
}
