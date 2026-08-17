import SwiftUI

struct BakeChapter: Identifiable {
    let id: Int
    let name: String
    let motto: String
    let banner: String
}

enum BakeBook {
    static let chapters: [BakeChapter] = [
        BakeChapter(id: 0, name: "Everyday Loaves", motto: "Flour, water, salt, patience.", banner: "banner_ch1"),
        BakeChapter(id: 1, name: "The Enriched Shelf", motto: "Butter and eggs make everything gentler.", banner: "banner_ch2"),
        BakeChapter(id: 2, name: "Flat and Crisp", motto: "The oldest breads in the world are the thinnest.", banner: "banner_ch3"),
        BakeChapter(id: 3, name: "The Laminated Arts", motto: "Butter, folded until it sings.", banner: "banner_ch4"),
        BakeChapter(id: 4, name: "Celebration Bakes", motto: "Some bread is baked for the table's best days.", banner: "banner_ch5"),
    ]

    static let recipes: [BakeRecipe] = everyday + enriched + flat + laminated + celebration

    static func recipe(_ id: String) -> BakeRecipe {
        recipes.first { $0.id == id } ?? recipes[0]
    }

    private static let everyday: [BakeRecipe] = [
        BakeRecipe(
            id: "tinloaf", name: "White Tin Loaf", chapter: 0,
            blurb: "The loaf of a thousand kitchens, square-shouldered and soft.",
            story: "Every baker starts here, and none of them ever really leaves. The tin gives the dough walls to climb, and the smell of it baking has sold more houses than any coat of paint.",
            ingredients: ["Flour", "Water", "Yeast", "Salt", "A little butter"],
            hydration: 0.64, stages: [.mix, .knead, .proofRise, .shape, .bake, .reveal],
            shapeKind: .log, slashCount: 0, crustTarget: 0.58, wantsSteam: false, laminateFolds: 0,
            unlockRank: 0, baseXP: 30, needsStarter: false,
            tip: "Pull it when the top is a soft gold; tin loaves keep their colour gentle.",
            doughTint: 0),
        BakeRecipe(
            id: "boule", name: "Farmhouse Boule", chapter: 0,
            blurb: "A round country loaf with a bold crust and an honest crumb.",
            story: "The boule is bread in its oldest silhouette, the shape dough takes when only two hands and gravity have opinions. A hot oven, a cloud of steam, and a single decisive slash across the top.",
            ingredients: ["Flour", "Water", "Yeast", "Salt"],
            hydration: 0.72, stages: [.mix, .knead, .proofRise, .shape, .slash, .bake, .reveal],
            shapeKind: .round, slashCount: 1, crustTarget: 0.72, wantsSteam: true, laminateFolds: 0,
            unlockRank: 0, baseXP: 40, needsStarter: false,
            tip: "Steam early and bake bold — a country crust should crackle as it cools.",
            doughTint: 0),
        BakeRecipe(
            id: "baguette", name: "Baguettes", chapter: 0,
            blurb: "Long, light, and gone by suppertime.",
            story: "A baguette is mostly crust by design, which is the entire point: maximum crackle per bite. The seven diagonal slashes are not decoration, they are the seams along which the loaf agrees to open.",
            ingredients: ["Flour", "Water", "Yeast", "Salt"],
            hydration: 0.68, stages: [.mix, .knead, .proofRise, .shape, .slash, .bake, .reveal],
            shapeKind: .sticks, slashCount: 4, crustTarget: 0.66, wantsSteam: true, laminateFolds: 0,
            unlockRank: 1, baseXP: 45, needsStarter: false,
            tip: "Overlap the slashes like roof tiles, each one nearly parallel to the loaf.",
            doughTint: 0),
        BakeRecipe(
            id: "rolls", name: "Soft Morning Rolls", chapter: 0,
            blurb: "A tray of small clouds, baked shoulder to shoulder.",
            story: "Rolls baked close enough to touch rise into each other and tear apart in soft sheets. The bottom of the tray is everyone's favourite, and every family pretends otherwise.",
            ingredients: ["Flour", "Milk", "Yeast", "Salt", "Butter"],
            hydration: 0.62, stages: [.mix, .knead, .proofRise, .shape, .bake, .reveal],
            shapeKind: .round, slashCount: 0, crustTarget: 0.5, wantsSteam: false, laminateFolds: 0,
            unlockRank: 0, baseXP: 35, needsStarter: false,
            tip: "Keep them pale; a soft roll should blush, not tan.",
            doughTint: 2),
        BakeRecipe(
            id: "rye", name: "Dark Rye Loaf", chapter: 0,
            blurb: "Dense, aromatic, and better on the second day.",
            story: "Rye flour has almost no gluten to speak of, so the loaf is heavier, closer, and prouder of it. It keeps for a week, slices thin as card, and carries butter the way a barge carries coal.",
            ingredients: ["Rye flour", "Flour", "Water", "Yeast", "Salt", "Caraway"],
            hydration: 0.7, stages: [.mix, .knead, .proofRise, .shape, .slash, .bake, .reveal],
            shapeKind: .log, slashCount: 3, crustTarget: 0.78, wantsSteam: true, laminateFolds: 0,
            unlockRank: 2, baseXP: 50, needsStarter: false,
            tip: "Do not chase a big rise — rye is meant to be close-crumbed and calm.",
            doughTint: 1),
    ]

    private static let enriched: [BakeRecipe] = [
        BakeRecipe(
            id: "brioche", name: "Brioche Buns", chapter: 1,
            blurb: "So much butter the dough shines like satin.",
            story: "Brioche is the point where bread starts negotiating with cake. The butter goes in slowly, the dough turns glossy and demanding, and the reward is a crumb so fine it tears like silk.",
            ingredients: ["Flour", "Eggs", "Milk", "Yeast", "Sugar", "Salt", "Butter"],
            hydration: 0.6, stages: [.mix, .knead, .proofRise, .shape, .bake, .reveal],
            shapeKind: .round, slashCount: 0, crustTarget: 0.62, wantsSteam: false, laminateFolds: 0,
            unlockRank: 1, baseXP: 50, needsStarter: false,
            tip: "An egg-rich dough browns fast — watch the last minute like a hawk.",
            doughTint: 2),
        BakeRecipe(
            id: "challah", name: "Challah Braid", chapter: 1,
            blurb: "Three strands, one golden crown.",
            story: "The braid is the oldest way of making bread beautiful without a single tool. Three ropes of enriched dough, crossed patiently, rise into a loaf that looks woven from light.",
            ingredients: ["Flour", "Eggs", "Water", "Yeast", "Sugar", "Salt", "Oil"],
            hydration: 0.58, stages: [.mix, .knead, .proofRise, .shape, .bake, .reveal],
            shapeKind: .braid, slashCount: 0, crustTarget: 0.68, wantsSteam: false, laminateFolds: 0,
            unlockRank: 2, baseXP: 60, needsStarter: false,
            tip: "Braid loosely — the proof will close every gap you leave.",
            doughTint: 2),
        BakeRecipe(
            id: "cinnamon", name: "Cinnamon Swirl", chapter: 1,
            blurb: "A soft loaf hiding a spiral of spice.",
            story: "Rolled flat, painted with butter and cinnamon sugar, then rolled up like a secret. Every slice is a spiral, and the middle slice is worth negotiating for.",
            ingredients: ["Flour", "Milk", "Yeast", "Sugar", "Salt", "Butter", "Cinnamon"],
            hydration: 0.61, stages: [.mix, .knead, .proofRise, .shape, .bake, .reveal],
            shapeKind: .twist, slashCount: 0, crustTarget: 0.6, wantsSteam: false, laminateFolds: 0,
            unlockRank: 2, baseXP: 55, needsStarter: false,
            tip: "Roll the spiral snug; loose swirls bake into caves.",
            doughTint: 2),
        BakeRecipe(
            id: "milkbread", name: "Milk Bread", chapter: 1,
            blurb: "The softest loaf in the book, feathery and tall.",
            story: "A cooked flour-and-milk paste holds water inside the crumb, and the result stays cloud-soft for days. The loaf tears into feathers, never crumbs, and toast made from it is a small event.",
            ingredients: ["Flour", "Milk paste", "Milk", "Yeast", "Sugar", "Salt", "Butter"],
            hydration: 0.66, stages: [.mix, .knead, .proofRise, .shape, .bake, .reveal],
            shapeKind: .log, slashCount: 0, crustTarget: 0.55, wantsSteam: false, laminateFolds: 0,
            unlockRank: 3, baseXP: 60, needsStarter: false,
            tip: "Knead it further than feels reasonable — the shine is the signal.",
            doughTint: 2),
    ]

    private static let flat: [BakeRecipe] = [
        BakeRecipe(
            id: "pita", name: "Pita Pockets", chapter: 2,
            blurb: "Flat going in, ballooned coming out.",
            story: "In a fierce oven, the water in a thin dough turns to steam all at once and blows the bread up like a paper bag. It collapses as it cools, leaving the pocket that makes lunch possible.",
            ingredients: ["Flour", "Water", "Yeast", "Salt", "Olive oil"],
            hydration: 0.63, stages: [.mix, .knead, .proofRise, .shape, .bake, .reveal],
            shapeKind: .round, slashCount: 0, crustTarget: 0.45, wantsSteam: false, laminateFolds: 0,
            unlockRank: 1, baseXP: 40, needsStarter: false,
            tip: "Hot and fast — a pita that lingers is a cracker that failed.",
            doughTint: 0),
        BakeRecipe(
            id: "focaccia", name: "Rosemary Focaccia", chapter: 2,
            blurb: "An olive-oil dough dimpled like a rainy pond.",
            story: "The dimples are the whole craft: pressed to the pan through a slick of oil, they hold little pools that fry the crumb golden from below. Rosemary on top, and the kitchen smells like a holiday.",
            ingredients: ["Flour", "Water", "Yeast", "Salt", "Olive oil", "Rosemary"],
            hydration: 0.8, stages: [.mix, .knead, .proofRise, .shape, .bake, .reveal],
            shapeKind: .dimple, slashCount: 0, crustTarget: 0.62, wantsSteam: false, laminateFolds: 0,
            unlockRank: 2, baseXP: 55, needsStarter: false,
            tip: "Press the dimples to the pan floor — brave fingers, better focaccia.",
            doughTint: 0),
        BakeRecipe(
            id: "crackers", name: "Seeded Crackers", chapter: 2,
            blurb: "Rolled thin as paper, snapped like twigs.",
            story: "No yeast, no rise, no waiting: crackers are the impatient baker's reward. Rolled until the counter shows through, scattered with seeds, and baked until they learn to snap.",
            ingredients: ["Flour", "Water", "Olive oil", "Salt", "Seeds"],
            hydration: 0.45, stages: [.mix, .shape, .bake, .reveal],
            shapeKind: .sticks, slashCount: 0, crustTarget: 0.6, wantsSteam: false, laminateFolds: 0,
            unlockRank: 0, baseXP: 30, needsStarter: false,
            tip: "Thin is everything; a thick cracker is just sad flatbread.",
            doughTint: 0),
        BakeRecipe(
            id: "grissini", name: "Hand-Rolled Grissini", chapter: 2,
            blurb: "Crisp breadsticks as long as your patience.",
            story: "Each stick is rolled by hand from a strip of dough, which is why no two are straight and nobody minds. Stood in a jar on the table, they disappear before the soup arrives.",
            ingredients: ["Flour", "Water", "Yeast", "Olive oil", "Salt", "Semolina"],
            hydration: 0.58, stages: [.mix, .knead, .proofRise, .shape, .bake, .reveal],
            shapeKind: .sticks, slashCount: 0, crustTarget: 0.64, wantsSteam: false, laminateFolds: 0,
            unlockRank: 3, baseXP: 50, needsStarter: false,
            tip: "Roll from the middle outward, and let crooked be charming.",
            doughTint: 0),
    ]

    private static let laminated: [BakeRecipe] = [
        BakeRecipe(
            id: "croissant", name: "Croissants", chapter: 3,
            blurb: "Twenty-seven layers of butter, if you fold honestly.",
            story: "Lamination is pastry's long game: a sheet of cold butter locked in dough, folded, rested, folded again. In the oven the water in the butter turns to steam and pushes every layer apart, and the croissant shatters exactly the way three days of patience deserve.",
            ingredients: ["Flour", "Milk", "Yeast", "Sugar", "Salt", "Butter slab"],
            hydration: 0.55, stages: [.mix, .laminate, .proofRise, .shape, .bake, .reveal],
            shapeKind: .crescent, slashCount: 0, crustTarget: 0.7, wantsSteam: false, laminateFolds: 3,
            unlockRank: 4, baseXP: 80, needsStarter: false,
            tip: "Cold butter, quick hands. If it smears, stop and let it rest.",
            doughTint: 2),
        BakeRecipe(
            id: "painauchoc", name: "Pain au Chocolat", chapter: 3,
            blurb: "The croissant's rectangular cousin with two dark secrets.",
            story: "Two batons of chocolate, rolled into laminated dough, aligned so every bite gets its share. Eaten warm, it is less a pastry than an argument for getting up early.",
            ingredients: ["Flour", "Milk", "Yeast", "Sugar", "Salt", "Butter slab", "Chocolate"],
            hydration: 0.55, stages: [.mix, .laminate, .proofRise, .shape, .bake, .reveal],
            shapeKind: .log, slashCount: 0, crustTarget: 0.7, wantsSteam: false, laminateFolds: 3,
            unlockRank: 5, baseXP: 85, needsStarter: false,
            tip: "Seam side down, always, or the oven will open it for you.",
            doughTint: 2),
        BakeRecipe(
            id: "palmier", name: "Palmiers", chapter: 3,
            blurb: "Sugared pastry rolled from both ends into little palms.",
            story: "Two scrolls of laminated dough meet in the middle, are sliced sideways, and caramelise flat on the tray. They look like hearts if you are fond of someone and like palm leaves if you are hungry.",
            ingredients: ["Flour", "Water", "Salt", "Butter slab", "Sugar"],
            hydration: 0.5, stages: [.mix, .laminate, .shape, .bake, .reveal],
            shapeKind: .twist, slashCount: 0, crustTarget: 0.74, wantsSteam: false, laminateFolds: 4,
            unlockRank: 5, baseXP: 80, needsStarter: false,
            tip: "Sugar burns a shade past caramel — pull them at deep amber, not mahogany.",
            doughTint: 2),
        BakeRecipe(
            id: "danish", name: "Danish Windmills", chapter: 3,
            blurb: "Folded pastry sails around a spoonful of jam.",
            story: "Cut a laminated square, snip the corners, fold alternate points to the centre, and a windmill appears. The jam goes in last and behaves for exactly as long as it feels like.",
            ingredients: ["Flour", "Milk", "Eggs", "Yeast", "Sugar", "Salt", "Butter slab", "Jam"],
            hydration: 0.56, stages: [.mix, .laminate, .proofRise, .shape, .bake, .reveal],
            shapeKind: .star, slashCount: 0, crustTarget: 0.66, wantsSteam: false, laminateFolds: 3,
            unlockRank: 6, baseXP: 90, needsStarter: false,
            tip: "A thumbprint well in the middle keeps the jam roughly where you meant it.",
            doughTint: 2),
    ]

    private static let celebration: [BakeRecipe] = [
        BakeRecipe(
            id: "sourdough", name: "Sourdough Country Loaf", chapter: 4,
            blurb: "Raised by your own starter, signed with your own slash.",
            story: "No packet yeast, just the colony of wild yeasts you have been feeding on the windowsill. Sourdough is slower in every direction and richer in most of them: a deeper flavour, a bolder crust, and a loaf with your kitchen's own signature in it.",
            ingredients: ["Ripe starter", "Flour", "Water", "Salt"],
            hydration: 0.76, stages: [.mix, .knead, .proofRise, .shape, .slash, .bake, .reveal],
            shapeKind: .round, slashCount: 1, crustTarget: 0.76, wantsSteam: true, laminateFolds: 0,
            unlockRank: 3, baseXP: 90, needsStarter: true,
            tip: "A ripe starter floats in water; a sleepy one sinks and so will the loaf.",
            doughTint: 0),
        BakeRecipe(
            id: "pretzel", name: "Pretzel Twists", chapter: 4,
            blurb: "Mahogany knots with white salt and a soft heart.",
            story: "The pretzel's colour and shine come from a quick alkaline bath before baking, an old trick that turns the crust deep brown and faintly savoury. The knot itself is a single confident flip.",
            ingredients: ["Flour", "Water", "Yeast", "Salt", "Butter", "Baking soda bath"],
            hydration: 0.58, stages: [.mix, .knead, .proofRise, .shape, .bake, .reveal],
            shapeKind: .twist, slashCount: 0, crustTarget: 0.8, wantsSteam: false, laminateFolds: 0,
            unlockRank: 4, baseXP: 75, needsStarter: false,
            tip: "Deep mahogany is correct here — a pale pretzel convinces no one.",
            doughTint: 0),
        BakeRecipe(
            id: "babka", name: "Chocolate Babka", chapter: 4,
            blurb: "A twisted loaf marbled through with dark chocolate.",
            story: "The dough is rolled with chocolate, cut down the middle, and the two halves are twisted around each other so every slice is a different marbled map. It is impossible to cut a neat slice, which is part of the design.",
            ingredients: ["Flour", "Eggs", "Milk", "Yeast", "Sugar", "Salt", "Butter", "Chocolate"],
            hydration: 0.6, stages: [.mix, .knead, .proofRise, .shape, .bake, .reveal],
            shapeKind: .twist, slashCount: 0, crustTarget: 0.68, wantsSteam: false, laminateFolds: 0,
            unlockRank: 5, baseXP: 85, needsStarter: false,
            tip: "Twist cut-side up so the chocolate strata face the light.",
            doughTint: 3),
        BakeRecipe(
            id: "starbread", name: "Star Bread", chapter: 4,
            blurb: "Four layers, sixteen twists, one edible snowflake.",
            story: "Four discs of dough with filling between, cut into rays and twisted in pairs, bloom into a star in the oven. It exists to be put in the middle of a table and torn apart by many hands.",
            ingredients: ["Flour", "Milk", "Eggs", "Yeast", "Sugar", "Salt", "Butter", "Spiced filling"],
            hydration: 0.6, stages: [.mix, .knead, .proofRise, .shape, .bake, .reveal],
            shapeKind: .star, slashCount: 0, crustTarget: 0.62, wantsSteam: false, laminateFolds: 0,
            unlockRank: 6, baseXP: 95, needsStarter: false,
            tip: "Twist neighbouring rays in opposite directions and the star opens itself.",
            doughTint: 2),
        BakeRecipe(
            id: "crown", name: "Seeded Harvest Crown", chapter: 4,
            blurb: "A ring loaf crusted with every seed in the jar.",
            story: "A crown for the table: a ring of dough rolled in poppy, sesame, sunflower and flax until it glitters. Baked as a ring so there is no end and no beginning, only the next torn piece.",
            ingredients: ["Flour", "Water", "Yeast", "Salt", "Honey", "Mixed seeds"],
            hydration: 0.68, stages: [.mix, .knead, .proofRise, .shape, .slash, .bake, .reveal],
            shapeKind: .round, slashCount: 5, crustTarget: 0.7, wantsSteam: true, laminateFolds: 0,
            unlockRank: 6, baseXP: 90, needsStarter: false,
            tip: "Wet the surface before seeding, or the harvest falls off at the first slice.",
            doughTint: 0),
        BakeRecipe(
            id: "sheaf", name: "Wheat Sheaf Centrepiece", chapter: 4,
            blurb: "A decorative sheaf of bread stalks, baked to be admired.",
            story: "Harvest festivals once filled church windowsills with these: bread sculpted into a bound sheaf of wheat, every stalk snipped by hand. It is baked hard, kept for the season, and admired far longer than any loaf is eaten.",
            ingredients: ["Flour", "Water", "Salt"],
            hydration: 0.5, stages: [.mix, .knead, .shape, .bake, .reveal],
            shapeKind: .sticks, slashCount: 0, crustTarget: 0.72, wantsSteam: false, laminateFolds: 0,
            unlockRank: 7, baseXP: 100, needsStarter: false,
            tip: "This dough is a sculptor's clay — stiff, slow, and obedient.",
            doughTint: 0),
        BakeRecipe(
            id: "sourfruit", name: "Fig and Walnut Sourdough", chapter: 4,
            blurb: "The country loaf dressed for a feast day.",
            story: "The same wild-raised crumb, now studded with figs and walnuts that toast inside the loaf as it bakes. Slices of it need nothing at all, which never stops anyone buttering them.",
            ingredients: ["Ripe starter", "Flour", "Water", "Salt", "Figs", "Walnuts"],
            hydration: 0.74, stages: [.mix, .knead, .proofRise, .shape, .slash, .bake, .reveal],
            shapeKind: .round, slashCount: 2, crustTarget: 0.76, wantsSteam: true, laminateFolds: 0,
            unlockRank: 7, baseXP: 110, needsStarter: true,
            tip: "Fold the fruit in at the end of the knead, or the crumb bruises purple.",
            doughTint: 1),
    ]
}
