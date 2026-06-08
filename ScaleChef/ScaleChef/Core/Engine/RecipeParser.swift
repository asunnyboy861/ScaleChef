import Foundation

final class RecipeParser {

    func parse(_ text: String) -> ParsedRecipe {
        let lines = text.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }

        var name = ""
        var servings = 4
        var ingredients: [Ingredient] = []
        var instructions: [String] = []
        var inIngredients = false
        var inInstructions = false

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if let s = detectServings(trimmed) {
                servings = s
                continue
            }

            if let ingredient = parseIngredientLine(trimmed) {
                ingredients.append(ingredient)
                inIngredients = true
                continue
            }

            if isSectionHeader(trimmed) {
                let lower = trimmed.lowercased()
                if lower.contains("ingredient") { inIngredients = true; inInstructions = false }
                else if lower.contains("instruction") || lower.contains("direction") || lower.contains("step") { inInstructions = true; inIngredients = false }
                continue
            }

            if inInstructions && !trimmed.isEmpty {
                instructions.append(trimmed)
            }

            if name.isEmpty && !inIngredients && !inInstructions {
                name = trimmed
            }
        }

        let category = detectCategory(ingredients: ingredients)

        return ParsedRecipe(
            name: name,
            originalServings: servings,
            ingredients: ingredients,
            category: category,
            instructions: instructions
        )
    }

    private func detectServings(_ line: String) -> Int? {
        let patterns = [
            "serves\\s+(\\d+)",
            "servings?\\s*:?\\s*(\\d+)",
            "for\\s+(\\d+)\\s+(people|persons|servings)",
            "yields?\\s*:?\\s*(\\d+)",
            "makes?\\s+(\\d+)"
        ]
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
               let range = Range(match.range(at: 1), in: line),
               let num = Int(line[range]) {
                return num
            }
        }
        return nil
    }

    private func parseIngredientLine(_ line: String) -> Ingredient? {
        let pattern = #"^(\d+\s+\d+/\d+|\d+/\d+|\d+\.?\d*|\u{00BD}|\u{00BC}|\u{00BE}|\u{2153}|\u{2154})\s*(cup|cups|tbsp|tablespoon|tablespoons|tsp|teaspoon|teaspoons|oz|ounce|ounces|lb|pound|pounds|g|gram|grams|kg|ml|liter|liters|l|pinch|clove|cloves|piece|pieces|can|cans|stick|sticks|scoop|scoots)?\s*(.*)"#

        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) else {
            return nil
        }

        let quantityStr = extractGroup(match, at: 1, in: line) ?? ""
        let unit = extractGroup(match, at: 2, in: line) ?? ""
        let name = extractGroup(match, at: 3, in: line) ?? ""

        guard let quantity = parseQuantity(quantityStr), !name.isEmpty else {
            return nil
        }

        return Ingredient(
            quantity: quantity,
            unit: unit.isEmpty ? "piece" : unit,
            name: name.trimmingCharacters(in: .whitespaces),
            originalLine: line
        )
    }

    private func parseQuantity(_ str: String) -> Double? {
        if str.contains(" ") && str.contains("/") {
            let parts = str.split(separator: " ")
            guard parts.count == 2,
                  let whole = Double(parts[0]),
                  let fraction = parseFraction(String(parts[1])) else { return nil }
            return whole + fraction
        }
        if str.contains("/") {
            return parseFraction(str)
        }
        let unicodeFractions: [String: Double] = ["\u{00BD}": 0.5, "\u{00BC}": 0.25, "\u{00BE}": 0.75, "\u{2153}": 0.333, "\u{2154}": 0.667]
        if let val = unicodeFractions[str] { return val }
        return Double(str)
    }

    private func parseFraction(_ str: String) -> Double? {
        let parts = str.split(separator: "/")
        guard parts.count == 2,
              let num = Double(parts[0]),
              let den = Double(parts[1]),
              den != 0 else { return nil }
        return num / den
    }

    private func detectCategory(ingredients: [Ingredient]) -> RecipeCategory {
        let names = ingredients.map { $0.name.lowercased() }.joined(separator: " ")
        let hasFlour = names.contains("flour")
        let hasLeavening = names.contains("baking powder") || names.contains("baking soda") || names.contains("yeast")
        let hasSugar = names.contains("sugar") || names.contains("honey") || names.contains("maple")

        if hasFlour && (hasLeavening || hasSugar) {
            return .baking
        }
        return .cooking
    }

    private func isSectionHeader(_ line: String) -> Bool {
        let lower = line.lowercased()
        let headers = ["ingredients", "instructions", "directions", "method", "preparation", "steps"]
        return headers.contains(where: { lower.contains($0) }) && line.count < 50
    }

    private func extractGroup(_ match: NSTextCheckingResult, at idx: Int, in string: String) -> String? {
        guard let range = Range(match.range(at: idx), in: string) else { return nil }
        return String(string[range])
    }
}
