import Foundation
import StoreKit

enum SubscriptionProductID {
    static let weekly = "com.magicsplitter.qrcodefoundry.weekly"
    static let monthly = "com.magicsplitter.qrcodefoundry.monthly"
    static let sixMonths = "com.magicsplitter.qrcodefoundry.sixmonths"
    static let yearly = "com.magicsplitter.qrcodefoundry.yearly"
    static let lifetime = "com.magicsplitter.qrcodefoundry.lifetime"

    static let all: [String] = [weekly, monthly, sixMonths, yearly, lifetime]
    static let subscriptionIDs: Set<String> = [weekly, monthly, sixMonths, yearly]
}

enum SubscriptionPlan: String, CaseIterable, Identifiable {
    case weekly
    case monthly
    case sixMonths
    case yearly
    case lifetime

    var id: String { rawValue }

    var productID: String {
        switch self {
        case .weekly: return SubscriptionProductID.weekly
        case .monthly: return SubscriptionProductID.monthly
        case .sixMonths: return SubscriptionProductID.sixMonths
        case .yearly: return SubscriptionProductID.yearly
        case .lifetime: return SubscriptionProductID.lifetime
        }
    }

    var title: String {
        switch self {
        case .weekly: return L10n.t("paywall.plan.weekly")
        case .monthly: return L10n.t("paywall.plan.monthly")
        case .sixMonths: return L10n.t("paywall.plan.sixMonths")
        case .yearly: return L10n.t("paywall.plan.yearly")
        case .lifetime: return L10n.t("paywall.plan.lifetime")
        }
    }

    var subtitle: String {
        switch self {
        case .weekly: return L10n.t("paywall.plan.weekly.sub")
        case .monthly: return L10n.t("paywall.plan.monthly.sub")
        case .sixMonths: return L10n.t("paywall.plan.sixMonths.sub")
        case .yearly: return L10n.t("paywall.plan.yearly.sub")
        case .lifetime: return L10n.t("paywall.plan.lifetime.sub")
        }
    }

    var badge: String? {
        switch self {
        case .yearly: return L10n.t("paywall.badge.best")
        case .lifetime: return L10n.t("paywall.badge.forever")
        default: return nil
        }
    }

    static func plan(for productID: String) -> SubscriptionPlan? {
        allCases.first { $0.productID == productID }
    }
}

@MainActor
@Observable
final class SubscriptionManager {
    private(set) var products: [Product] = []
    private(set) var purchasedProductIDs: Set<String> = []
    private(set) var isLoading = false
    private(set) var purchaseError: String?
    private(set) var isPremium = false

    private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = Task { await listenForTransactions() }
    }

    func start() async {
        await refreshProducts()
        await refreshEntitlements()
    }

    func product(for plan: SubscriptionPlan) -> Product? {
        products.first { $0.id == plan.productID }
    }

    func sortedPlans() -> [SubscriptionPlan] {
        SubscriptionPlan.allCases.sorted { lhs, rhs in
            sortIndex(lhs) < sortIndex(rhs)
        }
    }

    private func sortIndex(_ plan: SubscriptionPlan) -> Int {
        switch plan {
        case .weekly: return 0
        case .monthly: return 1
        case .sixMonths: return 2
        case .yearly: return 3
        case .lifetime: return 4
        }
    }

    func refreshProducts() async {
        isLoading = true
        purchaseError = nil
        defer { isLoading = false }

        do {
            let storeProducts = try await Product.products(for: SubscriptionProductID.all)
            products = storeProducts.sorted { $0.price < $1.price }
        } catch {
            purchaseError = error.localizedDescription
            products = []
        }
    }

    func purchase(_ product: Product) async -> Bool {
        isLoading = true
        purchaseError = nil
        defer { isLoading = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await refreshEntitlements()
                return true
            case .userCancelled, .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            purchaseError = error.localizedDescription
            return false
        }
    }

    func restore() async {
        isLoading = true
        purchaseError = nil
        defer { isLoading = false }

        do {
            try await AppStore.sync()
            await refreshEntitlements()
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    func refreshEntitlements() async {
        var active: Set<String> = []

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            if transaction.revocationDate != nil { continue }
            active.insert(transaction.productID)
        }

        purchasedProductIDs = active
        isPremium = active.contains(SubscriptionProductID.lifetime)
            || active.contains(where: { SubscriptionProductID.subscriptionIDs.contains($0) })
    }

    private func listenForTransactions() async {
        for await result in Transaction.updates {
            guard case .verified(let transaction) = result else { continue }
            await transaction.finish()
            await refreshEntitlements()
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    enum StoreError: Error {
        case failedVerification
    }
}
