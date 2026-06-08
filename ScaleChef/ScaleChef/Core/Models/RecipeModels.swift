import Foundation

enum IngredientType: String, CaseIterable {
    case standard
    case leavening
    case yeast
    case egg
    case spice
    case fat
    case acid
}

enum AdjustmentType: String {
    case linear
    case subLinear
    case rounded
    case unitPromoted
}

enum PanShape: String, CaseIterable {
    case round = "Round"
    case square = "Square"
    case rectangle = "Rectangle"
    case loafPan = "Loaf Pan"
}

enum RecipeCategory: String {
    case baking = "Baking"
    case cooking = "Cooking"
}

struct Ingredient: Identifiable {
    let id = UUID()
    var quantity: Double
    var unit: String
    var name: String
    var originalLine: String
}

struct ScaledIngredient: Identifiable {
    let id = UUID()
    let original: Ingredient
    let scaledQuantity: Double
    let scaledUnit: String
    let adjustmentType: AdjustmentType
    let note: String?
}

struct ParsedRecipe: Equatable {
    var name: String
    var originalServings: Int
    var ingredients: [Ingredient]
    var category: RecipeCategory
    var instructions: [String]

    static func == (lhs: ParsedRecipe, rhs: ParsedRecipe) -> Bool {
        lhs.name == rhs.name && lhs.originalServings == rhs.originalServings
    }
}

struct ScaledRecipe {
    let original: ParsedRecipe
    let desiredServings: Int
    let scaleFactor: Double
    let scaledIngredients: [ScaledIngredient]
}
