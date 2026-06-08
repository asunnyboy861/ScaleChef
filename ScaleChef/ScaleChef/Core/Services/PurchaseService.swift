import Foundation
import StoreKit

@Observable
final class PurchaseService {
    var isPremium: Bool = false
    var isLoading: Bool = false

    private let productID = "com.zzoutuo.ScaleChef.premium"

    func checkPurchaseStatus() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID == productID {
                    isPremium = transaction.revocationDate == nil
                    return
                }
            }
        }
        isPremium = false
    }

    func purchase() async -> Bool {
        isLoading = true
        defer { isLoading = false }

        do {
            let products = try await Product.products(for: [productID])
            guard let product = products.first else { return false }

            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    isPremium = true
                    await transaction.finish()
                    return true
                }
            case .pending, .userCancelled:
                break
            @unknown default:
                break
            }
        } catch {
            return false
        }
        return false
    }

    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await AppStore.sync()
            await checkPurchaseStatus()
        } catch {}
    }
}
