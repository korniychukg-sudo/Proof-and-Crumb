import SwiftUI

struct BakeAward: Identifiable {
    let id: String
    let name: String
    let blurb: String
    let emblem: Int
    let check: (BakeStore) -> Bool
    let progress: (BakeStore) -> (Double, String)
}

enum BakeAwards {
    static let all: [BakeAward] = a + b

    private static func countAward(id: String, name: String, blurb: String, emblem: Int, value: @escaping (BakeStore) -> Double, target: Double, unit: String) -> BakeAward {
        BakeAward(id: id, name: name, blurb: blurb, emblem: emblem,
                  check: { value($0) >= target },
                  progress: { store in
                      let v = value(store)
                      return (min(1, v / target), "\(Int(min(v, target))) of \(Int(target)) \(unit)")
                  })
    }

    private static let a: [BakeAward] = [
        countAward(id: "b_first", name: "First Bake", blurb: "Pull your first bake from the little oven.", emblem: 0,
                   value: { Double($0.stats.bakesFinished) }, target: 1, unit: "bakes"),
        countAward(id: "b_ten", name: "Steady Hands", blurb: "Finish ten bakes.", emblem: 1,
                   value: { Double($0.stats.bakesFinished) }, target: 10, unit: "bakes"),
        countAward(id: "b_thirty", name: "The Regular Oven", blurb: "Finish thirty bakes.", emblem: 2,
                   value: { Double($0.stats.bakesFinished) }, target: 30, unit: "bakes"),
        countAward(id: "b_gold1", name: "Window Worthy", blurb: "Earn your first three-star bake.", emblem: 3,
                   value: { Double($0.stats.threeStarBakes) }, target: 1, unit: "three-star bakes"),
        countAward(id: "b_gold8", name: "The Gold Shelf", blurb: "Earn eight three-star bakes.", emblem: 4,
                   value: { Double($0.stats.threeStarBakes) }, target: 8, unit: "three-star bakes"),
        BakeAward(id: "b_variety", name: "Round the Book", blurb: "Bake ten different recipes.", emblem: 5,
                  check: { $0.stats.bestStars.count >= 10 },
                  progress: { (min(1, Double($0.stats.bestStars.count) / 10), "\($0.stats.bestStars.count) of 10 recipes") }),
        BakeAward(id: "b_wholebook", name: "Cover to Cover", blurb: "Bake every recipe in the book at least once.", emblem: 6,
                  check: { $0.stats.bestStars.count >= BakeBook.recipes.count },
                  progress: { (min(1, Double($0.stats.bestStars.count) / Double(BakeBook.recipes.count)), "\($0.stats.bestStars.count) of \(BakeBook.recipes.count) recipes") }),
        countAward(id: "b_laminate", name: "Twenty-Seven Layers", blurb: "Finish three laminated bakes.", emblem: 7,
                   value: { Double($0.stats.laminatedBakes) }, target: 3, unit: "laminated bakes"),
        countAward(id: "b_steam", name: "The Kettle Trick", blurb: "Bake with steam five times.", emblem: 8,
                   value: { Double($0.stats.steamUses) }, target: 5, unit: "steamed bakes"),
        countAward(id: "b_lame", name: "A Steady Blade", blurb: "Cut twenty-five scoring slashes.", emblem: 9,
                   value: { Double($0.stats.slashesCut) }, target: 25, unit: "slashes"),
    ]

    private static let b: [BakeAward] = [
        countAward(id: "b_feed1", name: "Something Stirs", blurb: "Feed the starter for the first time.", emblem: 10,
                   value: { Double($0.starter.totalFeeds) }, target: 1, unit: "feeds"),
        countAward(id: "b_feed7", name: "The Faithful Keeper", blurb: "Feed the starter seven days in a row.", emblem: 11,
                   value: { Double($0.starter.feedStreak) }, target: 7, unit: "days running"),
        BakeAward(id: "b_thriving", name: "Bubbling Over", blurb: "Bring the starter to full, rolling health.", emblem: 12,
                  check: { $0.starter.health >= 95 },
                  progress: { (min(1, $0.starter.health / 95), "Health \(Int($0.starter.health)) of 95") }),
        countAward(id: "b_wild", name: "Wild Raised", blurb: "Bake three loaves raised on your own starter.", emblem: 13,
                   value: { Double($0.stats.starterBakes) }, target: 3, unit: "starter bakes"),
        BakeAward(id: "b_scholar", name: "The Floury Scholar", blurb: "Read every chapter of the handbook.", emblem: 14,
                  check: { $0.stats.guidesRead.count >= BakeGuides.all.count },
                  progress: { (min(1, Double($0.stats.guidesRead.count) / Double(BakeGuides.all.count)), "\($0.stats.guidesRead.count) of \(BakeGuides.all.count) chapters") }),
        BakeAward(id: "b_exam", name: "Guild Certificate", blurb: "Score a perfect ten on the guild exam.", emblem: 15,
                  check: { $0.stats.quizBest >= 10 },
                  progress: { (Double($0.stats.quizBest) / 10, "Best score \($0.stats.quizBest) of 10") }),
        BakeAward(id: "b_requests", name: "Well Regarded", blurb: "Fill eight requests from the counter book.", emblem: 16,
                  check: { $0.stats.requestsDone.count >= 8 },
                  progress: { (min(1, Double($0.stats.requestsDone.count) / 8), "\($0.stats.requestsDone.count) of 8 requests") }),
        BakeAward(id: "b_allreq", name: "The Counter Book, Closed", blurb: "Fill every request in the book.", emblem: 17,
                  check: { $0.stats.requestsDone.count >= BakeRequests.all.count },
                  progress: { (min(1, Double($0.stats.requestsDone.count) / Double(BakeRequests.all.count)), "\($0.stats.requestsDone.count) of \(BakeRequests.all.count) requests") }),
        countAward(id: "b_streak", name: "Three Warm Mornings", blurb: "Visit the bakery three days in a row.", emblem: 18,
                   value: { Double($0.stats.bestDayStreak) }, target: 3, unit: "days"),
        BakeAward(id: "b_master", name: "Master Baker", blurb: "Reach the highest rank the guild bestows.", emblem: 19,
                  check: { $0.rankIndex >= BakeStore.ranks.count - 1 },
                  progress: { (Double($0.rankIndex) / Double(BakeStore.ranks.count - 1), $0.rank.name) }),
    ]
}
