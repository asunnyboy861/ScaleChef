import SwiftUI

struct FractionFormatter {

    @AppStorage("showFractions") static var showFractions = true

    static func format(_ value: Double) -> String {
        if !showFractions {
            if value == floor(value) { return "\(Int(value))" }
            return String(format: "%.1f", value)
        }

        let whole = Int(value)
        let fraction = value - Double(whole)

        if abs(fraction) < 0.01 { return "\(whole)" }

        let closest = findClosestFraction(fraction)

        if whole > 0 {
            return "\(whole)\(closest.symbol)"
        } else {
            return closest.symbol
        }
    }

    private struct FractionCandidate {
        let value: Double
        let symbol: String
    }

    private static let fractions: [FractionCandidate] = [
        FractionCandidate(value: 1/8, symbol: "\u{215B}"),
        FractionCandidate(value: 1/4, symbol: "\u{00BC}"),
        FractionCandidate(value: 1/3, symbol: "\u{2153}"),
        FractionCandidate(value: 3/8, symbol: "\u{215C}"),
        FractionCandidate(value: 1/2, symbol: "\u{00BD}"),
        FractionCandidate(value: 5/8, symbol: "\u{215D}"),
        FractionCandidate(value: 2/3, symbol: "\u{2154}"),
        FractionCandidate(value: 3/4, symbol: "\u{00BE}"),
        FractionCandidate(value: 7/8, symbol: "\u{215E}"),
    ]

    private static func findClosestFraction(_ value: Double) -> FractionCandidate {
        var best = fractions[0]
        var bestDiff = abs(value - best.value)

        for candidate in fractions {
            let diff = abs(value - candidate.value)
            if diff < bestDiff {
                bestDiff = diff
                best = candidate
            }
        }

        if bestDiff > 0.05 {
            let decimal = String(format: "%.2f", value + Double(Int(0)))
            return FractionCandidate(value: value, symbol: decimal.hasSuffix("0") ? String(decimal.dropLast()) : decimal)
        }

        return best
    }
}
