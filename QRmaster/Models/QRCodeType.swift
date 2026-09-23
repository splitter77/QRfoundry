import SwiftUI
import UIKit

enum QRCodeType: String, CaseIterable, Identifiable, Codable {
    case url
    case wifi
    case text
    case email
    case phone
    case sms
    case contact
    case googleReview

    var id: String { rawValue }

    var title: String {
        switch self {
        case .url: return L10n.t("type.url.title")
        case .wifi: return L10n.t("type.wifi.title")
        case .text: return L10n.t("type.text.title")
        case .email: return L10n.t("type.email.title")
        case .phone: return L10n.t("type.phone.title")
        case .sms: return L10n.t("type.sms.title")
        case .contact: return L10n.t("type.contact.title")
        case .googleReview: return L10n.t("type.google.title")
        }
    }

    var subtitle: String {
        switch self {
        case .url: return L10n.t("type.url.subtitle")
        case .wifi: return L10n.t("type.wifi.subtitle")
        case .text: return L10n.t("type.text.subtitle")
        case .email: return L10n.t("type.email.subtitle")
        case .phone: return L10n.t("type.phone.subtitle")
        case .sms: return L10n.t("type.sms.subtitle")
        case .contact: return L10n.t("type.contact.subtitle")
        case .googleReview: return L10n.t("type.google.subtitle")
        }
    }

    var systemImage: String {
        switch self {
        case .url: return "link"
        case .wifi: return "wifi"
        case .text: return "text.alignleft"
        case .email: return "envelope"
        case .phone: return "phone"
        case .sms: return "message"
        case .contact: return "person.crop.rectangle"
        case .googleReview: return "star.bubble.fill"
        }
    }

    var accent: Color {
        switch self {
        case .url:
            return Palette.adaptive(
                light: UIColor(red: 0.15, green: 0.39, blue: 0.92, alpha: 1),
                dark: UIColor(red: 0.45, green: 0.62, blue: 1.0, alpha: 1)
            )
        case .wifi:
            return Palette.adaptive(
                light: UIColor(red: 0.05, green: 0.55, blue: 0.55, alpha: 1),
                dark: UIColor(red: 0.35, green: 0.82, blue: 0.78, alpha: 1)
            )
        case .text:
            return Palette.adaptive(
                light: UIColor(red: 0.42, green: 0.30, blue: 0.78, alpha: 1),
                dark: UIColor(red: 0.72, green: 0.62, blue: 0.98, alpha: 1)
            )
        case .email:
            return Palette.adaptive(
                light: UIColor(red: 0.82, green: 0.28, blue: 0.35, alpha: 1),
                dark: UIColor(red: 0.98, green: 0.55, blue: 0.58, alpha: 1)
            )
        case .phone:
            return Palette.adaptive(
                light: UIColor(red: 0.12, green: 0.58, blue: 0.35, alpha: 1),
                dark: UIColor(red: 0.45, green: 0.85, blue: 0.58, alpha: 1)
            )
        case .sms:
            return Palette.adaptive(
                light: UIColor(red: 0.85, green: 0.45, blue: 0.12, alpha: 1),
                dark: UIColor(red: 1.0, green: 0.70, blue: 0.40, alpha: 1)
            )
        case .contact:
            return Palette.adaptive(
                light: UIColor(red: 0.28, green: 0.40, blue: 0.68, alpha: 1),
                dark: UIColor(red: 0.62, green: 0.72, blue: 0.95, alpha: 1)
            )
        case .googleReview:
            return Palette.adaptive(
                light: UIColor(red: 0.20, green: 0.42, blue: 0.92, alpha: 1),
                dark: UIColor(red: 0.50, green: 0.65, blue: 1.0, alpha: 1)
            )
        }
    }

    var pastelFill: Color {
        accent.opacity(0.16)
    }
}

private enum Palette {
    static func adaptive(light: UIColor, dark: UIColor) -> Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? dark : light
        })
    }
}

enum WiFiSecurity: String, CaseIterable, Identifiable {
    case wpa = "WPA"
    case wep = "WEP"
    case none = "nopass"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .wpa: return L10n.t("wifi.wpa")
        case .wep: return L10n.t("wifi.wep")
        case .none: return L10n.t("wifi.none")
        }
    }
}

struct QRPayloadBuilder {
    static func url(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "" }
        if trimmed.lowercased().hasPrefix("http://") || trimmed.lowercased().hasPrefix("https://") {
            return trimmed
        }
        return "https://\(trimmed)"
    }

    static func wifi(ssid: String, password: String, security: WiFiSecurity, hidden: Bool) -> String {
        let ssidEscaped = escapeWiFi(ssid)
        let passwordEscaped = escapeWiFi(password)
        let hiddenFlag = hidden ? "true" : "false"
        if security == .none {
            return "WIFI:T:nopass;S:\(ssidEscaped);H:\(hiddenFlag);;"
        }
        return "WIFI:T:\(security.rawValue);S:\(ssidEscaped);P:\(passwordEscaped);H:\(hiddenFlag);;"
    }

    static func text(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func email(address: String, subject: String, body: String) -> String {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = address.trimmingCharacters(in: .whitespacesAndNewlines)
        var queryItems: [URLQueryItem] = []
        if !subject.isEmpty { queryItems.append(URLQueryItem(name: "subject", value: subject)) }
        if !body.isEmpty { queryItems.append(URLQueryItem(name: "body", value: body)) }
        if !queryItems.isEmpty { components.queryItems = queryItems }
        return components.string ?? "mailto:\(address)"
    }

    static func phone(_ number: String) -> String {
        "tel:\(number.filter { !$0.isWhitespace })"
    }

    static func sms(number: String, message: String) -> String {
        let clean = number.filter { !$0.isWhitespace }
        if message.isEmpty {
            return "SMSTO:\(clean)"
        }
        return "SMSTO:\(clean):\(message)"
    }

    static func contact(firstName: String, lastName: String, phone: String, email: String, organization: String) -> String {
        let fullName = [firstName, lastName]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        var lines = [
            "BEGIN:VCARD",
            "VERSION:3.0",
            "N:\(lastName);\(firstName);;;",
            "FN:\(fullName)"
        ]
        if !organization.isEmpty { lines.append("ORG:\(organization)") }
        if !phone.isEmpty { lines.append("TEL:\(phone.filter { !$0.isWhitespace })") }
        if !email.isEmpty { lines.append("EMAIL:\(email.trimmingCharacters(in: .whitespacesAndNewlines))") }
        lines.append("END:VCARD")
        return lines.joined(separator: "\n")
    }

    /// Accepte un lien d’avis Google ou un Place ID.
    static func googleReview(linkOrPlaceID: String) -> String {
        let trimmed = linkOrPlaceID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "" }

        if trimmed.lowercased().hasPrefix("http://") || trimmed.lowercased().hasPrefix("https://") {
            return trimmed
        }

        // Place ID Google (commence souvent par ChIJ…)
        if trimmed.hasPrefix("ChIJ") || trimmed.count > 20 && !trimmed.contains(" ") {
            return "https://search.google.com/local/writereview?placeid=\(trimmed)"
        }

        return url(trimmed)
    }

    private static func escapeWiFi(_ value: String) -> String {
        value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: ";", with: "\\;")
            .replacingOccurrences(of: ",", with: "\\,")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: ":", with: "\\:")
    }
}
