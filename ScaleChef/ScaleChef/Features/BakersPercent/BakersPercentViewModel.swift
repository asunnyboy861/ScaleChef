import SwiftUI

@Observable
final class BakersPercentViewModel {
    var ingredients: [BakersIngredient] = []
    var totalFlourWeight: Double = 0

    struct BakersIngredient: Identifiable {
        let id = UUID()
        var name: String
        var weight: Double
        var percentage: Double
    }

    func setIngredients(from recipe: ParsedRecipe) {
        var items: [BakersIngredient] = []
        var flourWeight = 0.0

        for ing in recipe.ingredients {
            let weight: Double
            if ing.unit.lowercased() == "g" || ing.unit.lowercased() == "gram" || ing.unit.lowercased() == "grams" {
                weight = ing.quantity
            } else if let converted = UnitConverter.convert(quantity: ing.quantity, from: ing.unit, to: "g", ingredient: ing.name) {
                weight = converted
            } else {
                weight = ing.quantity
            }

            let name = ing.name.lowercased()
            if name.contains("flour") {
                flourWeight += weight
            }

            items.append(BakersIngredient(name: ing.name, weight: weight, percentage: 0))
        }

        totalFlourWeight = flourWeight

        if flourWeight > 0 {
            for i in items.indices {
                items[i].percentage = (items[i].weight / flourWeight) * 100
            }
        }

        ingredients = items
    }

    var totalPercentage: Double {
        ingredients.reduce(0) { $0 + $1.percentage }
    }

    var hydration: Double {
        let waterWeight = ingredients.filter { $0.name.lowercased().contains("water") || $0.name.lowercased().contains("milk") }.reduce(0) { $0 + $1.weight }
        guard totalFlourWeight > 0 else { return 0 }
        return (waterWeight / totalFlourWeight) * 100
    }
}
