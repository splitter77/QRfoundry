import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.06)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 320)
                    .accessibilityLabel(L10n.appName)

                // Texte sous le logo pour la version FR (le visuel EN reste dans l’image)
                Text(L10n.appName)
                    .font(.footnote.weight(.semibold))
                    .tracking(1.2)
                    .foregroundStyle(Color.white.opacity(0.55))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Text(L10n.appTagline)
                    .font(.caption)
                    .foregroundStyle(Color(red: 0.85, green: 0.68, blue: 0.28).opacity(0.9))
            }
            .padding(.horizontal, 28)
        }
    }
}
