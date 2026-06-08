import Foundation

final class ScalingEngine {

    private let leaveningKeywords = [
        "baking powder", "baking soda", "bicarbonate", "cream of tartar"
    ]
    private let yeastKeywords = ["yeast", "sourdough starter", "levain"]
    private let eggKeywords = ["egg", "eggs", "egg white", "egg yolk", "egg whites", "egg yolks"]
    private let spiceKeywords = [
        "salt", "pepper", "cinnamon", "vanilla", "nutmeg", "clove", "cumin",
        "paprika", "chili", "oregano", "thyme", "rosemary", "basil"
    ]
    private let fatKeywords = ["butter", "oil", "cream", "margarine", "shortening", "lard"]
    private let acidKeywords = ["lemon juice", "vinegar", "lime juice", "wine"]

    func classifyIngredient(_ name: String) -> IngredientType {
        let lower = name.lowercased()
        if leaveningKeywords.contains(where: { lower.contains($0) }) { return .leavening }
        if yeastKeywords.contains(where: { lower.contains($0) }) { return .yeast }
        if eggKeywords.contains(where: { lower.contains($0) }) { return .egg }
        if spiceKeywords.contains(where: { lower.contains($0) }) { return .spice }
        if fatKeywords.contains(where: { lower.contains($0) }) { return .fat }
        if acidKeywords.contains(where: { lower.contains($0) }) { return .acid }
        return .standard
    }

    func scaleRecipe(_ recipe: ParsedRecipe, to desiredServings: Int) -> ScaledRecipe {
        let factor = Double(desiredServings) / Double(recipe.originalServings)
        let scaledIngredients = recipe.ingredients.map { scaleIngredient($0, factor: factor, recipeCategory: recipe.category) }
        return ScaledRecipe(
            original: recipe,
            desiredServings: desiredServings,
            scaleFactor: factor,
            scaledIngredients: scaledIngredients
        )
    }

    func scaleIngredient(
        _ ingredient: Ingredient,
        factor: Double,
        recipeCategory: RecipeCategory
    ) -> ScaledIngredient {
        let type = classifyIngredient(ingredient.name)
        let originalQty = ingredient.quantity

        let scaledQty: Double
        let adjustmentType: AdjustmentType
        let note: String?

        switch type {
        case .standard, .fat:
            scaledQty = originalQty * factor
            adjustmentType = .linear
            note = nil

        case .leavening:
            if factor <= 2.0 {
                scaledQty = originalQty * pow(factor, 0.8)
            } else {
                let doublings = log2(factor)
                let adjustedFactor = pow(1.75, doublings)
                scaledQty = originalQty * adjustedFactor
            }
            adjustmentType = .subLinear
            note = factor > 1.5 ? "Reduced from \(FractionFormatter.format(originalQty * factor)) — leavening doesn't scale linearly" : nil

        case .yeast:
            scaledQty = originalQty * pow(factor, 0.7)
            adjustmentType = .subLinear
            note = factor > 2.0 ? "Reduced — yeast is more active in larger batches" : nil

        case .egg:
            let rawScaled = originalQty * factor
            let rounded = (rawScaled * 2).rounded() / 2
            scaledQty = rounded
            adjustmentType = .rounded
            if rounded != rawScaled && rounded.truncatingRemainder(dividingBy: 1) != 0 {
                let grams = Int(rounded * 50)
                note = "\u{2248} \(grams)g beaten egg"
            } else if rounded != rawScaled {
                note = "Rounded from \(FractionFormatter.format(rawScaled))"
            } else {
                note = nil
            }

        case .spice:
            scaledQty = originalQty * pow(factor, 0.85)
            adjustmentType = .subLinear
            note = factor > 1.5 ? "Season gradually — taste and adjust" : nil

        case .acid:
            scaledQty = originalQty * pow(factor, 0.9)
            adjustmentType = .subLinear
            note = nil
        }

        let (finalQty, finalUnit, promoted) = promoteUnit(quantity: scaledQty, unit: ingredient.unit)

        return ScaledIngredient(
            original: ingredient,
            scaledQuantity: promoted ? finalQty : scaledQty,
            scaledUnit: finalUnit,
            adjustmentType: promoted ? .unitPromoted : adjustmentType,
            note: note
        )
    }

    func panScaleFactor(
        originalShape: PanShape, originalDimension1: Double, originalDimension2: Double?,
        newShape: PanShape, newDimension1: Double, newDimension2: Double?
    ) -> Double {
        let originalArea = calculateArea(shape: originalShape, dim1: originalDimension1, dim2: originalDimension2)
        let newArea = calculateArea(shape: newShape, dim1: newDimension1, dim2: newDimension2)
        guard originalArea > 0 else { return 1.0 }
        return newArea / originalArea
    }

    private func calculateArea(shape: PanShape, dim1: Double, dim2: Double?) -> Double {
        switch shape {
        case .round:
            let radius = dim1 / 2
            return .pi * radius * radius
        case .square:
            return dim1 * dim1
        case .rectangle:
            return dim1 * (dim2 ?? dim1)
        case .loafPan:
            return dim1 * (dim2 ?? 4.5) * 3.0
        }
    }

    private func promoteUnit(quantity: Double, unit: String) -> (Double, String, Bool) {
        let lower = unit.lowercased()

        if lower == "tsp" || lower == "teaspoon" || lower == "teaspoons" {
            if quantity >= 3 {
                let tbsp = quantity / 3
                if tbsp >= 16 {
                    return (tbsp / 16, "cup", true)
                }
                return (tbsp, "tbsp", true)
            }
        }

        if lower == "tbsp" || lower == "tablespoon" || lower == "tablespoons" {
            if quantity >= 16 {
                return (quantity / 16, "cup", true)
            }
        }

        if lower == "oz" || lower == "ounce" || lower == "ounces" {
            if quantity >= 16 {
                return (quantity / 16, "lb", true)
            }
        }

        return (quantity, unit, false)
    }
}
