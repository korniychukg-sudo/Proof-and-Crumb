import SwiftUI

struct BakeTerm: Identifiable {
    var id: String { term }
    let term: String
    let definition: String
}

enum BakeGlossary {
    static let terms: [BakeTerm] = [
        BakeTerm(term: "Autolyse", definition: "A quiet rest of just flour and water before kneading, letting the dough begin building gluten on its own."),
        BakeTerm(term: "Baker's dozen", definition: "Thirteen: the medieval baker's habit of adding one extra loaf to a dozen as insurance against strict bread laws."),
        BakeTerm(term: "Baker's percentage", definition: "The bakery's arithmetic: every ingredient weighed as a percentage of the flour, which always counts as one hundred."),
        BakeTerm(term: "Banneton", definition: "The coiled cane basket that cradles a proofing loaf and prints its spiral onto the crust."),
        BakeTerm(term: "Bulk ferment", definition: "The dough's first long rise, taken as one whole mass before it is divided and shaped."),
        BakeTerm(term: "Crumb", definition: "The inside of a loaf — its texture, its holes, its softness — and the first thing bakers examine in a slice."),
        BakeTerm(term: "Ear", definition: "The proud lifted flap of crust along a good slash, raised as the loaf springs in the oven."),
        BakeTerm(term: "Enriched dough", definition: "Dough carrying butter, eggs, milk or sugar; softer, browner, and gentler than a lean loaf."),
        BakeTerm(term: "Fermentation", definition: "The slow feast of yeast on flour's sugars, breathing out the gas that raises every loaf."),
        BakeTerm(term: "Gluten", definition: "The stretchy net built from flour's proteins by water and kneading; the architecture that holds a loaf's bubbles."),
        BakeTerm(term: "Hydration", definition: "Water measured against flour by weight. Low means a firm, obedient dough; high means a sticky one with an open crumb."),
        BakeTerm(term: "Knock back", definition: "Gently pressing the gas out of a risen dough before shaping, so it rises evenly a second time."),
        BakeTerm(term: "Lame", definition: "The baker's razor on a little handle, used to slash the loaf before it meets the oven."),
        BakeTerm(term: "Lamination", definition: "Folding cold butter inside dough again and again until dozens of paper-thin layers stack up, as in a croissant."),
        BakeTerm(term: "Lean dough", definition: "The plainest family of doughs: flour, water, salt and yeast, and nothing else."),
        BakeTerm(term: "Letter fold", definition: "Folding rolled dough in three like a business letter; each fold triples a laminated dough's layers."),
        BakeTerm(term: "Maillard reaction", definition: "The browning chemistry of the hot crust, source of its colour and most of its flavour."),
        BakeTerm(term: "Oven spring", definition: "The loaf's final surge of rising in its first minutes of baking, before the crust sets."),
        BakeTerm(term: "Poke test", definition: "The proof's honest referee: a gentle dimple that fills back slowly means the dough is ready."),
        BakeTerm(term: "Proof", definition: "The shaped loaf's last rise before baking — the patient hour where bread is won or lost."),
        BakeTerm(term: "Retarding", definition: "Slowing a proof in the cold, often overnight, to deepen flavour and fit baking around a life."),
        BakeTerm(term: "Score", definition: "The blade strokes cut into a loaf's surface, giving its oven spring a planned place to open."),
        BakeTerm(term: "Scrape down", definition: "Cleaning the dough hook and bowl walls mid-knead so every scrap rejoins the dough."),
        BakeTerm(term: "Slack dough", definition: "A wet, loose-limbed dough that spreads when left alone and demands wet hands and courage."),
        BakeTerm(term: "Sourdough starter", definition: "A living jar of flour and water colonised by wild yeasts and friendly bacteria, kept alive by regular feeding."),
        BakeTerm(term: "Steam", definition: "Moisture added to the oven's first minutes, keeping the crust soft so the loaf can rise to full height."),
        BakeTerm(term: "Tangzhong", definition: "A cooked flour-and-milk paste folded into soft doughs to hold moisture and keep the crumb cloud-soft for days."),
        BakeTerm(term: "Wash", definition: "The brushed coat — egg, milk, or water — that decides whether a crust bakes glossy, golden, or crisp."),
        BakeTerm(term: "Windowpane test", definition: "Stretching a scrap of dough thin enough to see light through; the sign that kneading has done its work."),
        BakeTerm(term: "Yeast", definition: "The single-celled fungus whose appetite and breath raise nearly every bread in this book."),
    ]
}

struct BakeQuizQuestion: Identifiable {
    let id = UUID()
    let prompt: String
    let options: [String]
    let correctIndex: Int
    let explanation: String
}

enum BakeQuiz {
    static func makeRound(seed: UInt64? = nil) -> [BakeQuizQuestion] {
        var rng = BakeSeededRandom(seed: seed ?? UInt64(Date().timeIntervalSince1970 * 1000))
        var questions: [BakeQuizQuestion] = []
        var usedTerms: Set<String> = []
        var usedRecipes: Set<String> = []
        for _ in 0..<3 {
            if let q = termQuestion(&rng, used: &usedTerms) { questions.append(q) }
        }
        for _ in 0..<2 {
            if let q = reverseTermQuestion(&rng, used: &usedTerms) { questions.append(q) }
        }
        for _ in 0..<2 {
            if let q = recipeQuestion(&rng, used: &usedRecipes) { questions.append(q) }
        }
        questions.append(contentsOf: factQuestions(&rng, count: 3))
        while questions.count > 10 { questions.removeLast() }
        var shuffled: [BakeQuizQuestion] = []
        var pool = questions
        while !pool.isEmpty {
            shuffled.append(pool.remove(at: rng.nextInt(pool.count)))
        }
        return shuffled
    }

    private static func pickDistinct(_ rng: inout BakeSeededRandom, count: Int, upper: Int, avoiding: Int?) -> [Int] {
        var picks: Set<Int> = []
        var guardCount = 0
        while picks.count < count && guardCount < 200 {
            guardCount += 1
            let v = rng.nextInt(upper)
            if v != avoiding { picks.insert(v) }
        }
        return Array(picks)
    }

    private static func shuffle(_ rng: inout BakeSeededRandom, _ options: [String]) -> [String] {
        var tmp = options
        var result: [String] = []
        while !tmp.isEmpty { result.append(tmp.remove(at: rng.nextInt(tmp.count))) }
        return result
    }

    private static func termQuestion(_ rng: inout BakeSeededRandom, used: inout Set<String>) -> BakeQuizQuestion? {
        let pool = BakeGlossary.terms.enumerated().filter { !used.contains($0.element.term) }
        guard pool.count >= 4 else { return nil }
        let pick = pool[rng.nextInt(pool.count)]
        used.insert(pick.element.term)
        var options = [pick.element.term]
        for w in pickDistinct(&rng, count: 3, upper: BakeGlossary.terms.count, avoiding: pick.offset) {
            options.append(BakeGlossary.terms[w].term)
        }
        guard options.count == 4 else { return nil }
        let shuffled = shuffle(&rng, options)
        guard let correct = shuffled.firstIndex(of: pick.element.term) else { return nil }
        return BakeQuizQuestion(
            prompt: "Which term does the handbook define as: \u{201C}\(pick.element.definition)\u{201D}",
            options: shuffled, correctIndex: correct,
            explanation: "\(pick.element.term): \(pick.element.definition)")
    }

    private static func reverseTermQuestion(_ rng: inout BakeSeededRandom, used: inout Set<String>) -> BakeQuizQuestion? {
        let pool = BakeGlossary.terms.enumerated().filter { !used.contains($0.element.term) }
        guard pool.count >= 4 else { return nil }
        let pick = pool[rng.nextInt(pool.count)]
        used.insert(pick.element.term)
        var options = [pick.element.definition]
        for w in pickDistinct(&rng, count: 3, upper: BakeGlossary.terms.count, avoiding: pick.offset) {
            options.append(BakeGlossary.terms[w].definition)
        }
        guard options.count == 4 else { return nil }
        let shuffled = shuffle(&rng, options)
        guard let correct = shuffled.firstIndex(of: pick.element.definition) else { return nil }
        return BakeQuizQuestion(
            prompt: "What does \u{201C}\(pick.element.term)\u{201D} mean?",
            options: shuffled, correctIndex: correct,
            explanation: "\(pick.element.term): \(pick.element.definition)")
    }

    private static func recipeQuestion(_ rng: inout BakeSeededRandom, used: inout Set<String>) -> BakeQuizQuestion? {
        let pool = BakeBook.recipes.enumerated().filter { !used.contains($0.element.id) }
        guard pool.count >= 4 else { return nil }
        let pick = pool[rng.nextInt(pool.count)]
        used.insert(pick.element.id)
        var options = [pick.element.name]
        for w in pickDistinct(&rng, count: 3, upper: BakeBook.recipes.count, avoiding: pick.offset) {
            options.append(BakeBook.recipes[w].name)
        }
        guard options.count == 4 else { return nil }
        let shuffled = shuffle(&rng, options)
        guard let correct = shuffled.firstIndex(of: pick.element.name) else { return nil }
        return BakeQuizQuestion(
            prompt: "Which bake does the book describe as: \u{201C}\(pick.element.blurb)\u{201D}",
            options: shuffled, correctIndex: correct,
            explanation: "\(pick.element.name) — \(pick.element.blurb)")
    }

    private static let factBank: [(String, String, [String], String)] = [
        ("What is the windowpane test checking?", "That kneading has built enough gluten", ["That the oven is hot enough", "That the yeast is alive", "That the crust has set"], "Dough stretched thin enough to see light through means the gluten net is fully developed."),
        ("Why do bakers add steam to the oven?", "It keeps the crust soft so the loaf can finish rising", ["It makes the crumb moist", "It cools the oven slightly", "It feeds the yeast"], "Steam delays the crust's setting, letting oven spring reach full height before the surface hardens."),
        ("A dimple pressed into proofed dough fills back slowly. What does it mean?", "The loaf is perfectly ready to bake", ["The dough needs another hour", "The dough is ruined", "The oven is too cold"], "The poke test: a slowly filling dimple is the sign of a perfect proof."),
        ("How many layers do three letter folds give a laminated dough?", "Twenty-seven", ["Nine", "Twelve", "Eighty-one"], "Each letter fold triples the layers: three, nine, twenty-seven."),
        ("What browns a crust and builds most of its flavour?", "The Maillard reaction", ["The yeast burning off", "Caramelised salt", "The flour bleaching"], "The Maillard reaction folds the surface's sugars and proteins into hundreds of flavourful compounds."),
        ("What is hydration, in a baker's recipe?", "Water weighed as a share of the flour", ["The dough's temperature", "The rising time", "The oven's humidity"], "Baker's percentages measure everything against the flour; hydration is the water's share."),
        ("Why does a pita form a pocket?", "Its moisture flashes to steam and inflates it", ["It is folded before baking", "The yeast gathers in the middle", "It is rolled around a mould"], "In a fierce oven the thin dough balloons as its water turns to steam all at once."),
        ("What does a ripe sourdough starter do in the float test?", "Floats, buoyed by its own gas", ["Sinks and stays down", "Dissolves at once", "Turns the water pink"], "A ripe starter is full of gas and floats; a sleepy one sinks."),
        ("Why is a baker's dozen thirteen?", "An extra loaf guarded against strict bread laws", ["Ovens held thirteen loaves", "One loaf was for the guild", "Thirteen was lucky"], "Medieval bakers added a spare loaf rather than risk punishment for selling light."),
        ("What is the slash cut into a loaf actually for?", "Giving the rising loaf a planned seam to open", ["Letting heat into the middle", "Marking the flavour", "Draining extra moisture"], "Scoring directs oven spring so the loaf opens at the blade line instead of tearing at random."),
        ("What does salt do in a bread dough?", "Disciplines the yeast and strengthens the gluten", ["Feeds the yeast", "Softens the crust", "Speeds up the proof"], "Salt tightens the gluten net and holds fermentation to a steady, flavourful pace."),
        ("Why do enriched doughs brown so quickly?", "Milk sugars and egg proteins feed the browning reaction", ["They are baked hotter", "Butter conducts heat", "They hold less water"], "The extra sugars and proteins give the Maillard reaction more to work with."),
    ]

    private static func factQuestions(_ rng: inout BakeSeededRandom, count: Int) -> [BakeQuizQuestion] {
        var result: [BakeQuizQuestion] = []
        var usedIdx: Set<Int> = []
        var guardCount = 0
        while result.count < count && guardCount < 60 {
            guardCount += 1
            let idx = rng.nextInt(factBank.count)
            guard !usedIdx.contains(idx) else { continue }
            usedIdx.insert(idx)
            let fact = factBank[idx]
            let shuffled = shuffle(&rng, [fact.1] + fact.2)
            guard let correct = shuffled.firstIndex(of: fact.1) else { continue }
            result.append(BakeQuizQuestion(prompt: fact.0, options: shuffled, correctIndex: correct, explanation: fact.3))
        }
        return result
    }
}
