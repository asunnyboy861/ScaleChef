import Foundation

struct PanCalculator {

    static func calculateArea(shape: PanShape, dim1: Double, dim2: Double? = nil) -> Double {
        switch shape {
        case .round:
            let radius = dim1 / 2
            return .pi * radius * radius
        case .square:
            return dim1 * dim1
        case .rectangle:
            return dim1 * (dim2 ?? dim1)
        case .loafPan:
            return dim1 * (dim2 ?? 4.5) * 3.0
        }
    }

    static func scaleFactor(
        originalShape: PanShape, originalDim1: Double, originalDim2: Double?,
        newShape: PanShape, newDim1: Double, newDim2: Double?
    ) -> Double {
        let originalArea = calculateArea(shape: originalShape, dim1: originalDim1, dim2: originalDim2)
        let newArea = calculateArea(shape: newShape, dim1: newDim1, dim2: newDim2)
        guard originalArea > 0 else { return 1.0 }
        return newArea / originalArea
    }
}
