import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(PurchaseService.self) private var purchaseService
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: SCSpace.xl) {
                    headerSection
                    featuresList
                    purchaseButton
                    restoreButton
                    legalLinks
                }
                .padding(.horizontal, SCSpace.md)
                .padding(.top, SCSpace.xl)
            }
            .background(Color.scBackground)
            .navigationTitle("ScaleChef Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: SCSpace.sm) {
            Image(systemName: "chef.hat")
                .font(.system(size: 60))
                .foregroundStyle(Color.scPrimary)

            Text("Unlock Full Power")
                .font(SCFont.title1)
                .foregroundStyle(Color.scTextPrimary)

            Text("One-time purchase. Yours forever.")
                .font(SCFont.body)
                .foregroundStyle(Color.scTextSecondary)
        }
    }

    private var featuresList: some View {
        VStack(spacing: SCSpace.md) {
            PremiumFeatureRow(icon: "sparkles", title: "Smart Scaling", description: "Baking-aware adjustments for leavening, yeast & spices")
            PremiumFeatureRow(icon: "square.grid.2x2", title: "Pan Calculator", description: "Convert between any pan size & shape")
            PremiumFeatureRow(icon: "percent", title: "Baker's Percentage", description: "Professional hydration & formula analysis")
            PremiumFeatureRow(icon: "link", title: "URL Import", description: "Import recipes from any website")
            PremiumFeatureRow(icon: "square.and.arrow.down", title: "Unlimited Saves", description: "Save as many recipes as you want")
        }
        .padding(SCSpace.md)
        .background(Color.scSurface)
        .cornerRadius(16)
    }

    private var purchaseButton: some View {
        Button(action: {
            Task {
                if await purchaseService.purchase() {
                    dismiss()
                }
            }
        }) {
            HStack(spacing: SCSpace.sm) {
                if purchaseService.isLoading {
                    ProgressView().tint(.white)
                }
                Text(purchaseService.isLoading ? "Processing..." : "Unlock Premium — $3.99")
                    .font(SCFont.title2)
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(SCSpace.lg)
            .background(Color.scPrimary)
            .cornerRadius(16)
        }
        .disabled(purchaseService.isLoading)
    }

    private var restoreButton: some View {
        Button(action: {
            Task { await purchaseService.restorePurchases() }
        }) {
            Text("Restore Purchases")
                .font(SCFont.headline)
                .foregroundStyle(Color.scSecondary)
        }
    }

    private var legalLinks: some View {
        HStack(spacing: SCSpace.md) {
            Link("Privacy Policy", destination: URL(string: "https://asunnyboy861.github.io/ScaleChef/privacy")!)
            Text("|")
            Link("Terms of Use", destination: URL(string: "https://asunnyboy861.github.io/ScaleChef/terms")!)
        }
        .font(SCFont.caption)
        .foregroundStyle(Color.scTextSecondary)
    }
}

struct PremiumFeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: SCSpace.md) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.scPrimary)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(SCFont.headline)
                    .foregroundStyle(Color.scTextPrimary)
                Text(description)
                    .font(SCFont.caption)
                    .foregroundStyle(Color.scTextSecondary)
            }
        }
    }
}
