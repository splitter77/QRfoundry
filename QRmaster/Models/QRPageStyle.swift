import SwiftUI
import UIKit

struct QRPageStyle: Equatable {
    var logoData: Data?
    var headline: String
    var subtitle: String
    var buttonText: String
    var showLogo: Bool
    var showStars: Bool
    var showGoogleWordmark: Bool
    var pageBackground: Color
    var accentColor: Color
    var qrForeground: Color
    var qrBackground: Color
    var textColor: Color
    var moduleStyle: QRModuleStyle
    var frameStyle: QRFrameStyle
    var frameColor: Color

    var logoImage: UIImage? {
        guard let logoData else { return nil }
        return UIImage(data: logoData)
    }

    private static let printInk = Color(red: 0.12, green: 0.14, blue: 0.18)
    private static let printPaper = Color.white
    private static let printQR = Color(red: 0.08, green: 0.09, blue: 0.12)

    static func defaults(for type: QRCodeType) -> QRPageStyle {
        switch type {
        case .url:
            return base(
                headline: L10n.t("page.url.headline"),
                subtitle: L10n.t("page.url.subtitle"),
                buttonText: L10n.t("page.url.button"),
                accent: Color(red: 0.15, green: 0.39, blue: 0.92)
            )
        case .wifi:
            return base(
                headline: L10n.t("page.wifi.headline"),
                subtitle: L10n.t("page.wifi.subtitle"),
                buttonText: L10n.t("page.wifi.button"),
                accent: Color(red: 0.05, green: 0.52, blue: 0.52)
            )
        case .text:
            return base(
                headline: L10n.t("page.text.headline"),
                subtitle: L10n.t("page.text.subtitle"),
                buttonText: L10n.t("page.text.button"),
                accent: Color(red: 0.40, green: 0.30, blue: 0.75)
            )
        case .email:
            return base(
                headline: L10n.t("page.email.headline"),
                subtitle: L10n.t("page.email.subtitle"),
                buttonText: L10n.t("page.email.button"),
                accent: Color(red: 0.78, green: 0.26, blue: 0.32)
            )
        case .phone:
            return base(
                headline: L10n.t("page.phone.headline"),
                subtitle: L10n.t("page.phone.subtitle"),
                buttonText: L10n.t("page.phone.button"),
                accent: Color(red: 0.12, green: 0.55, blue: 0.35)
            )
        case .sms:
            return base(
                headline: L10n.t("page.sms.headline"),
                subtitle: L10n.t("page.sms.subtitle"),
                buttonText: L10n.t("page.sms.button"),
                accent: Color(red: 0.82, green: 0.42, blue: 0.12)
            )
        case .contact:
            return base(
                headline: L10n.t("page.contact.headline"),
                subtitle: L10n.t("page.contact.subtitle"),
                buttonText: L10n.t("page.contact.button"),
                accent: Color(red: 0.25, green: 0.38, blue: 0.65)
            )
        case .googleReview:
            return QRPageStyle(
                logoData: nil,
                headline: L10n.t("page.google.headline"),
                subtitle: L10n.t("page.google.subtitle"),
                buttonText: L10n.t("page.google.button"),
                showLogo: true,
                showStars: true,
                showGoogleWordmark: true,
                pageBackground: printPaper,
                accentColor: Color(red: 0.20, green: 0.42, blue: 0.92),
                qrForeground: .black,
                qrBackground: printPaper,
                textColor: printInk,
                moduleStyle: .square,
                frameStyle: .rounded,
                frameColor: printQR
            )
        }
    }

    private static func base(
        headline: String,
        subtitle: String,
        buttonText: String,
        accent: Color
    ) -> QRPageStyle {
        QRPageStyle(
            logoData: nil,
            headline: headline,
            subtitle: subtitle,
            buttonText: buttonText,
            showLogo: true,
            showStars: false,
            showGoogleWordmark: false,
            pageBackground: printPaper,
            accentColor: accent,
            qrForeground: printQR,
            qrBackground: printPaper,
            textColor: printInk,
            moduleStyle: .square,
            frameStyle: .none,
            frameColor: printQR
        )
    }
}

struct BrandedPageModel {
    let type: QRCodeType
    let payload: String
    let businessName: String
    var style: QRPageStyle
}
