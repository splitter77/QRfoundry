import Foundation

struct QRDraft {
    var url = ""
    var wifiSSID = ""
    var wifiPassword = ""
    var wifiSecurity: WiFiSecurity = .wpa
    var wifiHidden = false
    var text = ""
    var email = ""
    var emailSubject = ""
    var emailBody = ""
    var phone = ""
    var smsNumber = ""
    var smsMessage = ""
    var firstName = ""
    var lastName = ""
    var contactPhone = ""
    var contactEmail = ""
    var organization = ""
    var businessName = ""
    var googleReviewLink = ""

    func payload(for type: QRCodeType) -> String {
        switch type {
        case .url:
            return QRPayloadBuilder.url(url)
        case .wifi:
            return QRPayloadBuilder.wifi(
                ssid: wifiSSID,
                password: wifiPassword,
                security: wifiSecurity,
                hidden: wifiHidden
            )
        case .text:
            return QRPayloadBuilder.text(text)
        case .email:
            return QRPayloadBuilder.email(address: email, subject: emailSubject, body: emailBody)
        case .phone:
            return QRPayloadBuilder.phone(phone)
        case .sms:
            return QRPayloadBuilder.sms(number: smsNumber, message: smsMessage)
        case .contact:
            return QRPayloadBuilder.contact(
                firstName: firstName,
                lastName: lastName,
                phone: contactPhone,
                email: contactEmail,
                organization: organization
            )
        case .googleReview:
            return QRPayloadBuilder.googleReview(linkOrPlaceID: googleReviewLink)
        }
    }

    func isValid(for type: QRCodeType) -> Bool {
        switch type {
        case .url: return !url.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .wifi: return !wifiSSID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .text: return !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .email: return email.contains("@")
        case .phone: return !phone.filter({ !$0.isWhitespace }).isEmpty
        case .sms: return !smsNumber.filter({ !$0.isWhitespace }).isEmpty
        case .contact:
            return !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                || !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                || !contactPhone.isEmpty
                || !contactEmail.isEmpty
        case .googleReview:
            return !googleReviewLink.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    func displayTitle(for type: QRCodeType) -> String {
        let business = businessName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !business.isEmpty { return business }

        switch type {
        case .url: return url.isEmpty ? type.title : url
        case .wifi: return wifiSSID.isEmpty ? type.title : wifiSSID
        case .text:
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? type.title : String(trimmed.prefix(40))
        case .email: return email.isEmpty ? type.title : email
        case .phone: return phone.isEmpty ? type.title : phone
        case .sms: return smsNumber.isEmpty ? type.title : smsNumber
        case .contact:
            let name = [firstName, lastName].filter { !$0.isEmpty }.joined(separator: " ")
            return name.isEmpty ? type.title : name
        case .googleReview:
            return type.title
        }
    }

    func brandedModel(type: QRCodeType, style: QRPageStyle) -> BrandedPageModel {
        BrandedPageModel(
            type: type,
            payload: payload(for: type),
            businessName: businessName.trimmingCharacters(in: .whitespacesAndNewlines),
            style: style
        )
    }
}
