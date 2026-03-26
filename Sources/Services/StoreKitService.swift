import Foundation
import StoreKit

@MainActor
final class StoreKitService: ObservableObject {
    static let shared = StoreKitService()

    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published private(set) var isLoading = false

    private let productID = "com.nostalgiabox.app.unlock"

    private init() {
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }

    var isUnlocked: Bool {
        purchasedProductIDs.contains(productID)
    }

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            products = try await Product.products(for: [productID])
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    func purchase() async throws -> Transaction? {
        guard let product = products.first(where: { $0.id == productID }) else {
            throw StoreError.productNotFound
        }

        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updatePurchasedProducts()
            await transaction.finish()
            return transaction
        case .userCancelled:
            return nil
        case .pending:
            return nil
        @unknown default:
            return nil
        }
    }

    func updatePurchasedProducts() async {
        var ids: Set<String> = []

        for await result in Transaction.currentEntitlements {
            if case .verified(let trans) = result {
                ids.insert(trans.productID)
            }
        }

        purchasedProductIDs = ids

        // Sync with backend
        if isUnlocked {
            await syncUnlockToBackend()
        }
    }

    private func syncUnlockToBackend() async {
        guard let receiptData = loadReceiptData() else { return }
        let receiptBase64 = receiptData.base64EncodedString()
        do {
            let user = try await APIService.shared.verifyReceipt(receiptData: receiptBase64)
            AppState.shared.updateFromUser(user)
        } catch {
            print("Failed to sync unlock to backend: \(error)")
        }
    }

    private func loadReceiptData() -> Data? {
        guard let url = Bundle.main.appStoreReceiptURL,
              FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }
        return try? Data(contentsOf: url)
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    func restorePurchases() async {
        try? await AppStore.sync()
        await updatePurchasedProducts()
    }

    enum StoreError: Error, LocalizedError {
        case productNotFound
        case failedVerification
        case purchaseFailed

        var errorDescription: String? {
            switch self {
            case .productNotFound: return "未找到商品"
            case .failedVerification: return "购买验证失败"
            case .purchaseFailed: return "购买失败"
            }
        }
    }
}
