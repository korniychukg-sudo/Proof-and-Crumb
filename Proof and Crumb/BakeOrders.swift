import SwiftUI

struct BakeRequest: Identifiable {
    let id: String
    let title: String
    let client: String
    let brief: String
    let rewardXP: Int
    let progress: (BakeStore) -> (Double, String)

    func satisfied(_ store: BakeStore) -> Bool {
        progress(store).0 >= 1.0
    }
}

enum BakeRequests {
    static let all: [BakeRequest] = first + second

    private static func countReq(id: String, title: String, client: String, brief: String, xp: Int, value: @escaping (BakeStore) -> Double, target: Double, unit: String) -> BakeRequest {
        BakeRequest(id: id, title: title, client: client, brief: brief, rewardXP: xp) { store in
            let v = value(store)
            return (min(1, v / target), "\(Int(min(v, target))) of \(Int(target)) \(unit)")
        }
    }

    private static let first: [BakeRequest] = [
        countReq(id: "r01", title: "First Light, First Loaf", client: "The Empty Shelf",
                 brief: "The shop window has been bare too long. Bake anything at all and set it on the shelf.",
                 xp: 30, value: { Double($0.stats.bakesFinished) }, target: 1, unit: "bakes"),
        countReq(id: "r02", title: "A Working Morning", client: "The Till",
                 brief: "One bake is a treat; five bakes is a bakery. Fill the shelf five times over.",
                 xp: 50, value: { Double($0.stats.bakesFinished) }, target: 5, unit: "bakes"),
        countReq(id: "r03", title: "The Perfectionist", client: "A Very Particular Customer",
                 brief: "She will accept nothing below the best. Bake something worthy of three stars.",
                 xp: 60, value: { Double($0.stats.threeStarBakes) }, target: 1, unit: "three-star bakes"),
        BakeRequest(id: "r04", title: "The Everyday Round", client: "The Village Breakfast",
                    brief: "Master the everyday shelf: bake every loaf in the first chapter at least once.",
                    rewardXP: 80) { store in
            let ids = BakeBook.recipes.filter { $0.chapter == 0 }.map { $0.id }
            let done = ids.filter { store.stats.bestStars[$0] != nil }.count
            return (Double(done) / Double(ids.count), "\(done) of \(ids.count) everyday bakes made")
        },
        countReq(id: "r05", title: "Feed the Quiet Tenant", client: "The Jar on the Sill",
                 brief: "Something in the jar is hungry. Feed the starter three days running.",
                 xp: 55, value: { Double($0.starter.feedStreak) }, target: 3, unit: "days running"),
        countReq(id: "r06", title: "Steam in the Oven", client: "The Crust Enthusiast",
                 brief: "Real crust wants steam. Use the steam kettle in three bakes.",
                 xp: 50, value: { Double($0.stats.steamUses) }, target: 3, unit: "steamed bakes"),
        countReq(id: "r07", title: "Signed with a Blade", client: "The Old Lame",
                 brief: "A slash is a baker's signature. Cut ten scoring slashes across your bakes.",
                 xp: 55, value: { Double($0.stats.slashesCut) }, target: 10, unit: "slashes"),
        countReq(id: "r08", title: "The Student", client: "The Flour-Dusted Bookshelf",
                 brief: "Read four chapters of the baker's handbook between batches.",
                 xp: 50, value: { Double($0.stats.guidesRead.count) }, target: 4, unit: "chapters"),
    ]

    private static let second: [BakeRequest] = [
        countReq(id: "r09", title: "Layers upon Layers", client: "The Pastry Case",
                 brief: "The glass case longs for lamination. Finish two laminated bakes.",
                 xp: 80, value: { Double($0.stats.laminatedBakes) }, target: 2, unit: "laminated bakes"),
        countReq(id: "r10", title: "Wild Raised", client: "The Jar on the Sill",
                 brief: "The starter wants to prove itself. Bake two loaves raised on it alone.",
                 xp: 85, value: { Double($0.stats.starterBakes) }, target: 2, unit: "starter bakes"),
        countReq(id: "r11", title: "A Dozen Batches", client: "The Till",
                 brief: "Twelve bakes out of this little oven and the ledger starts smiling.",
                 xp: 75, value: { Double($0.stats.bakesFinished) }, target: 12, unit: "bakes"),
        countReq(id: "r12", title: "The Examiner Calls", client: "The Guild of Bakers",
                 brief: "The guild sends its exam. Score at least eight of ten.",
                 xp: 70, value: { Double($0.stats.quizBest) }, target: 8, unit: "best score"),
        BakeRequest(id: "r13", title: "The Enriched Shelf", client: "Sunday Visitors",
                    brief: "Butter, eggs and patience: bake every recipe in the enriched chapter.",
                    rewardXP: 90) { store in
            let ids = BakeBook.recipes.filter { $0.chapter == 1 }.map { $0.id }
            let done = ids.filter { store.stats.bestStars[$0] != nil }.count
            return (Double(done) / Double(ids.count), "\(done) of \(ids.count) enriched bakes made")
        },
        countReq(id: "r14", title: "Five Gold Mornings", client: "A Very Particular Customer",
                 brief: "She is back, and she has friends. Five three-star bakes on the shelf.",
                 xp: 100, value: { Double($0.stats.threeStarBakes) }, target: 5, unit: "three-star bakes"),
        countReq(id: "r15", title: "A Week at the Ovens", client: "The Flour Calendar",
                 brief: "Come back to the bakery on five different days.",
                 xp: 80, value: { Double($0.stats.playDays.count) }, target: 5, unit: "days"),
        BakeRequest(id: "r16", title: "The Whole Book, Once", client: "The Guild of Bakers",
                    brief: "The guild's final request: bake at least half of everything the book holds.",
                    rewardXP: 130) { store in
            let total = BakeBook.recipes.count
            let done = store.stats.bestStars.count
            let target = total / 2
            return (Double(done) / Double(target), "\(min(done, target)) of \(target) different bakes made")
        },
    ]
}
