import SwiftUI

struct SettingsView: View {
    @Environment(PurchaseService.self) private var purchaseService
    @AppStorage("useMetricUnits") private var useMetricUnits = false
    @AppStorage("showFractions") private var showFractions = true

    var body: some View {
        List {
            Section("Display") {
                Toggle("Metric Units", isOn: $useMetricUnits)
                Toggle("Show Fractions", isOn: $showFractions)
            }

            Section("Premium") {
                HStack {
                    Text("Status")
                    Spacer()
                    Text(purchaseService.isPremium ? "Premium" : "Free")
                        .foregroundStyle(purchaseService.isPremium ? Color.scSuccess : Color.scTextSecondary)
                }

                if !purchaseService.isPremium {
                    NavigationLink(destination: PaywallView()) {
                        Text("Upgrade to Premium")
                    }
                }

                Button(action: {
                    Task { await purchaseService.restorePurchases() }
                }) {
                    Text("Restore Purchases")
                }
            }

            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                        .foregroundStyle(Color.scTextSecondary)
                }
                NavigationLink(destination: ContactSupportView()) {
                    Text("Contact Support")
                }
                Link("Privacy Policy", destination: URL(string: "https://asunnyboy861.github.io/ScaleChef/privacy.html")!)
                Link("Terms of Use", destination: URL(string: "https://asunnyboy861.github.io/ScaleChef/terms.html")!)
            }
        }
        .navigationTitle("Settings")
    }
}
