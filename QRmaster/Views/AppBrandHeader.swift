import SwiftUI

/// En-tête marque avec le blason Foundry.
struct AppBrandHeader: View {
    var compact: Bool = false

    var body: some View {
        HStack(spacing: compact ? 12 : 14) {
            ZStack {
                RoundedRectangle(cornerRadius: compact ? 14 : 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.12, green: 0.12, blue: 0.14),
                                Color(red: 0.22, green: 0.20, blue: 0.18)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: compact ? 52 : 68, height: compact ? 52 : 68)
                    .overlay(
                        RoundedRectangle(cornerRadius: compact ? 14 : 18, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.85, green: 0.68, blue: 0.28).opacity(0.9),
                                        Color(red: 0.55, green: 0.45, blue: 0.20).opacity(0.5)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.2
                            )
                    )
                    .shadow(color: Color(red: 0.85, green: 0.55, blue: 0.15).opacity(0.25), radius: 10, y: 4)

                Image("AppLogo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: compact ? 44 : 58, height: compact ? 44 : 58)
                    .clipShape(RoundedRectangle(cornerRadius: compact ? 11 : 14, style: .continuous))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(L10n.appName)
                    .font(compact ? .headline.weight(.bold) : .title3.weight(.bold))
                    .foregroundStyle(AppTheme.ink)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)

                Text(L10n.appTagline.uppercased())
                    .font(.caption.weight(.semibold))
                    .tracking(1.1)
                    .foregroundStyle(Color(red: 0.72, green: 0.55, blue: 0.18))
            }

            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(L10n.appName). \(L10n.appTagline)")
    }
}
