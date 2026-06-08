import Foundation

protocol RecipeImportServiceProtocol {
    func fetchAndParse(url: URL) async throws -> ParsedRecipe
}

final class RecipeImportService: RecipeImportServiceProtocol {
    private let parser = RecipeParser()

    func fetchAndParse(url: URL) async throws -> ParsedRecipe {
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let html = String(data: data, encoding: .utf8) else {
            throw ImportError.invalidHTML
        }

        if let recipe = parseSchema(html: html, url: url) {
            return recipe
        }

        return parseHeuristic(html: html, url: url)
    }

    private func parseSchema(html: String, url: URL) -> ParsedRecipe? {
        let pattern = #"<script[^>]*type=["']application/ld\+json["'][^>]*>([\s\S]*?)</script>"#

        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else { return nil }
        let range = NSRange(html.startIndex..., in: html)
        let matches = regex.matches(in: html, range: range)

        for match in matches {
            guard let jsonRange = Range(match.range(at: 1), in: html) else { continue }
            let jsonString = String(html[jsonRange])

            guard let jsonData = jsonString.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: jsonData) else { continue }

            if let recipeDict = extractRecipe(from: json) {
                return dictToRecipe(recipeDict, url: url)
            }
        }
        return nil
    }

    private func extractRecipe(from json: Any) -> [String: Any]? {
        if let dict = json as? [String: Any] {
            if dict["@type"] as? String == "Recipe" {
                return dict
            }
            if let graph = dict["@graph"] as? [[String: Any]] {
                return graph.first { $0["@type"] as? String == "Recipe" }
            }
        }
        if let array = json as? [[String: Any]] {
            return array.first { $0["@type"] as? String == "Recipe" }
        }
        return nil
    }

    private func dictToRecipe(_ dict: [String: Any], url: URL) -> ParsedRecipe {
        let name = dict["name"] as? String ?? url.host ?? "Imported Recipe"
        let servings = dict["recipeYield"] as? Int ?? 4

        var ingredients: [Ingredient] = []
        if let ingredientList = dict["recipeIngredient"] as? [String] {
            for line in ingredientList {
                if let ingredient = parser.parse(line.trimmingCharacters(in: .whitespaces)).ingredients.first {
                    ingredients.append(ingredient)
                } else {
                    ingredients.append(Ingredient(quantity: 1, unit: "piece", name: line, originalLine: line))
                }
            }
        }

        var instructions: [String] = []
        if let stepList = dict["recipeInstructions"] as? [[String: Any]] {
            for step in stepList {
                if let text = step["text"] as? String {
                    instructions.append(text)
                }
            }
        }

        let category = detectCategory(ingredients: ingredients)
        return ParsedRecipe(name: name, originalServings: servings, ingredients: ingredients, category: category, instructions: instructions)
    }

    private func parseHeuristic(html: String, url: URL) -> ParsedRecipe {
        let title = extractTitle(from: html)

        var ingredientLines: [String] = []
        let selectors = [
            #"class="[^"]*ingredient[^"]*""#,
            #"itemprop="recipeIngredient""#,
            #"class="[^"]*recipe-ingredient[^"]*""#
        ]

        for selector in selectors {
            if let regex = try? NSRegularExpression(pattern: "<li[^>]*\(selector)[^>]*>([\\s\\S]*?)</li>", options: .caseInsensitive) {
                let range = NSRange(html.startIndex..., in: html)
                let matches = regex.matches(in: html, range: range)
                for match in matches {
                    if let textRange = Range(match.range(at: 1), in: html) {
                        let text = stripHTMLTags(String(html[textRange]))
                        if !text.isEmpty { ingredientLines.append(text) }
                    }
                }
                if !ingredientLines.isEmpty { break }
            }
        }

        var ingredients: [Ingredient] = []
        for line in ingredientLines {
            if let ingredient = parser.parse(line).ingredients.first {
                ingredients.append(ingredient)
            } else {
                ingredients.append(Ingredient(quantity: 1, unit: "piece", name: line, originalLine: line))
            }
        }

        let category = detectCategory(ingredients: ingredients)
        return ParsedRecipe(
            name: title,
            originalServings: 4,
            ingredients: ingredients,
            category: category,
            instructions: []
        )
    }

    private func extractTitle(from html: String) -> String {
        let pattern = "<title[^>]*>([\\s\\S]*?)</title>"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
              let range = Range(match.range(at: 1), in: html) else {
            return "Imported Recipe"
        }
        return stripHTMLTags(String(html[range])).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func stripHTMLTags(_ text: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: "<[^>]+>", options: .caseInsensitive) else { return text }
        let range = NSRange(text.startIndex..., in: text)
        return regex.stringByReplacingMatches(in: text, range: range, withTemplate: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func detectCategory(ingredients: [Ingredient]) -> RecipeCategory {
        let names = ingredients.map { $0.name.lowercased() }.joined(separator: " ")
        let hasFlour = names.contains("flour")
        let hasLeavening = names.contains("baking powder") || names.contains("baking soda") || names.contains("yeast")
        let hasSugar = names.contains("sugar") || names.contains("honey")
        if hasFlour && (hasLeavening || hasSugar) { return .baking }
        return .cooking
    }
}

enum ImportError: LocalizedError {
    case invalidHTML
    case noRecipeFound

    var errorDescription: String? {
        switch self {
        case .invalidHTML: return "Could not read the webpage content."
        case .noRecipeFound: return "No recipe found on this page. Try pasting the recipe text instead."
        }
    }
}
