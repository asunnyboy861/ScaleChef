import SwiftUI

@Observable
final class HomeViewModel {
    var pastedText = ""
    var parsedRecipe: ParsedRecipe?
    var recentRecipes: [SavedRecipe] = []
    var showScaleView = false
    var showURLImport = false
    var parseError: String?

    private let parser = RecipeParser()
    private let storage = StorageService.shared

    func loadRecentRecipes() {
        recentRecipes = storage.fetchRecipes()
    }

    func parsePastedText() {
        guard !pastedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            parseError = "Please paste or type a recipe first."
            return
        }
        let recipe = parser.parse(pastedText)
        if recipe.ingredients.isEmpty {
            parseError = "Could not detect any ingredients. Try pasting the ingredient list."
            return
        }
        parsedRecipe = recipe
        parseError = nil
        showScaleView = true
    }

    func loadSavedRecipe(_ saved: SavedRecipe) {
        parsedRecipe = storage.toParsedRecipe(saved)
        showScaleView = true
    }

    func canSaveRecipe(isPremium: Bool) -> Bool {
        isPremium || storage.recipeCount() < 10
    }
}
