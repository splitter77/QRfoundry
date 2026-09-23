import Foundation

enum L10n {
    static func t(_ key: String) -> String {
        String(localized: String.LocalizationValue(key))
    }

    static var appName: String { t("app.name") }
    static var appTagline: String { t("app.tagline") }

    static var homeHeadline: String { t("home.headline") }
    static var homeSubtitle: String { t("home.subtitle") }
    static var homeRecents: String { t("home.recents") }
    static var homeClear: String { t("home.clear") }
    static var homeDelete: String { t("home.delete") }

    static var preview: String { t("editor.preview") }
    static var tabContent: String { t("editor.tab.content") }
    static var tabPage: String { t("editor.tab.page") }
    static var contentTitle: String { t("editor.content.title") }
    static var pageTitle: String { t("editor.page.title") }
    static var pageColors: String { t("editor.page.colors") }
    static var logo: String { t("editor.logo") }
    static var logoChoose: String { t("editor.logo.choose") }
    static var logoChange: String { t("editor.logo.change") }
    static var logoRemove: String { t("editor.logo.remove") }
    static var showLogo: String { t("editor.showLogo") }
    static var showGoogle: String { t("editor.showGoogle") }
    static var showStars: String { t("editor.showStars") }
    static var fieldHeadline: String { t("editor.field.headline") }
    static var fieldHeadlinePlaceholder: String { t("editor.field.headline.placeholder") }
    static var fieldSubtitle: String { t("editor.field.subtitle") }
    static var fieldSubtitlePlaceholder: String { t("editor.field.subtitle.placeholder") }
    static var fieldButton: String { t("editor.field.button") }
    static var fieldButtonPlaceholder: String { t("editor.field.button.placeholder") }
    static var colorPage: String { t("editor.color.page") }
    static var colorButton: String { t("editor.color.button") }
    static var colorText: String { t("editor.color.text") }
    static var colorQR: String { t("editor.color.qr") }
    static var colorQRBg: String { t("editor.color.qrBg") }
    static var exportCTA: String { t("editor.export") }

    static var exportTitle: String { t("export.title") }
    static var exportSubtitle: String { t("export.subtitle") }
    static var exportShare: String { t("export.share") }
    static var exportSavePhotos: String { t("export.savePhotos") }
    static var exportCopy: String { t("export.copy") }
    static var exportCopied: String { t("export.copied") }
    static var exportSaved: String { t("export.saved") }
    static var exportDenied: String { t("export.denied") }
    static var exportFailed: String { t("export.failed") }

    static func exportReady(width: CGFloat, height: CGFloat) -> String {
        "\(t("export.ready")) · \(Int(width))×\(Int(height)) px"
    }

    static var fillFields: String { t("qr.fillFields") }
}
