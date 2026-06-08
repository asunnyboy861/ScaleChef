import SwiftUI

@Observable
final class PanCalculatorViewModel {
    var originalShape: PanShape = .round
    var originalDim1: Double = 9
    var originalDim2: Double = 13
    var newShape: PanShape = .round
    var newDim1: Double = 8
    var newDim2: Double = 8
    var calculatedFactor: Double = 1.0

    func calculate() {
        calculatedFactor = PanCalculator.scaleFactor(
            originalShape: originalShape,
            originalDim1: originalDim1,
            originalDim2: originalShape == .rectangle || originalShape == .loafPan ? originalDim2 : nil,
            newShape: newShape,
            newDim1: newDim1,
            newDim2: newShape == .rectangle || newShape == .loafPan ? newDim2 : nil
        )
    }

    var originalArea: Double {
        PanCalculator.calculateArea(shape: originalShape, dim1: originalDim1, dim2: originalShape == .rectangle || originalShape == .loafPan ? originalDim2 : nil)
    }

    var newArea: Double {
        PanCalculator.calculateArea(shape: newShape, dim1: newDim1, dim2: newShape == .rectangle || newShape == .loafPan ? newDim2 : nil)
    }

    var needsOriginalDim2: Bool {
        originalShape == .rectangle || originalShape == .loafPan
    }

    var needsNewDim2: Bool {
        newShape == .rectangle || newShape == .loafPan
    }
}
