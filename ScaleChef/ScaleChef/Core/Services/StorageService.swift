import Foundation
import CoreData

final class StorageService {
    static let shared = StorageService()

    private init() {}

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ScaleChefModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("CoreData error: \(error)")
            }
        }
        return container
    }()

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    func saveRecipe(_ recipe: ParsedRecipe, desiredServings: Int) throws {
        let entity = SavedRecipe(context: context)
        entity.id = UUID()
        entity.name = recipe.name
        entity.originalServings = Int16(recipe.originalServings)
        entity.desiredServings = Int16(desiredServings)
        entity.category = recipe.category.rawValue
        entity.createdAt = Date()
        entity.instructions = recipe.instructions.joined(separator: "\n")

        for ingredient in recipe.ingredients {
            let ingEntity = SavedIngredient(context: context)
            ingEntity.id = UUID()
            ingEntity.quantity = ingredient.quantity
            ingEntity.unit = ingredient.unit
            ingEntity.name = ingredient.name
            ingEntity.originalLine = ingredient.originalLine
            ingEntity.recipe = entity
        }

        try context.save()
    }

    func fetchRecipes() -> [SavedRecipe] {
        let request = SavedRecipe.fetchRequest() as! NSFetchRequest<SavedRecipe>
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return (try? context.fetch(request)) ?? []
    }

    func deleteRecipe(_ recipe: SavedRecipe) {
        context.delete(recipe)
        try? context.save()
    }

    func recipeCount() -> Int {
        let request = SavedRecipe.fetchRequest() as! NSFetchRequest<SavedRecipe>
        return (try? context.count(for: request)) ?? 0
    }

    func toParsedRecipe(_ saved: SavedRecipe) -> ParsedRecipe {
        var ingredients: [Ingredient] = []
        if let savedIngredients = saved.ingredients as? Set<SavedIngredient> {
            for si in savedIngredients {
                ingredients.append(Ingredient(
                    quantity: si.quantity,
                    unit: si.unit ?? "piece",
                    name: si.name ?? "",
                    originalLine: si.originalLine ?? ""
                ))
            }
        }
        return ParsedRecipe(
            name: saved.name ?? "",
            originalServings: Int(saved.originalServings),
            ingredients: ingredients,
            category: RecipeCategory(rawValue: saved.category ?? "Cooking") ?? .cooking,
            instructions: (saved.instructions ?? "").components(separatedBy: "\n")
        )
    }
}
