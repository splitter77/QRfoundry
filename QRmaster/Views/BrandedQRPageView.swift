import SwiftUI
import UIKit

/// Page branding imprimable / partageable pour tous les types de QR.
struct BrandedQRPageView: View {
    let model: BrandedPageModel
    var qrSize: CGFloat = 220
    var compact: Bool = false

    private var pageWidth: CGFloat { compact ? 260 : 360 }
    private var style: QRPageStyle { model.style }

    var body: some View {
        VStack(spacing: compact ? 12 : 18) {
            if style.showLogo {
                logoSection
            }

            if !model.businessName.isEmpty {
                Text(model.businessName)
                    .font(compact ? .caption.weight(.semibold) : .subheadline.weight(.semibold))
                    .foregroundStyle(style.textColor.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }

            if !style.headline.isEmpty {
                Text(style.headline)
                    .font(compact ? .footnote.weight(.medium) : .title3.weight(.medium))
                    .foregroundStyle(style.textColor)
                    .multilineTextAlignment(.center)
            }

            if style.showGoogleWordmark {
                GoogleWordmark(fontSize: compact ? 26 : 38)
            }

            if style.showStars {
                HStack(spacing: compact ? 4 : 6) {
                    ForEach(0..<5, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: compact ? 15 : 22))
                            .foregroundStyle(Color(red: 0.98, green: 0.75, blue: 0.18))
                    }
                }
            }

            if !style.subtitle.isEmpty {
                Text(style.subtitle)
                    .font(compact ? .caption2 : .subheadline)
                    .foregroundStyle(style.textColor.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 6)
            }

            QRCodeImageView(
                payload: model.payload.isEmpty ? L10n.appName : model.payload,
                size: qrSize,
                foreground: style.qrForeground,
                background: style.qrBackground,
                moduleStyle: style.moduleStyle,
                frameStyle: style.frameStyle,
                frameColor: style.frameColor
            )
            .padding(compact ? 10 : 14)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(style.qrBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(Color.black.opacity(0.08), lineWidth: 1)
                    )
            )

            if !style.buttonText.isEmpty {
                HStack(spacing: 10) {
                    Image(systemName: model.type.systemImage)
                        .font(.system(size: compact ? 13 : 15, weight: .semibold))
                    Text(style.buttonText)
                        .font(compact ? .subheadline.weight(.bold) : .headline.weight(.bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, compact ? 12 : 15)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(style.accentColor)
                )
            }
        }
        .padding(.horizontal, compact ? 18 : 28)
        .padding(.vertical, compact ? 20 : 32)
        .frame(width: pageWidth)
        .background(
            RoundedRectangle(cornerRadius: compact ? 18 : 24, style: .continuous)
                .fill(style.pageBackground)
                .shadow(color: Color.black.opacity(0.08), radius: 16, y: 6)
        )
    }

    @ViewBuilder
    private var logoSection: some View {
        if let logo = style.logoImage {
            Image(uiImage: logo)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: compact ? 72 : 110, maxHeight: compact ? 52 : 80)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        } else {
            ZStack {
                Circle()
                    .fill(model.type.pastelFill)
                    .frame(width: compact ? 48 : 64, height: compact ? 48 : 64)
                Image(systemName: model.type.systemImage)
                    .font(.system(size: compact ? 18 : 24, weight: .semibold))
                    .foregroundStyle(model.type.accent)
            }
        }
    }
}

struct GoogleWordmark: View {
    var fontSize: CGFloat = 40

    private let letters: [(Character, Color)] = [
        ("G", Color(red: 0.26, green: 0.52, blue: 0.96)),
        ("o", Color(red: 0.92, green: 0.26, blue: 0.22)),
        ("o", Color(red: 0.98, green: 0.74, blue: 0.02)),
        ("g", Color(red: 0.26, green: 0.52, blue: 0.96)),
        ("l", Color(red: 0.20, green: 0.66, blue: 0.33)),
        ("e", Color(red: 0.92, green: 0.26, blue: 0.22))
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(letters.enumerated()), id: \.offset) { _, item in
                Text(String(item.0))
                    .font(.system(size: fontSize, weight: .medium, design: .rounded))
                    .foregroundStyle(item.1)
            }
        }
    }
}

enum BrandedPageRenderer {
    /// Export haute qualité (~3–4× densité écran).
    @MainActor
    static func render(model: BrandedPageModel, scale: CGFloat = 4) -> UIImage? {
        let exportModel = model
        let view = BrandedQRPageView(model: exportModel, qrSize: 320, compact: false)
            .frame(width: 400)
        let renderer = ImageRenderer(content: view)
        renderer.scale = scale
        return renderer.uiImage
    }
}
