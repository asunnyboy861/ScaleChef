import Foundation
import CoreData

@objc(SavedRecipe)
public class SavedRecipe: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var originalServings: Int16
    @NSManaged public var desiredServings: Int16
    @NSManaged public var category: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var instructions: String?
    @NSManaged public var ingredients: NSSet?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SavedRecipe> {
        return NSFetchRequest<SavedRecipe>(entityName: "SavedRecipe")
    }
}

extension SavedRecipe {
    var ingredientsArray: [SavedIngredient] {
        (ingredients as? Set<SavedIngredient>)?.sorted(by: { $0.name ?? "" < $1.name ?? "" }) ?? []
    }
}

@objc(SavedIngredient)
public class SavedIngredient: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID?
    @NSManaged public var quantity: Double
    @NSManaged public var unit: String?
    @NSManaged public var name: String?
    @NSManaged public var originalLine: String?
    @NSManaged public var recipe: SavedRecipe?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SavedIngredient> {
        return NSFetchRequest<SavedIngredient>(entityName: "SavedIngredient")
    }
}
