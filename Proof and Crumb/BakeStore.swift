import SwiftUI
import Combine

struct BakeRank {
    let name: String
    let xp: Int
}

struct StarterState: Codable {
    var name: String = "Poppy"
    var health: Double = 55
    var lastFedDay: String = ""
    var feedStreak: Int = 0
    var totalFeeds: Int = 0
    var born: Date = Date()
}

struct BakeStats: Codable {
    var xp: Int = 0
    var bakesFinished: Int = 0
    var threeStarBakes: Int = 0
    var bestStars: [String: Int] = [:]
    var records: [BakeRecord] = []
    var guidesRead: Set<String> = []
    var quizBest: Int = 0
    var quizRounds: Int = 0
    var requestsDone: Set<String> = []
    var playDays: Set<String> = []
    var bestDayStreak: Int = 0
    var dailyDoneDays: Set<String> = []
    var laminatedBakes: Int = 0
    var starterBakes: Int = 0
    var slashesCut: Int = 0
    var steamUses: Int = 0
    var awards: Set<String> = []
}

struct BakeSave: Codable {
    var stats: BakeStats?
    var starter: StarterState?
    var onboardingDone: Bool?
    var reduceMotion: Bool?
}

final class BakeStore: ObservableObject {
    static let saveKey = "proof_crumb_save_v1"

    @Published var stats: BakeStats
    @Published var starter: StarterState
    @Published var onboardingDone: Bool
    @Published var reduceMotion: Bool
    @Published var celebration: String?

    private var saveWork: DispatchWorkItem?

    static let ranks: [BakeRank] = [
        BakeRank(name: "Flour Sweeper", xp: 0),
        BakeRank(name: "Dough Hand", xp: 120),
        BakeRank(name: "Oven Watcher", xp: 320),
        BakeRank(name: "Shaper of Loaves", xp: 620),
        BakeRank(name: "Crust Reader", xp: 1000),
        BakeRank(name: "Laminator", xp: 1500),
        BakeRank(name: "Keeper of the Starter", xp: 2100),
        BakeRank(name: "Master Baker", xp: 2900),
    ]

    init() {
        var loadedStats = BakeStats()
        var loadedStarter = StarterState()
        var loadedOnboarding = false
        var loadedReduce = false
        if let data = UserDefaults.standard.data(forKey: BakeStore.saveKey),
           let save = try? JSONDecoder().decode(BakeSave.self, from: data) {
            loadedStats = save.stats ?? BakeStats()
            loadedStarter = save.starter ?? StarterState()
            loadedOnboarding = save.onboardingDone ?? false
            loadedReduce = save.reduceMotion ?? false
        }
        stats = loadedStats
        starter = loadedStarter
        onboardingDone = loadedOnboarding
        reduceMotion = loadedReduce
        decayStarterIfNeeded()
        touchPlayDay()
    }

    static func dayKey(_ date: Date = Date()) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        fmt.locale = Locale(identifier: "en_US_POSIX")
        return fmt.string(from: date)
    }

    var rankIndex: Int {
        var idx = 0
        for (i, rank) in BakeStore.ranks.enumerated() where stats.xp >= rank.xp { idx = i }
        return idx
    }

    var rank: BakeRank { BakeStore.ranks[rankIndex] }

    var nextRank: BakeRank? {
        rankIndex + 1 < BakeStore.ranks.count ? BakeStore.ranks[rankIndex + 1] : nil
    }

    var rankProgress: Double {
        guard let next = nextRank else { return 1 }
        let base = BakeStore.ranks[rankIndex].xp
        return Double(stats.xp - base) / Double(next.xp - base)
    }

    func isUnlocked(_ recipe: BakeRecipe) -> Bool {
        recipe.unlockRank <= rankIndex
    }

    func starterReady(_ recipe: BakeRecipe) -> Bool {
        !recipe.needsStarter || starter.health >= 50
    }

    func addXP(_ amount: Int) {
        guard amount > 0 else { return }
        let before = rankIndex
        stats.xp += amount
        if rankIndex > before {
            celebration = "Promoted to \(rank.name)!"
            BakeHaptics.success()
        }
        scheduleSave()
    }

    var dailyRecipe: BakeRecipe {
        let day = Calendar.current.ordinality(of: .day, in: .era, for: Date()) ?? 0
        let unlocked = BakeBook.recipes.filter { isUnlocked($0) && !$0.needsStarter }
        let pool = unlocked.isEmpty ? [BakeBook.recipes[0]] : unlocked
        return pool[day % pool.count]
    }

    var dailyDoneToday: Bool {
        stats.dailyDoneDays.contains(BakeStore.dayKey())
    }

    func recordBake(recipe: BakeRecipe, marks: StageMarks, crust: Double, hydration: Double, ferment: Double, gluten: Double, usedSteam: Bool) -> BakeRecord {
        let stars = marks.stars(for: recipe)
        let record = BakeRecord(
            recipeID: recipe.id, date: Date(), stars: stars, quality: marks.overall(for: recipe),
            crust: crust, hydration: hydration, ferment: ferment, gluten: gluten)
        stats.records.insert(record, at: 0)
        if stats.records.count > 48 { stats.records.removeLast(stats.records.count - 48) }
        stats.bakesFinished += 1
        if stats.bakesFinished == 5 {
            celebration = "A marmalade cat has moved into the shop window"
        }
        if stars == 3 { stats.threeStarBakes += 1 }
        if recipe.stages.contains(.laminate) { stats.laminatedBakes += 1 }
        if recipe.needsStarter { stats.starterBakes += 1 }
        if usedSteam { stats.steamUses += 1 }
        stats.slashesCut += recipe.slashCount
        let prev = stats.bestStars[recipe.id] ?? 0
        if stars > prev { stats.bestStars[recipe.id] = stars }
        var xp = recipe.baseXP * stars / 2
        if dailyRecipe.id == recipe.id && !dailyDoneToday {
            stats.dailyDoneDays.insert(BakeStore.dayKey())
            xp = Int(Double(xp) * 1.5)
        }
        addXP(max(10, xp))
        touchPlayDay()
        checkAwards()
        scheduleSave()
        return record
    }

    func decayStarterIfNeeded() {
        guard !starter.lastFedDay.isEmpty else { return }
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        fmt.locale = Locale(identifier: "en_US_POSIX")
        guard let lastDate = fmt.date(from: starter.lastFedDay) else { return }
        let days = Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
        if days > 1 {
            starter.health = (starter.health - Double(days - 1) * 14).bakeClamped(5, 100)
            if days > 2 { starter.feedStreak = 0 }
        }
    }

    var starterFedToday: Bool {
        starter.lastFedDay == BakeStore.dayKey()
    }

    func feedStarter() {
        let today = BakeStore.dayKey()
        if starter.lastFedDay == today {
            starter.health = (starter.health + 2).bakeClamped(0, 100)
        } else {
            let fmt = DateFormatter()
            fmt.dateFormat = "yyyy-MM-dd"
            fmt.locale = Locale(identifier: "en_US_POSIX")
            if let lastDate = fmt.date(from: starter.lastFedDay),
               let days = Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day,
               days == 1 {
                starter.feedStreak += 1
            } else {
                starter.feedStreak = 1
            }
            starter.lastFedDay = today
            starter.health = (starter.health + 24).bakeClamped(0, 100)
            starter.totalFeeds += 1
            addXP(8)
        }
        BakeHaptics.thump()
        checkAwards()
        scheduleSave()
    }

    var starterMood: String {
        if starter.health >= 85 { return "bubbling with enthusiasm" }
        if starter.health >= 65 { return "lively and ready to bake" }
        if starter.health >= 50 { return "awake, if a little slow" }
        if starter.health >= 30 { return "sluggish and hungry" }
        return "fast asleep under a sad grey crust"
    }

    func touchPlayDay() {
        let today = BakeStore.dayKey()
        if !stats.playDays.contains(today) {
            stats.playDays.insert(today)
            var streak = 1
            var day = Date()
            let fmt = DateFormatter()
            fmt.dateFormat = "yyyy-MM-dd"
            fmt.locale = Locale(identifier: "en_US_POSIX")
            while true {
                guard let prev = Calendar.current.date(byAdding: .day, value: -1, to: day) else { break }
                if stats.playDays.contains(fmt.string(from: prev)) {
                    streak += 1
                    day = prev
                } else {
                    break
                }
            }
            stats.bestDayStreak = max(stats.bestDayStreak, streak)
            scheduleSave()
        }
    }

    var currentDayStreak: Int {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        fmt.locale = Locale(identifier: "en_US_POSIX")
        var streak = 0
        var day = Date()
        while stats.playDays.contains(fmt.string(from: day)) {
            streak += 1
            guard let prev = Calendar.current.date(byAdding: .day, value: -1, to: day) else { break }
            day = prev
        }
        return streak
    }

    func recordGuideRead(_ id: String) {
        if !stats.guidesRead.contains(id) {
            stats.guidesRead.insert(id)
            addXP(15)
            checkAwards()
        }
    }

    func recordQuiz(score: Int) {
        stats.quizRounds += 1
        if score > stats.quizBest { stats.quizBest = score }
        addXP(score * 6)
        checkAwards()
    }

    func completeRequest(_ request: BakeRequest) {
        guard !stats.requestsDone.contains(request.id) else { return }
        stats.requestsDone.insert(request.id)
        addXP(request.rewardXP)
        celebration = "Request filled: \(request.title)"
        BakeHaptics.success()
        checkAwards()
    }

    func checkAwards() {
        var earned: BakeAward?
        for award in BakeAwards.all where !stats.awards.contains(award.id) {
            if award.check(self) {
                stats.awards.insert(award.id)
                earned = award
            }
        }
        if let award = earned {
            celebration = "Award earned: \(award.name)"
            BakeHaptics.success()
        }
        scheduleSave()
    }

    func resetAll() {
        stats = BakeStats()
        starter = StarterState()
        onboardingDone = true
        scheduleSave()
    }

    func scheduleSave() {
        saveWork?.cancel()
        let work = DispatchWorkItem { [weak self] in self?.saveNow() }
        saveWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: work)
    }

    func saveNow() {
        let save = BakeSave(stats: stats, starter: starter, onboardingDone: onboardingDone, reduceMotion: reduceMotion)
        if let data = try? JSONEncoder().encode(save) {
            UserDefaults.standard.set(data, forKey: BakeStore.saveKey)
        }
    }
}
