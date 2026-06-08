import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @Environment(PurchaseService.self) private var purchaseService

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: SCSpace.lg) {
                    pasteSection
                    urlImportButton
                    recentRecipesSection
                    quickScaleSection
                }
                .padding(.horizontal, SCSpace.md)
                .padding(.top, SCSpace.md)
            }
            .background(Color.scBackground)
            .navigationTitle("ScaleChef")
            .onAppear { viewModel.loadRecentRecipes() }
            .sheet(isPresented: $viewModel.showScaleView) {
                if let recipe = viewModel.parsedRecipe {
                    ScaleView(recipe: recipe)
                }
            }
            .sheet(isPresented: $viewModel.showURLImport) {
                URLImportView { recipe in
                    viewModel.parsedRecipe = recipe
                    viewModel.showScaleView = true
                }
            }
        }
    }

    private var pasteSection: some View {
        VStack(alignment: .leading, spacing: SCSpace.sm) {
            Text("Paste Your Recipe")
                .font(SCFont.headline)
                .foregroundStyle(Color.scTextPrimary)

            TextEditor(text: $viewModel.pastedText)
                .frame(minHeight: 120)
                .padding(SCSpace.sm)
                .background(Color.scSurface)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.scPrimary.opacity(0.3), lineWidth: 1)
                )
                .overlay(alignment: .topLeading) {
                    if viewModel.pastedText.isEmpty {
                        Text("Paste recipe text here...")
                            .font(SCFont.body)
                            .foregroundStyle(Color.scTextSecondary)
                            .padding(SCSpace.md)
                            .allowsHitTesting(false)
                    }
                }

            if let error = viewModel.parseError {
                Text(error)
                    .font(SCFont.caption)
                    .foregroundStyle(Color.scError)
            }

            Button(action: { viewModel.parsePastedText() }) {
                Text("Scale Recipe")
                    .font(SCFont.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(SCSpace.md)
                    .background(Color.scPrimary)
                    .cornerRadius(12)
            }
        }
    }

    private var urlImportButton: some View {
        Button(action: { viewModel.showURLImport = true }) {
            HStack {
                Image(systemName: "link")
                    .foregroundStyle(Color.scPrimary)
                Text("Import from URL")
                    .font(SCFont.headline)
                    .foregroundStyle(Color.scPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.scTextSecondary)
            }
            .padding(SCSpace.md)
            .background(Color.scSurface)
            .cornerRadius(12)
        }
    }

    private var recentRecipesSection: some View {
        VStack(alignment: .leading, spacing: SCSpace.sm) {
            if !viewModel.recentRecipes.isEmpty {
                Text("Recent Recipes")
                    .font(SCFont.headline)
                    .foregroundStyle(Color.scTextPrimary)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: SCSpace.sm) {
                        ForEach(viewModel.recentRecipes.prefix(10), id: \.id) { recipe in
                            Button(action: { viewModel.loadSavedRecipe(recipe) }) {
                                RecipeCard(recipe: recipe)
                            }
                        }
                    }
                }
            }
        }
    }

    private var quickScaleSection: some View {
        VStack(alignment: .leading, spacing: SCSpace.sm) {
            Text("Quick Scale")
                .font(SCFont.headline)
                .foregroundStyle(Color.scTextPrimary)

            HStack(spacing: SCSpace.sm) {
                ForEach(["0.5x", "1.5x", "2x", "3x"], id: \.self) { label in
                    Button(action: {}) {
                        Text(label)
                            .font(SCFont.headline)
                            .foregroundStyle(Color.scPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(SCSpace.sm)
                            .background(Color.scPrimary.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            }
        }
    }
}

struct RecipeCard: View {
    let recipe: SavedRecipe

    var body: some View {
        VStack(alignment: .leading, spacing: SCSpace.xs) {
            Image(systemName: "book.closed")
                .font(.title2)
                .foregroundStyle(Color.scPrimary)
            Text(recipe.name ?? "Recipe")
                .font(SCFont.headline)
                .foregroundStyle(Color.scTextPrimary)
                .lineLimit(1)
            Text("\(recipe.originalServings) servings")
                .font(SCFont.caption)
                .foregroundStyle(Color.scTextSecondary)
        }
        .padding(SCSpace.md)
        .frame(width: 120)
        .background(Color.scSurface)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}
