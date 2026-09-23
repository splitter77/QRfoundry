import SwiftUI

struct QRDraftEditor: View {
    let type: QRCodeType
    @Binding var draft: QRDraft

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ThemedField(
                L10n.t("field.business.placeholder"),
                text: $draft.businessName,
                title: L10n.t("field.business")
            )

            switch type {
            case .url:
                ThemedField("https://exemple.com", text: $draft.url, title: L10n.t("field.url"))
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

            case .wifi:
                ThemedField(
                    L10n.t("field.ssid.placeholder"),
                    text: $draft.wifiSSID,
                    title: L10n.t("field.ssid")
                )
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

                VStack(alignment: .leading, spacing: 6) {
                    Text(L10n.t("field.security"))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.inkSecondary)
                    Picker(L10n.t("field.security"), selection: $draft.wifiSecurity) {
                        ForEach(WiFiSecurity.allCases) { security in
                            Text(security.label).tag(security)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                if draft.wifiSecurity != .none {
                    ThemedField(
                        L10n.t("field.password"),
                        text: $draft.wifiPassword,
                        title: L10n.t("field.password"),
                        isSecure: true
                    )
                }

                Toggle(isOn: $draft.wifiHidden) {
                    Text(L10n.t("field.hiddenNetwork"))
                        .foregroundStyle(AppTheme.ink)
                }
                .tint(AppTheme.brand)

            case .text:
                ThemedField(
                    L10n.t("field.message.placeholder"),
                    text: $draft.text,
                    title: L10n.t("field.message"),
                    axis: .vertical,
                    lineLimit: 3...8
                )

            case .email:
                ThemedField("name@example.com", text: $draft.email, title: L10n.t("field.email"))
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                ThemedField(L10n.t("field.subject"), text: $draft.emailSubject, title: L10n.t("field.subject"))
                ThemedField(
                    L10n.t("field.body"),
                    text: $draft.emailBody,
                    title: L10n.t("field.body"),
                    axis: .vertical,
                    lineLimit: 2...5
                )

            case .phone:
                ThemedField("+33 6 12 34 56 78", text: $draft.phone, title: L10n.t("field.phone"))
                    .keyboardType(.phonePad)

            case .sms:
                ThemedField(L10n.t("field.phone"), text: $draft.smsNumber, title: L10n.t("field.phone"))
                    .keyboardType(.phonePad)
                ThemedField(
                    L10n.t("field.body"),
                    text: $draft.smsMessage,
                    title: L10n.t("field.body"),
                    axis: .vertical,
                    lineLimit: 2...5
                )

            case .contact:
                ThemedField(L10n.t("field.firstName"), text: $draft.firstName, title: L10n.t("field.firstName"))
                ThemedField(L10n.t("field.lastName"), text: $draft.lastName, title: L10n.t("field.lastName"))
                ThemedField(L10n.t("field.organization"), text: $draft.organization, title: L10n.t("field.organization"))
                ThemedField(L10n.t("field.phone"), text: $draft.contactPhone, title: L10n.t("field.phone"))
                    .keyboardType(.phonePad)
                ThemedField(L10n.t("field.email"), text: $draft.contactEmail, title: L10n.t("field.email"))
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

            case .googleReview:
                ThemedField(
                    L10n.t("field.googleLink.placeholder"),
                    text: $draft.googleReviewLink,
                    title: L10n.t("field.googleLink")
                )
                .keyboardType(.URL)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

                Text(L10n.t("field.google.hint"))
                    .font(.caption)
                    .foregroundStyle(AppTheme.inkSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
