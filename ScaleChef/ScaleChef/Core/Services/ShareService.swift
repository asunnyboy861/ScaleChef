import UIKit

struct ShareService {
    static func shareText(_ recipe: ScaledRecipe, from viewController: UIViewController?) {
        var text = "\(recipe.original.name)\n"
        text += "Serves \(recipe.desiredServings) (scaled from \(recipe.original.originalServings))\n\n"
        text += "Ingredients:\n"
        for item in recipe.scaledIngredients {
            let qty = FractionFormatter.format(item.scaledQuantity)
            text += "\(qty) \(item.scaledUnit) \(item.original.name)\n"
            if let note = item.note {
                text += "  (\(note))\n"
            }
        }
        if !recipe.original.instructions.isEmpty {
            text += "\nInstructions:\n"
            for (i, step) in recipe.original.instructions.enumerated() {
                text += "\(i + 1). \(step)\n"
            }
        }

        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = viewController?.view
            popover.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
        }
        viewController?.present(activityVC, animated: true)
    }
}
