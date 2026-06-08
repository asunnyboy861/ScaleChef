import SwiftUI

@Observable
final class URLImportViewModel {
    var urlText = ""
    var isLoading = false
    var errorMessage: String?
    var importedRecipe: ParsedRecipe?

    private let importService: RecipeImportServiceProtocol

    init(importService: RecipeImportServiceProtocol = RecipeImportService()) {
        self.importService = importService
    }

    func importRecipe() async {
        guard let url = URL(string: urlText.trimmingCharacters(in: .whitespaces)), url.scheme != nil else {
            errorMessage = "Please enter a valid URL."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let recipe = try await importService.fetchAndParse(url: url)
            importedRecipe = recipe
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
