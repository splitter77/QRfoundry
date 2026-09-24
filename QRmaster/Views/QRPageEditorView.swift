import PhotosUI
import SwiftUI
import UIKit

struct QRPageEditorView: View {
    let type: QRCodeType

    @State private var draft = QRDraft()
    @State private var style: QRPageStyle
    @State private var tab: EditorTab = .content
    @State private var photoItem: PhotosPickerItem?
    @State private var showExport = false

    private var model: BrandedPageModel {
        draft.brandedModel(type: type, style: style)
    }

    private var isValid: Bool { draft.isValid(for: type) }

    init(type: QRCodeType) {
        self.type = type
        _style = State(initialValue: .defaults(for: type))
    }

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        preview
                        tabPicker

                        Group {
                            if tab == .content {
                                contentCard
                            } else {
                                pageCard
                            }
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 8)
                    .padding(.bottom, 110)
                }

                exportBar
            }
        }
        .navigationTitle(type.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Image("AppLogo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 28, height: 28)
                    .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                    .accessibilityHidden(true)
            }
        }
        .toolbarBackground(AppTheme.background.opacity(0.92), for: .navigationBar)
        .navigationDestination(isPresented: $showExport) {
            QRExportView(
                model: model,
                displayTitle: draft.displayTitle(for: type),
                saveToHistory: true
            )
        }
        .onChange(of: photoItem) { _, newItem in
            Task { await loadLogo(from: newItem) }
        }
    }

    private var preview: some View {
        VStack(spacing: 12) {
            ScreenshotShield {
                BrandedQRPageView(model: model, qrSize: 118, compact: true)
                    .environment(\.colorScheme, .light)
            }
            .frame(height: 340)

            Text(L10n.preview)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppTheme.inkSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(ThemeCard(cornerRadius: 24))
    }

    private var tabPicker: some View {
        HStack(spacing: 6) {
            ForEach(EditorTab.allCases) { item in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { tab = item }
                } label: {
                    Text(item.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(tab == item ? AppTheme.ink : AppTheme.inkSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(tab == item ? AppTheme.segmentSelected : Color.clear)
                                .shadow(color: tab == item ? AppTheme.shadow : .clear, radius: 6, y: 2)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(5)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppTheme.segment)
        )
    }

    private var contentCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            ThemedSectionLabel(title: L10n.contentTitle, systemImage: type.systemImage, color: type.accent)
            QRDraftEditor(type: type, draft: $draft)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ThemeCard(cornerRadius: 20))
    }

    private var pageCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            ThemedSectionLabel(title: L10n.pageTitle)

            logoPicker

            ThemedField(L10n.fieldHeadlinePlaceholder, text: $style.headline, title: L10n.fieldHeadline)
            ThemedField(L10n.fieldSubtitlePlaceholder, text: $style.subtitle, title: L10n.fieldSubtitle)
            ThemedField(L10n.fieldButtonPlaceholder, text: $style.buttonText, title: L10n.fieldButton)

            themedToggle(L10n.showLogo, isOn: $style.showLogo)

            if type == .googleReview {
                themedToggle(L10n.showGoogle, isOn: $style.showGoogleWordmark)
                themedToggle(L10n.showStars, isOn: $style.showStars)
            }

            Divider().overlay(AppTheme.fieldBorder)

            Text(L10n.t("qr.style.section"))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.ink)

            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.t("qr.module.title"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.inkSecondary)
                Picker(L10n.t("qr.module.title"), selection: $style.moduleStyle) {
                    ForEach(QRModuleStyle.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
                .pickerStyle(.segmented)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.t("qr.frame.title"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.inkSecondary)
                Picker(L10n.t("qr.frame.title"), selection: $style.frameStyle) {
                    ForEach(QRFrameStyle.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
                .pickerStyle(.menu)
            }

            if style.frameStyle != .none {
                colorRow(L10n.t("qr.frame.color"), selection: $style.frameColor)
            }

            Divider().overlay(AppTheme.fieldBorder)

            Text(L10n.pageColors)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.ink)

            colorRow(L10n.colorPage, selection: $style.pageBackground)
            colorRow(L10n.colorButton, selection: $style.accentColor)
            colorRow(L10n.colorText, selection: $style.textColor)
            colorRow(L10n.colorQR, selection: $style.qrForeground)
            colorRow(L10n.colorQRBg, selection: $style.qrBackground)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ThemeCard(cornerRadius: 20))
    }

    private var logoPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L10n.logo)
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.inkSecondary)

            HStack(spacing: 14) {
                Group {
                    if let logo = style.logoImage {
                        Image(uiImage: logo)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image(systemName: "photo.badge.plus")
                            .font(.title2)
                            .foregroundStyle(AppTheme.inkSecondary)
                    }
                }
                .frame(width: 64, height: 64)
                .background(AppTheme.field)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(AppTheme.fieldBorder, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 8) {
                    PhotosPicker(selection: $photoItem, matching: .images) {
                        Text(style.logoData == nil ? L10n.logoChoose : L10n.logoChange)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppTheme.brand)
                    }

                    if style.logoData != nil {
                        Button(L10n.logoRemove) {
                            style.logoData = nil
                            photoItem = nil
                        }
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.red)
                    }
                }
            }
        }
    }

    private var exportBar: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [AppTheme.backgroundSecondary.opacity(0), AppTheme.backgroundSecondary],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 16)

            Button {
                guard isValid else { return }
                showExport = true
            } label: {
                Text(L10n.exportCTA)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: isValid
                                        ? [AppTheme.brand, AppTheme.brandDeep]
                                        : [AppTheme.inkTertiary, AppTheme.inkTertiary],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: isValid ? AppTheme.brand.opacity(0.3) : .clear, radius: 10, y: 4)
                    )
            }
            .disabled(!isValid)
            .padding(.horizontal, 18)
            .padding(.bottom, 12)
            .background(AppTheme.backgroundSecondary)
        }
    }

    private func themedToggle(_ title: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            Text(title)
                .foregroundStyle(AppTheme.ink)
        }
        .tint(AppTheme.brand)
    }

    private func colorRow(_ title: String, selection: Binding<Color>) -> some View {
        ColorPicker(selection: selection, supportsOpacity: false) {
            Text(title)
                .foregroundStyle(AppTheme.ink)
        }
    }

    private func loadLogo(from item: PhotosPickerItem?) async {
        guard let item else { return }
        if let data = try? await item.loadTransferable(type: Data.self) {
            await MainActor.run {
                style.logoData = compressedLogoData(data)
            }
        }
    }

    private func compressedLogoData(_ data: Data) -> Data? {
        guard let image = UIImage(data: data) else { return data }
        let maxSide: CGFloat = 800
        let ratio = min(maxSide / max(image.size.width, 1), maxSide / max(image.size.height, 1), 1)
        let size = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)
        let renderer = UIGraphicsImageRenderer(size: size)
        let resized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        return resized.jpegData(compressionQuality: 0.85) ?? data
    }
}

private enum EditorTab: String, CaseIterable, Identifiable {
    case content
    case page

    var id: String { rawValue }

    var title: String {
        switch self {
        case .content: return L10n.tabContent
        case .page: return L10n.tabPage
        }
    }
}
