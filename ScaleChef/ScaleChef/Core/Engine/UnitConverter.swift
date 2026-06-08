import Foundation

struct UnitConverter {

    static let volumeConversions: [String: Double] = [
        "tsp": 1.0, "teaspoon": 1.0, "teaspoons": 1.0,
        "tbsp": 3.0, "tablespoon": 3.0, "tablespoons": 3.0,
        "cup": 48.0, "cups": 48.0,
        "fl oz": 6.0, "fluid ounce": 6.0,
        "ml": 0.2029, "milliliter": 0.2029, "milliliters": 0.2029,
        "l": 202.9, "liter": 202.9, "liters": 202.9,
    ]

    static let weightConversions: [String: Double] = [
        "g": 1.0, "gram": 1.0, "grams": 1.0,
        "kg": 1000.0, "kilogram": 1000.0,
        "oz": 28.35, "ounce": 28.35, "ounces": 28.35,
        "lb": 453.6, "pound": 453.6, "pounds": 453.6,
    ]

    static let ingredientWeights: [String: Double] = [
        "flour": 120.0, "sugar": 200.0, "brown sugar": 200.0,
        "powdered sugar": 120.0, "butter": 227.0, "cocoa": 85.0,
        "honey": 340.0, "maple syrup": 320.0, "milk": 240.0,
        "heavy cream": 240.0, "water": 240.0, "oil": 218.0,
        "cornstarch": 120.0, "oats": 80.0, "rice": 185.0,
        "chocolate chips": 170.0, "nuts": 120.0, "salt": 273.0,
        "baking powder": 180.0, "baking soda": 220.0, "yeast": 200.0,
    ]

    static func convert(quantity: Double, from unit: String, to targetUnit: String, ingredient: String? = nil) -> Double? {
        let fromLower = unit.lowercased()
        let toLower = targetUnit.lowercased()

        if let fromVol = volumeConversions[fromLower], let toVol = volumeConversions[toLower] {
            return quantity * fromVol / toVol
        }

        if let fromWt = weightConversions[fromLower], let toWt = weightConversions[toLower] {
            return quantity * fromWt / toWt
        }

        if let ingredientName = ingredient?.lowercased(),
           let cupWeight = ingredientWeights[ingredientName] {
            let isFromVolume = volumeConversions[fromLower] != nil
            let isToWeight = weightConversions[toLower] != nil
            let isFromWeight = weightConversions[fromLower] != nil
            let isToVolume = volumeConversions[toLower] != nil

            if isFromVolume && isToWeight {
                let tspEquiv = quantity * (volumeConversions[fromLower] ?? 1)
                let cupsEquiv = tspEquiv / 48.0
                return cupsEquiv * cupWeight / (weightConversions[toLower] ?? 1)
            }

            if isFromWeight && isToVolume {
                let grams = quantity * (weightConversions[fromLower] ?? 1)
                let cups = grams / cupWeight
                return cups * 48.0 / (volumeConversions[toLower] ?? 1)
            }
        }

        return nil
    }

    static func celsiusToFahrenheit(_ celsius: Double) -> Double {
        return celsius * 9 / 5 + 32
    }

    static func fahrenheitToCelsius(_ fahrenheit: Double) -> Double {
        return (fahrenheit - 32) * 5 / 9
    }
}
