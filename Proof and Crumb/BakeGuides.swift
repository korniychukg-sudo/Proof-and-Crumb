import SwiftUI

struct BakeGuide: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let plateArt: String
    let paragraphs: [String]
    let facts: [String]
}

enum BakeGuides {
    static let all: [BakeGuide] = partOne + partTwo

    private static let partOne: [BakeGuide] = [
        BakeGuide(
            id: "g_gluten",
            title: "What Kneading Builds",
            subtitle: "Gluten, the invisible architecture of bread",
            plateArt: "guide_gluten",
            paragraphs: [
                "Flour holds two sleeping proteins that wake the moment water arrives. Worked together by kneading, they bond into gluten: a stretchy, springy net that runs invisibly through every dough. That net is the whole architecture of bread. When yeast fills the dough with gas, it is gluten that catches the bubbles and holds them, the way a sail holds wind.",
                "Kneading is simply the building of that net, strand by strand, fold by fold. Under-kneaded dough tears like wet paper and lets its bubbles escape; the loaf bakes low and dense. Well-kneaded dough turns smooth and almost glossy, springing back when poked, stretching thin without breaking. Bakers test it by stretching a piece to a translucent sheet, the famous windowpane, thin enough to read a recipe through.",
                "There is a far side to the work, though hands rarely reach it: dough worked far too long grows tight, then gives up entirely, turning slack and sticky as the net shears apart. The lesson of the knead is the lesson of most of baking: enough is a destination, and more is not a virtue.",
            ],
            facts: [
                "The windowpane test: a walnut of dough stretched thin enough to see light through means the gluten is ready.",
                "Rye flour builds almost no gluten, which is why rye loaves are dense and proud of it.",
                "Resting a shaggy dough for twenty minutes builds gluten all by itself, no kneading required.",
            ]),
        BakeGuide(
            id: "g_yeast",
            title: "The Living Ingredient",
            subtitle: "How yeast raises every loaf",
            plateArt: "guide_yeast",
            paragraphs: [
                "Yeast is a single-celled fungus with one great talent: it eats sugars and breathes out carbon dioxide. Folded through a dough, billions of these cells fill the gluten net with countless tiny bubbles, and the dough grows, slowly and surely, like something breathing. That is all a rise is: respiration, held in a net.",
                "Yeast works at the pace of its kitchen. In warmth it feasts and the dough billows in an hour; in the cold of a larder it dawdles overnight, and bakers use that dawdling on purpose, because a slow rise leaves deeper flavour behind. Salt, meanwhile, keeps the feast orderly, tightening the gluten and holding the yeast to a civilised pace. A dough without salt rises like a mob and tastes like a shrug.",
                "Alongside the packet yeast of the modern kitchen lives the older way: the sourdough starter, a jar of flour and water where wild yeasts have settled in and made a home. Both raise bread by the same breath; the wild jar simply brings its whole unruly family, and the flavour of everywhere it has been.",
            ],
            facts: [
                "One gram of baker's yeast holds around ten billion living cells.",
                "Dough rising overnight in the refrigerator develops more flavour than dough hurried in an hour.",
                "Salt is not seasoning alone: it disciplines the yeast and strengthens the gluten net.",
            ]),
        BakeGuide(
            id: "g_hydration",
            title: "The Water Question",
            subtitle: "Why wet doughs make open crumb",
            plateArt: "guide_hydration",
            paragraphs: [
                "Bakers measure water against flour and call it hydration: a stiff bagel dough may be half water by flour weight, a ciabatta four-fifths. That single number shapes almost everything about a loaf, from how the dough feels in the hand to how the crumb looks on the board.",
                "Dry doughs are obedient. They hold their shape, roll into neat logs, and bake into a fine, even crumb, tight as a good mattress. Wet doughs are nearly alive: they slump, sprawl and stick to everything they meet, and reward the baker who persists with the glossy, open, big-holed crumb of the finest country loaves, because water makes the dough supple enough for bubbles to grow huge.",
                "The craft is matching water to purpose. Sandwich bread wants order; a rustic boule wants drama. And the oldest advice in the bakery still stands: wet hands, not extra flour, are the way to handle a sticky dough, because every spoonful of flour added in a panic is a spoonful the recipe never asked for.",
            ],
            facts: [
                "Hydration is water weighed against flour: 700 g of water to 1 kg of flour is seventy percent.",
                "The big glossy holes in ciabatta are impossible below roughly seventy-five percent hydration.",
                "Bakers handle wet dough with wet hands — water against water does not stick.",
            ]),
        BakeGuide(
            id: "g_proofing",
            title: "The Patient Hour",
            subtitle: "Proofing, and the art of waiting well",
            plateArt: "guide_proofing",
            paragraphs: [
                "After shaping, a loaf needs one last quiet rise before the oven, and that wait is called the proof. It is the stage where most bread is won or lost, because dough keeps its own clock and cares nothing for the baker's. Too short, and the loaf hits the oven tight and tears itself open along the sides. Too long, and the bubbles thin past their strength and the loaf sighs flat at the first touch of heat.",
                "The poke test reads the dough's clock honestly. Press a floured finger gently into the risen loaf. If the dimple springs back at once, the dough is still climbing; give it time. If it fills slowly, easing halfway back like a held breath released, the loaf is ready this very minute. If it stays, a crater in soft ground, the proof has gone over and the oven is now an emergency.",
                "Temperature sets the tempo. A warm corner proofs a loaf in under an hour; the refrigerator stretches the same journey across a whole night, trading speed for flavour and giving the baker back their evening. The dough does not mind which. It only asks that somebody be paying attention when it arrives.",
            ],
            facts: [
                "The poke test: a dimple that fills back slowly means the proof is perfect.",
                "An overnight proof in the cold is called retarding, and deepens both flavour and crust colour.",
                "Underproofed loaves burst at the seams; overproofed ones bake flat and pale.",
            ]),
        BakeGuide(
            id: "g_oven",
            title: "Steam and Spring",
            subtitle: "The first five minutes in the oven",
            plateArt: "guide_oven",
            paragraphs: [
                "A loaf's fate is mostly decided in its first five minutes of baking. Heat wakes the yeast into one final frantic feast, the gases swell, and the loaf surges upward in the burst bakers call oven spring. Everything about a good crust and a tall crumb hangs on letting that surge finish before the surface sets.",
                "This is why bakers throw steam into the oven. A dry oven crusts the loaf in the first minute, a shell that the rising insides can only rupture. Steam keeps the skin soft and elastic, so the loaf can climb to its full height; then, as the steam clears, the surface dries into a thin, blistered, deeply coloured crust. One kettle-splash of water on a hot tray is the difference between a loaf that opened like a flower and one that cracked like a road.",
                "The slash, that quick stroke of a blade before baking, is the same physics turned into signature. It gives the expanding loaf a planned seam to open along, instead of a random tear. Where the blade passed, the crust peels back into an ear; and every baker's slashes, like every baker's handwriting, are recognisably their own.",
            ],
            facts: [
                "Oven spring can add a third of a loaf's final height in the first minutes of baking.",
                "Steam delays the crust so the loaf can finish rising; professional ovens pipe it in on demand.",
                "Bread is done when its core reaches roughly 96 °C — or when the bottom knocks hollow.",
            ]),
    ]

    private static let partTwo: [BakeGuide] = [
        BakeGuide(
            id: "g_crust",
            title: "Reading the Crust",
            subtitle: "Colour, crackle, and the browning reaction",
            plateArt: "guide_crust",
            paragraphs: [
                "Crust colour is chemistry made visible. Above a certain heat, the sugars and proteins in the dough's skin begin folding into hundreds of new compounds, a transformation called the Maillard reaction, and every shade from first gold to deep mahogany carries its own flavours: toast, caramel, roasted nuts, a whisper of bitterness right at the dark end.",
                "Bakers read that colour the way smiths read glowing steel. Pale crust is quiet and soft; the loaf underneath is often underdone. The wide golden middle of the range is safety and sweetness. The bold browns just past it are where country loaves live, bitter-edged and loud when cut. A few shades further and the story ends in carbon and regret, sometimes in under a minute.",
                "A true crust also sings. As a well-baked loaf cools, the crust contracts faster than the crumb inside and crackles into a map of fine fractures, ticking softly on the counter like a cooling engine. Old bakers call it the bread singing, and count it, along with a hollow knock on the loaf's underside, among the only proofs of doneness that never lie.",
            ],
            facts: [
                "The browning of crust, seared steak, and roasted coffee is the same Maillard reaction.",
                "A loaf that crackles and ticks as it cools is a loaf that was baked boldly enough.",
                "Enriched doughs brown much faster — the milk sugars and egg proteins feed the reaction.",
            ]),
        BakeGuide(
            id: "g_lamination",
            title: "The Butter Fold",
            subtitle: "How croissants come by their layers",
            plateArt: "guide_lamination",
            paragraphs: [
                "Lamination is the craft of folding a slab of cold butter inside a sheet of dough, then rolling and folding the parcel over itself again and again. Each letter fold triples the layers: three become nine, nine become twenty-seven. A classic croissant carries those twenty-seven leaves of dough and butter, each thinner than paper, stacked in perfect order.",
                "The whole art balances on temperature. Butter must stay cold enough to remain its own layer, yet supple enough to roll without shattering. Too warm and it smears into the dough, and the layers dissolve into ordinary richness; too cold and it breaks into shards that punch through the sheets. Between every fold the parcel rests in the cold, both to relax the gluten and to keep the butter obediently solid.",
                "In the oven, the water hiding in all that butter turns to steam at once, and every layer lifts from its neighbour like pages of a book left in the wind. That is the whole secret of the shatter: there is no leavening trick, only water, butter, and geometry, folded patiently by somebody who refused to hurry.",
            ],
            facts: [
                "Three letter folds give twenty-seven layers; four give eighty-one.",
                "Butter is around fifteen percent water — in the oven that water is the engine of the rise.",
                "Professional pastry rooms are kept cold on purpose; lamination hates a warm afternoon.",
            ]),
        BakeGuide(
            id: "g_flat",
            title: "The Oldest Breads",
            subtitle: "Flatbreads, and ten thousand years of supper",
            plateArt: "guide_flat",
            paragraphs: [
                "Long before ovens, there were hot stones, and on those stones the first bread was flat. Charred crumbs on ancient hearths put flatbread thousands of years before farming itself; it remains the most widely eaten bread on earth, from wheat tortillas to injera, from lavash to the chapati puffing over a flame.",
                "Flat does not mean simple. A pita balloons in the oven's fierce heat as its moisture flashes to steam, splitting itself into the pocket that makes it famous; the skill is a dough rolled evenly and an oven hot enough to shock it. Focaccia goes the other way, pressed thick into a slick of olive oil, dimpled to the pan floor so the little wells hold oil and salt and fry the crumb golden from below.",
                "Every flatbread is a record of the kitchen that made it: the fuel it had, the flour it grew, the time it could spare. Where fuel was scarce, bread baked in minutes against hot metal; where ovens roared, it puffed and blistered. To bake through the flatbreads is to travel without a map, one thin supper at a time.",
            ],
            facts: [
                "Charred flatbread crumbs from ancient hearths predate agriculture by millennia.",
                "A pita's pocket is one steam-burst, over in seconds in a very hot oven.",
                "Focaccia's dimples are structural: they hold the oil that fries the crumb from below.",
            ]),
        BakeGuide(
            id: "g_starter",
            title: "The Jar on the Sill",
            subtitle: "Keeping a sourdough starter alive",
            plateArt: "guide_starter",
            paragraphs: [
                "A sourdough starter is the slowest pet a household can keep: a jar of flour and water colonised by wild yeasts and friendly bacteria, thickening and bubbling as they settle in. Fed regularly, the culture lives indefinitely; bakeries exist whose starters are older than the buildings around them, passed down like silverware.",
                "The keeping is plain: pour off most of the jar, feed what remains with fresh flour and water, and let it work. A ripe starter doubles itself and smells of orchards and yoghurt; a hungry one slumps under grey liquid and sulks. The float test settles any argument, for a spoonful of ripe starter floats in water, buoyed by its own gas, while a sleepy one sinks like the apology it is.",
                "What the jar gives back is character. The bacteria sharing quarters with the yeast brew the gentle acids that give sourdough its name, its keeping quality, and its depth. No two kitchens grow quite the same jar, which means no two houses bake quite the same loaf, and that, more than anything, is the point.",
            ],
            facts: [
                "Some working bakery starters are over a century old and still fed daily.",
                "The float test: ripe starter floats in water; sleepy starter sinks.",
                "The sour in sourdough is brewed by bacteria, not by the yeast at all.",
            ]),
        BakeGuide(
            id: "g_bakery",
            title: "The Village Bakery",
            subtitle: "A short history of the baker's trade",
            plateArt: "guide_bakery",
            paragraphs: [
                "For most of history, bread was the meal, and the baker's oven was the warmest room in the village. Households carried their own risen loaves to be baked in the communal oven, each family's mark pressed into the dough; the ovens of some villages never fully cooled for three hundred years.",
                "The baker's day ran backwards to everyone else's: fires lit at midnight, dough turned in the small hours, shelves full by the time the village woke. Guilds guarded the craft, and the law watched it closely, because bread was too important to cheat; medieval bakers who sold light loaves faced real punishment, and the old habit of adding a thirteenth loaf to a dozen, just to be safe, still carries their name.",
                "The village bakery has thinned in the world, but it has never quite left, and every home oven with a loaf inside is a small revival of it. The smell of baking bread remains what it has always been: the announcement, older than writing, that somebody in this house intends for people to be fed.",
            ],
            facts: [
                "A baker's dozen is thirteen: one extra loaf as insurance against the old strict bread laws.",
                "Communal village ovens baked every family's loaves, each pressed with the household's mark.",
                "Bakers' guilds are among the oldest recorded trade organisations in existence.",
            ]),
    ]
}
