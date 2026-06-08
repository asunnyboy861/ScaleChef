import SwiftUI

struct ScaleView: View {
    let recipe: ParsedRecipe
    @State private var viewModel: ScaleViewModel
    @Environment(PurchaseService.self) private var purchaseService
    @Environment(\.dismiss) private var dismiss

    init(recipe: ParsedRecipe) {
        self.recipe = recipe
        self._viewModel = State(initialValue: ScaleViewModel(recipe: recipe))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: SCSpace.lg) {
                    servingsControl
                    quickScaleButtons
                    smartAdjustmentsBanner
                    ingredientsList
                    instructionsSection
                }
                .padding(.horizontal, SCSpace.md)
                .padding(.top, SCSpace.md)
            }
            .background(Color.scBackground)
            .navigationTitle(recipe.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(action: { viewModel.saveRecipe() }) {
                            Label("Save Recipe", systemImage: "square.and.arrow.down")
                        }
                        Button(action: shareRecipe) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showPaywall) {
                PaywallView()
            }
        }
    }

    private var servingsControl: some View {
        VStack(spacing: SCSpace.sm) {
            Text("Original: \(recipe.originalServings) servings")
                .font(SCFont.caption)
                .foregroundStyle(Color.scTextSecondary)

            HStack(spacing: SCSpace.lg) {
                Button(action: viewModel.decrementServings) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title)
                        .foregroundStyle(Color.scPrimary)
                }

                VStack(spacing: 2) {
                    Text("\(viewModel.desiredServings)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(Color.scTextPrimary)
                    Text("servings")
                        .font(SCFont.caption)
                        .foregroundStyle(Color.scTextSecondary)
                }

                Button(action: viewModel.incrementServings) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundStyle(Color.scPrimary)
                }
            }

            Text(viewModel.factorLabel)
                .font(SCFont.headline)
                .foregroundStyle(Color.scSecondary)
        }
        .padding(SCSpace.lg)
        .frame(maxWidth: .infinity)
        .background(Color.scSurface)
        .cornerRadius(16)
    }

    private var quickScaleButtons: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: SCSpace.sm) {
                ForEach([0.5, 1.5, 2.0, 2.5, 3.0, 4.0], id: \.self) { factor in
                    Button(action: { viewModel.quickScale(factor) }) {
                        Text(factor == floor(factor) ? "\(Int(factor))x" : "\(factor)x")
                            .font(SCFont.headline)
                            .foregroundStyle(viewModel.scaleFactor == factor ? .white : Color.scPrimary)
                            .padding(.horizontal, SCSpace.md)
                            .padding(.vertical, SCSpace.sm)
                            .background(viewModel.scaleFactor == factor ? Color.scPrimary : Color.scPrimary.opacity(0.1))
                            .cornerRadius(20)
                    }
                }
            }
        }
    }

    private var smartAdjustmentsBanner: some View {
        Group {
            if viewModel.adjustmentCount > 0 {
                HStack(spacing: SCSpace.sm) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(Color.scWarning)
                    Text("\(viewModel.adjustmentCount) smart adjustment\(viewModel.adjustmentCount > 1 ? "s" : "")")
                        .font(SCFont.headline)
                        .foregroundStyle(Color.scTextPrimary)
                    Spacer()
                }
                .padding(SCSpace.md)
                .background(Color.scWarning.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }

    private var ingredientsList: some View {
        VStack(alignment: .leading, spacing: SCSpace.sm) {
            Text("Ingredients")
                .font(SCFont.title2)
                .foregroundStyle(Color.scTextPrimary)

            if let scaled = viewModel.scaledRecipe {
                ForEach(scaled.scaledIngredients) { item in
                    IngredientRow(scaledIngredient: item)
                }
            }
        }
    }

    private var instructionsSection: some View {
        Group {
            if !recipe.instructions.isEmpty {
                VStack(alignment: .leading, spacing: SCSpace.sm) {
                    Text("Instructions")
                        .font(SCFont.title2)
                        .foregroundStyle(Color.scTextPrimary)

                    ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: SCSpace.sm) {
                            Text("\(index + 1)")
                                .font(SCFont.caption)
                                .foregroundStyle(.white)
                                .frame(width: 24, height: 24)
                                .background(Color.scPrimary)
                                .clipShape(Circle())
                            Text(step)
                                .font(SCFont.body)
                                .foregroundStyle(Color.scTextPrimary)
                        }
                    }
                }
            }
        }
    }

    private func shareRecipe() {
        guard let scaled = viewModel.scaledRecipe else { return }
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let viewController = windowScene.windows.first?.rootViewController else { return }
        ShareService.shareText(scaled, from: viewController)
    }
}

struct IngredientRow: View {
    let scaledIngredient: ScaledIngredient

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(FractionFormatter.format(scaledIngredient.scaledQuantity))
                    .font(SCFont.headline)
                    .foregroundStyle(Color.scTextPrimary)
                Text(scaledIngredient.scaledUnit)
                    .font(SCFont.body)
                    .foregroundStyle(Color.scTextSecondary)
                Text(scaledIngredient.original.name)
                    .font(SCFont.body)
                    .foregroundStyle(Color.scTextPrimary)
                Spacer()
                adjustmentBadge
            }

            if let note = scaledIngredient.note {
                Text(note)
                    .font(SCFont.caption)
                    .foregroundStyle(Color.scWarning)
                    .padding(.leading, 4)
            }
        }
        .padding(SCSpace.md)
        .background(Color.scSurface)
        .cornerRadius(10)
    }

    @ViewBuilder
    private var adjustmentBadge: some View {
        switch scaledIngredient.adjustmentType {
        case .subLinear:
            Image(systemName: "sparkle")
                .font(.caption)
                .foregroundStyle(Color.scWarning)
        case .rounded:
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.caption)
                .foregroundStyle(Color.scSecondary)
        case .unitPromoted:
            Image(systemName: "arrow.up.right")
                .font(.caption)
                .foregroundStyle(Color.scSuccess)
        case .linear:
            EmptyView()
        }
    }
}
