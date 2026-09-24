import StoreKit
import SwiftUI

struct PaywallView: View {
    @Environment(SubscriptionManager.self) private var subscriptions
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPlan: SubscriptionPlan = .yearly
    @State private var isPurchasing = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundGradient.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 22) {
                        header
                        benefits
                        plans
                        cta
                        footerLinks

                        if let error = subscriptions.purchaseError {
                            Text(error)
                                .font(.footnote)
                                .foregroundStyle(.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 16)
                    .padding(.bottom, 28)
                }
            }
            .navigationTitle(L10n.t("paywall.nav"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.t("paywall.close")) { dismiss() }
                }
            }
            .task {
                await subscriptions.refreshProducts()
                if subscriptions.product(for: selectedPlan) == nil,
                   let first = subscriptions.sortedPlans().first(where: { subscriptions.product(for: $0) != nil }) {
                    selectedPlan = first
                }
            }
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            Image("AppLogo")
                .resizable()
                .scaledToFill()
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: AppTheme.shadow, radius: 10, y: 4)

            Text(L10n.t("paywall.title"))
                .font(.title2.weight(.bold))
                .foregroundStyle(AppTheme.ink)
                .multilineTextAlignment(.center)

            Text(L10n.t("paywall.subtitle"))
                .font(.subheadline)
                .foregroundStyle(AppTheme.inkSecondary)
                .multilineTextAlignment(.center)
        }
    }

    private var benefits: some View {
        VStack(alignment: .leading, spacing: 10) {
            benefitRow("square.and.arrow.up", L10n.t("paywall.benefit.export"))
            benefitRow("photo", L10n.t("paywall.benefit.photos"))
            benefitRow("clock.arrow.circlepath", L10n.t("paywall.benefit.history"))
            benefitRow("paintpalette", L10n.t("paywall.benefit.style"))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ThemeCard(cornerRadius: 18))
    }

    private func benefitRow(_ icon: String, _ text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(AppTheme.brand)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(AppTheme.ink)
            Spacer()
        }
    }

    private var plans: some View {
        VStack(spacing: 10) {
            ForEach(subscriptions.sortedPlans()) { plan in
                planRow(plan)
            }

            if subscriptions.products.isEmpty && !subscriptions.isLoading {
                Text(L10n.t("paywall.products.missing"))
                    .font(.footnote)
                    .foregroundStyle(AppTheme.inkSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }
        }
    }

    private func planRow(_ plan: SubscriptionPlan) -> some View {
        let product = subscriptions.product(for: plan)
        let selected = selectedPlan == plan

        return Button {
            selectedPlan = plan
        } label: {
            HStack(spacing: 12) {
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(selected ? AppTheme.brand : AppTheme.inkTertiary)

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(plan.title)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(AppTheme.ink)
                        if let badge = plan.badge {
                            Text(badge)
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(AppTheme.brand))
                        }
                    }
                    Text(plan.subtitle)
                        .font(.caption)
                        .foregroundStyle(AppTheme.inkSecondary)
                }

                Spacer()

                Text(product?.displayPrice ?? "—")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.ink)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppTheme.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(selected ? AppTheme.brand : AppTheme.fieldBorder, lineWidth: selected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(product == nil)
        .opacity(product == nil ? 0.55 : 1)
    }

    private var cta: some View {
        Button {
            Task { await buySelected() }
        } label: {
            HStack {
                if isPurchasing || subscriptions.isLoading {
                    ProgressView()
                        .tint(.white)
                }
                Text(L10n.t("paywall.cta"))
                    .font(.headline)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(LinearGradient(colors: [AppTheme.brand, AppTheme.brandDeep], startPoint: .leading, endPoint: .trailing))
            )
        }
        .disabled(isPurchasing || subscriptions.product(for: selectedPlan) == nil)
    }

    private var footerLinks: some View {
        VStack(spacing: 10) {
            Button(L10n.t("paywall.restore")) {
                Task { await subscriptions.restore() }
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(AppTheme.brand)

            Text(L10n.t("paywall.legal"))
                .font(.caption2)
                .foregroundStyle(AppTheme.inkTertiary)
                .multilineTextAlignment(.center)
        }
    }

    private func buySelected() async {
        guard let product = subscriptions.product(for: selectedPlan) else { return }
        isPurchasing = true
        let ok = await subscriptions.purchase(product)
        isPurchasing = false
        if ok { dismiss() }
    }
}
