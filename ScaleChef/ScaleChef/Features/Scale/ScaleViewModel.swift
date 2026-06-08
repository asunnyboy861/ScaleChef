import SwiftUI

@Observable
final class ScaleViewModel {
    var desiredServings: Int
    var scaleFactor: Double = 1.0
    var useFactorMode = false
    var scaledRecipe: ScaledRecipe?
    var showPaywall = false

    private let engine = ScalingEngine()
    let originalRecipe: ParsedRecipe

    init(recipe: ParsedRecipe) {
        self.originalRecipe = recipe
        self.desiredServings = recipe.originalServings
        recalculate()
    }

    func recalculate() {
        if useFactorMode {
            desiredServings = Int(Double(originalRecipe.originalServings) * scaleFactor)
        } else {
            scaleFactor = Double(desiredServings) / Double(originalRecipe.originalServings)
        }
        scaledRecipe = engine.scaleRecipe(originalRecipe, to: desiredServings)
    }

    func quickScale(_ factor: Double) {
        useFactorMode = true
        scaleFactor = factor
        recalculate()
    }

    func incrementServings() {
        desiredServings += 1
        useFactorMode = false
        recalculate()
    }

    func decrementServings() {
        if desiredServings > 1 {
            desiredServings -= 1
            useFactorMode = false
            recalculate()
        }
    }

    func canSave(isPremium: Bool) -> Bool {
        isPremium || StorageService.shared.recipeCount() < 10
    }

    func saveRecipe() {
        guard let scaled = scaledRecipe else { return }
        try? StorageService.shared.saveRecipe(originalRecipe, desiredServings: scaled.desiredServings)
    }

    var adjustmentCount: Int {
        scaledRecipe?.scaledIngredients.filter { $0.adjustmentType != .linear }.count ?? 0
    }

    var factorLabel: String {
        let f = scaleFactor
        if f == floor(f) { return "\(Int(f))x" }
        return String(format: "%.1fx", f)
    }
}
