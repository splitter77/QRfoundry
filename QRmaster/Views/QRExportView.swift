import SwiftUI
import UIKit

struct QRExportView: View {
    let model: BrandedPageModel
    let displayTitle: String
    var saveToHistory: Bool = true

    @Environment(QRHistoryStore.self) private var history
    @Environment(SubscriptionManager.self) private var subscriptions
    @State private var showShare = false
    @State private var showPaywall = false
    @State private var saveMessage: String?
    @State private var didSaveHistory = false
    @State private var hqImage: UIImage?

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 22) {
                    VStack(spacing: 8) {
                        Text(displayTitle)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(AppTheme.ink)
                            .multilineTextAlignment(.center)
                        Text(L10n.exportSubtitle)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(model.type.accent)
                    }
                    .padding(.top, 8)

                    ScreenshotShield {
                        BrandedQRPageView(model: model, qrSize: 220, compact: false)
                            .environment(\.colorScheme, .light)
                    }
                    .frame(height: 560)

                    Text(model.payload)
                        .font(.caption2.monospaced())
                        .foregroundStyle(AppTheme.inkSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    if !subscriptions.isPremium {
                        premiumBanner
                    }

                    VStack(spacing: 12) {
                        primaryButton(title: L10n.exportShare, icon: "square.and.arrow.up") {
                            requirePremium {
                                ensureImage()
                                showShare = true
                            }
                        }

                        secondaryButton(title: L10n.exportSavePhotos, icon: "photo") {
                            requirePremium {
                                Task { await saveToPhotos() }
                            }
                        }

                        secondaryButton(title: L10n.exportCopy, icon: "doc.on.doc") {
                            UIPasteboard.general.string = model.payload
                            saveMessage = L10n.exportCopied
                        }
                    }
                    .padding(.horizontal, 20)

                    if let saveMessage {
                        Text(saveMessage)
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(AppTheme.inkSecondary)
                    }

                    if let hqImage {
                        Text(L10n.exportReady(width: hqImage.size.width, height: hqImage.size.height))
                            .font(.caption2)
                            .foregroundStyle(AppTheme.inkSecondary.opacity(0.8))
                    }
                }
                .padding(.bottom, 32)
            }
        }
        .navigationTitle(L10n.exportTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppTheme.background.opacity(0.92), for: .navigationBar)
        .sheet(isPresented: $showShare) {
            if let hqImage {
                ShareSheet(items: [hqImage, model.payload])
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
                .environment(subscriptions)
        }
        .task {
            ensureImage()
            guard saveToHistory, !didSaveHistory else { return }
            guard subscriptions.isPremium else { return }
            history.add(type: model.type, title: displayTitle, payload: model.payload)
            didSaveHistory = true
        }
        .onChange(of: subscriptions.isPremium) { _, isPremium in
            guard isPremium, saveToHistory, !didSaveHistory else { return }
            history.add(type: model.type, title: displayTitle, payload: model.payload)
            didSaveHistory = true
        }
    }

    private var premiumBanner: some View {
        Button {
            showPaywall = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "crown.fill")
                    .foregroundStyle(Color(red: 0.85, green: 0.68, blue: 0.28))
                VStack(alignment: .leading, spacing: 2) {
                    Text(L10n.t("paywall.banner.title"))
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(AppTheme.ink)
                    Text(L10n.t("paywall.banner.subtitle"))
                        .font(.caption)
                        .foregroundStyle(AppTheme.inkSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.inkTertiary)
            }
            .padding(14)
            .background(ThemeCard(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
    }

    private func requirePremium(_ action: () -> Void) {
        if subscriptions.isPremium {
            action()
        } else {
            showPaywall = true
        }
    }

    private func primaryButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.white)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(LinearGradient(colors: [AppTheme.brand, AppTheme.brandDeep], startPoint: .leading, endPoint: .trailing))
                .shadow(color: AppTheme.brand.opacity(0.3), radius: 10, y: 5)
        )
    }

    private func secondaryButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(AppTheme.ink)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppTheme.card)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(AppTheme.fieldBorder, lineWidth: 1)
                        )
                        .shadow(color: AppTheme.shadow, radius: 6, y: 2)
                )
        }
        .buttonStyle(.plain)
    }

    private func ensureImage() {
        if hqImage == nil {
            hqImage = BrandedPageRenderer.render(model: model, scale: 4)
        }
    }

    private func saveToPhotos() async {
        ensureImage()
        guard let hqImage else {
            saveMessage = L10n.exportFailed
            return
        }
        let success = await PhotoLibrarySaver.save(hqImage)
        withAnimation {
            saveMessage = success ? L10n.exportSaved : L10n.exportDenied
        }
    }
}
