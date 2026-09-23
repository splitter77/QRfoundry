import SwiftUI

struct HomeView: View {
    @Environment(QRHistoryStore.self) private var history

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundGradient.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        AppBrandHeader()
                            .padding(.top, 4)

                        header

                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(QRCodeType.allCases) { type in
                                NavigationLink {
                                    QRPageEditorView(type: type)
                                } label: {
                                    TypeCard(type: type)
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        if !history.items.isEmpty {
                            recentSection
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 8)
                    .padding(.bottom, 28)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    EmptyView()
                }
            }
            .toolbarBackground(AppTheme.background.opacity(0.92), for: .navigationBar)
        }
        .tint(AppTheme.brand)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.homeHeadline)
                .font(.title2.weight(.bold))
                .foregroundStyle(AppTheme.ink)
            Text(L10n.homeSubtitle)
                .font(.subheadline)
                .foregroundStyle(AppTheme.inkSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(L10n.homeRecents)
                    .font(.headline)
                    .foregroundStyle(AppTheme.ink)
                Spacer()
                Button(L10n.homeClear) { history.clear() }
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(AppTheme.inkSecondary)
            }

            ForEach(history.items.prefix(8)) { item in
                NavigationLink {
                    QRExportView(
                        model: BrandedPageModel(
                            type: item.type,
                            payload: item.payload,
                            businessName: item.title,
                            style: .defaults(for: item.type)
                        ),
                        displayTitle: item.title,
                        saveToHistory: false
                    )
                } label: {
                    HistoryRow(item: item)
                }
                .buttonStyle(.plain)
                .contextMenu {
                    Button(role: .destructive) {
                        history.delete(item)
                    } label: {
                        Label(L10n.homeDelete, systemImage: "trash")
                    }
                }
            }
        }
    }
}

private struct TypeCard: View {
    let type: QRCodeType

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                Circle()
                    .fill(type.pastelFill)
                    .frame(width: 40, height: 40)
                Image(systemName: type.systemImage)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(type.accent)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(type.title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(AppTheme.ink)
                Text(type.subtitle)
                    .font(.caption)
                    .foregroundStyle(AppTheme.inkSecondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 108, alignment: .topLeading)
        .padding(14)
        .background(ThemeCard(cornerRadius: 18))
    }
}

private struct HistoryRow: View {
    let item: SavedQRCode

    private var dateText: String {
        item.createdAt.formatted(date: .abbreviated, time: .shortened)
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(item.type.pastelFill)
                    .frame(width: 40, height: 40)
                Image(systemName: item.type.systemImage)
                    .foregroundStyle(item.type.accent)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.ink)
                    .lineLimit(1)
                Text("\(item.type.title) · \(dateText)")
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
}
