import SwiftUI

struct BakersPercentView: View {
    let recipe: ParsedRecipe
    @State private var viewModel = BakersPercentViewModel()
    @Environment(PurchaseService.self) private var purchaseService
    @State private var showPaywall = false

    init(recipe: ParsedRecipe) {
        self.recipe = recipe
    }

    var body: some View {
        ScrollView {
            VStack(spacing: SCSpace.lg) {
                summaryCards
                ingredientsTable
            }
            .padding(.horizontal, SCSpace.md)
            .padding(.top, SCSpace.md)
        }
        .background(Color.scBackground)
        .navigationTitle("Baker's %")
        .onAppear {
            if !purchaseService.isPremium {
                showPaywall = true
            } else {
                viewModel.setIngredients(from: recipe)
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    private var summaryCards: some View {
        HStack(spacing: SCSpace.md) {
            SummaryCard(title: "Total Flour", value: String(format: "%.0fg", viewModel.totalFlourWeight), color: Color.scPrimary)
            SummaryCard(title: "Hydration", value: String(format: "%.0f%%", viewModel.hydration), color: Color.scSecondary)
            SummaryCard(title: "Total %", value: String(format: "%.0f%%", viewModel.totalPercentage), color: Color.scWarning)
        }
    }

    private var ingredientsTable: some View {
        VStack(alignment: .leading, spacing: SCSpace.sm) {
            Text("Ingredients")
                .font(SCFont.title2)
                .foregroundStyle(Color.scTextPrimary)

            HStack {
                Text("Ingredient").font(SCFont.caption).foregroundStyle(Color.scTextSecondary)
                Spacer()
                Text("Weight").font(SCFont.caption).foregroundStyle(Color.scTextSecondary).frame(width: 60)
                Text("Baker's %").font(SCFont.caption).foregroundStyle(Color.scTextSecondary).frame(width: 70)
            }
            .padding(.horizontal, SCSpace.md)

            ForEach(viewModel.ingredients) { item in
                HStack {
                    Text(item.name)
                        .font(SCFont.body)
                        .foregroundStyle(Color.scTextPrimary)
                        .lineLimit(1)
                    Spacer()
                    Text(String(format: "%.0fg", item.weight))
                        .font(SCFont.body)
                        .foregroundStyle(Color.scTextSecondary)
                        .frame(width: 60)
                    Text(String(format: "%.1f%%", item.percentage))
                        .font(SCFont.headline)
                        .foregroundStyle(item.name.lowercased().contains("flour") ? Color.scPrimary : Color.scTextPrimary)
                        .frame(width: 70)
                }
                .padding(SCSpace.md)
                .background(Color.scSurface)
                .cornerRadius(10)
            }
        }
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: SCSpace.xs) {
            Text(title)
                .font(SCFont.caption)
                .foregroundStyle(Color.scTextSecondary)
            Text(value)
                .font(SCFont.title2)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
        .padding(SCSpace.md)
        .background(Color.scSurface)
        .cornerRadius(12)
    }
}
