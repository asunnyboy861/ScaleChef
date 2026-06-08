import SwiftUI
import CoreData

@main
struct ScaleChefApp: App {
    @State private var purchaseService = PurchaseService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(purchaseService)
                .task {
                    await purchaseService.checkPurchaseStatus()
                }
        }
    }
}
