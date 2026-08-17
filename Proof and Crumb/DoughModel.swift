import SwiftUI

enum BakeStage: String, Codable, CaseIterable {
    case mix, knead, laminate, proofRise, shape, slash, bake, reveal

    var title: String {
        switch self {
        case .mix: return "The Mix"
        case .knead: return "The Knead"
        case .laminate: return "The Lamination"
        case .proofRise: return "The Proof"
        case .shape: return "The Shaping"
        case .slash: return "The Scoring"
        case .bake: return "The Bake"
        case .reveal: return "The Reveal"
        }
    }
}

enum ShapeKind: String, Codable {
    case round, log, sticks, braid, twist, dimple, crescent, star
}

struct BakeRecipe: Identifiable {
    let id: String
    let name: String
    let chapter: Int
    let blurb: String
    let story: String
    let ingredients: [String]
    let hydration: Double
    let stages: [BakeStage]
    let shapeKind: ShapeKind
    let slashCount: Int
    let crustTarget: Double
    let wantsSteam: Bool
    let laminateFolds: Int
    let unlockRank: Int
    let baseXP: Int
    let needsStarter: Bool
    let tip: String
    let doughTint: Int
}

struct StageMarks: Codable {
    var mix: Double = 0
    var knead: Double = 0
    var laminate: Double = 0
    var proofRise: Double = 0
    var shape: Double = 0
    var slash: Double = 0
    var bake: Double = 0

    func overall(for recipe: BakeRecipe) -> Double {
        var total = 0.0
        var weight = 0.0
        for stage in recipe.stages {
            switch stage {
            case .mix: total += mix * 1.0; weight += 1.0
            case .knead: total += knead * 1.2; weight += 1.2
            case .laminate: total += laminate * 1.4; weight += 1.4
            case .proofRise: total += proofRise * 1.3; weight += 1.3
            case .shape: total += shape * 1.2; weight += 1.2
            case .slash: total += slash * 0.8; weight += 0.8
            case .bake: total += bake * 1.4; weight += 1.4
            case .reveal: break
            }
        }
        guard weight > 0 else { return 0 }
        return (total / weight).bakeClamped(0, 1)
    }

    func stars(for recipe: BakeRecipe) -> Int {
        let q = overall(for: recipe)
        if q >= 0.82 { return 3 }
        if q >= 0.6 { return 2 }
        return 1
    }
}

struct BakeRecord: Codable, Identifiable {
    var id: UUID = UUID()
    var recipeID: String
    var date: Date
    var stars: Int
    var quality: Double
    var crust: Double
    var hydration: Double
    var ferment: Double
    var gluten: Double
}

enum BakeVerdicts {
    static func crumbLine(hydration: Double, ferment: Double, gluten: Double) -> String {
        if ferment < 0.45 { return "The crumb is tight and a little heavy — the dough wanted more time to rise." }
        if ferment > 1.05 { return "The crumb has collapsed in places; it proofed past its peak and the bubbles gave way." }
        if hydration > 0.8 && gluten > 0.7 { return "An open, glossy crumb with big irregular holes — the mark of a wet dough handled well." }
        if gluten < 0.45 { return "The crumb tears rather than pulls; a longer knead would build more strength." }
        if gluten > 1.15 { return "The crumb is dense and chewy — the dough was worked past its best." }
        return "An even, tender crumb with a soft sheen — honest bread, well made."
    }

    static func crustLine(crust: Double, target: Double, steamOK: Bool) -> String {
        let diff = crust - target
        if diff < -0.16 { return "The crust is pale and quiet; it left the oven shy of its colour." }
        if diff > 0.16 { return "The crust went past deep brown toward bitter — a minute less next time." }
        if !steamOK { return "Good colour, though without steam the crust set before it could fully bloom." }
        return "A deep, crackling crust, right in the sweet band of colour."
    }

    static func title(stars: Int) -> String {
        switch stars {
        case 3: return "A bake to put in the window"
        case 2: return "A good honest bake"
        default: return "A lesson, freshly baked"
        }
    }
}

struct CrumbSpec {
    var bubbleCount: Int
    var bubbleScale: CGFloat
    var irregularity: CGFloat
    var collapsed: Bool

    static func from(hydration: Double, ferment: Double, gluten: Double, seed: UInt64) -> CrumbSpec {
        let open = (hydration - 0.6) * 2.2 + (ferment.bakeClamped(0, 1) - 0.5)
        let count = Int(90 - open.bakeClamped(-0.5, 1.2) * 44)
        let scale = CGFloat(0.5 + open.bakeClamped(-0.5, 1.2) * 0.75)
        let irregular = CGFloat((1.1 - gluten.bakeClamped(0.2, 1.1)) * 0.6 + hydration * 0.3)
        return CrumbSpec(
            bubbleCount: max(26, count),
            bubbleScale: scale.bakeClamped(0.35, 1.6),
            irregularity: irregular.bakeClamped(0.1, 0.9),
            collapsed: ferment > 1.05)
    }
}

enum BakeMath {
    static func mixMark(orderErrors: Int, total: Int, hydrationSet: Double, target: Double) -> Double {
        let orderPart = 1.0 - Double(orderErrors) / Double(max(1, total)) * 0.9
        let hydrationPart = 1.0 - (abs(hydrationSet - target) / 0.14).bakeClamped(0, 1)
        return (orderPart * 0.45 + hydrationPart * 0.55).bakeClamped(0, 1)
    }

    static func kneadMark(_ gluten: Double) -> Double {
        if gluten <= 1.0 {
            return (gluten * gluten * 0.5 + gluten * 0.5).bakeClamped(0, 1)
        }
        return (1.0 - (gluten - 1.0) * 1.4).bakeClamped(0.15, 1)
    }

    static func proofMark(_ ferment: Double) -> Double {
        let ideal = 0.82
        let diff = abs(ferment - ideal)
        return (1.0 - diff * 2.4).bakeClamped(0.05, 1)
    }

    static func bakeMark(crust: Double, target: Double, steamOK: Bool, wantsSteam: Bool) -> Double {
        var mark = 1.0 - (abs(crust - target) / 0.22).bakeClamped(0, 1)
        if wantsSteam && !steamOK { mark -= 0.18 }
        return mark.bakeClamped(0.05, 1)
    }

    static func laminateMark(goodFolds: Int, rushedFolds: Int, targetFolds: Int) -> Double {
        guard targetFolds > 0 else { return 1 }
        let done = Double(goodFolds) / Double(targetFolds)
        let rush = Double(rushedFolds) * 0.12
        return (done - rush).bakeClamped(0, 1)
    }

    static func pokeVerdict(_ ferment: Double) -> String {
        if ferment < 0.35 { return "The dimple springs straight back. The dough is nowhere near ready." }
        if ferment < 0.6 { return "It springs back quickly — give it longer in the warmth." }
        if ferment < 0.72 { return "The dimple fills slowly. Getting close now." }
        if ferment < 0.95 { return "The dimple stays, easing back just a little. It is ready." }
        if ferment < 1.1 { return "The dough sighs and barely pushes back — take it now, quickly." }
        return "The poke leaves a crater and the dome is sinking. It has gone over."
    }
}
