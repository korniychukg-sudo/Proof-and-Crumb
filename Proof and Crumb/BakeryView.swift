import SwiftUI

struct BakeryView: View {
    @EnvironmentObject var store: BakeStore
    @State private var phaseStart = Date()

    var body: some View {
        ZStack {
            FlourBackdrop()
            ScrollView {
                VStack(spacing: 16) {
                    header
                    TimelineView(.animation(minimumInterval: store.reduceMotion ? 0.6 : 1.0 / 20.0)) { timeline in
                        let phase = timeline.date.timeIntervalSince(phaseStart)
                        ShopWindowScene(records: store.stats.records, phase: phase, daylight: daylight, catPresent: store.stats.bakesFinished >= 5)
                            .frame(height: 250)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .shadow(color: BakeTheme.cardShadow, radius: 7, x: 0, y: 3)
                    }
                    dailyCard
                    starterCard
                    BakeSectionHeader(title: "The Counter Book", subtitle: "Requests from the village, filled in your own time")
                    ForEach(BakeRequests.all) { request in
                        NavigationLink(destination: RequestDetailView(request: request).environmentObject(store)) {
                            requestRow(request)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 90)
            }
            if let text = store.celebration {
                BakeCelebrationBanner(text: text) {
                    withAnimation { store.celebration = nil }
                }
                .zIndex(3)
            }
        }
        .navigationBarHidden(true)
    }

    private var daylight: Double {
        let hour = Double(Calendar.current.component(.hour, from: Date()))
        if hour < 6 || hour >= 21 { return 0 }
        if hour < 9 { return (hour - 6) / 3 }
        if hour >= 18 { return 1 - (hour - 18) / 3 }
        return 1
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Proof & Crumb")
                    .font(BakeTheme.title(26))
                    .foregroundColor(BakeTheme.ink)
                Text("\(store.rank.name) · \(store.stats.xp) XP")
                    .font(BakeTheme.body(13))
                    .foregroundColor(BakeTheme.inkFaint)
            }
            Spacer()
            ZStack {
                BakeProgressRing(progress: store.rankProgress, size: 46, lineWidth: 5)
                BIcon(kind: .wheatStalk, size: 18, color: BakeTheme.wheatDeep)
            }
        }
    }

    private var dailyCard: some View {
        let recipe = store.dailyRecipe
        return NavigationLink(destination: RecipeDetailView(recipe: recipe).environmentObject(store)) {
            HStack(spacing: 14) {
                ZStack {
                    Circle().fill(BakeTheme.terracotta.opacity(0.14)).frame(width: 54, height: 54)
                    BIcon(kind: .timerGlass, size: 26, color: BakeTheme.terraDeep)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("Today's bake: \(recipe.name)")
                        .font(BakeTheme.heading(15))
                        .foregroundColor(BakeTheme.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Text(store.dailyDoneToday ? "Baked and shelved — half again the experience, banked." : "Half again the experience while the day lasts.")
                        .font(BakeTheme.body(12))
                        .foregroundColor(store.dailyDoneToday ? BakeTheme.sageDeep : BakeTheme.inkFaint)
                }
                Spacer()
                if store.dailyDoneToday {
                    BIcon(kind: .check, size: 16, color: BakeTheme.sageDeep)
                } else {
                    BIcon(kind: .chevronRight, size: 14, color: BakeTheme.inkFaint)
                }
            }
            .bakeCard()
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var starterCard: some View {
        NavigationLink(destination: StarterView().environmentObject(store)) {
            HStack(spacing: 14) {
                TimelineView(.animation(minimumInterval: store.reduceMotion ? 0.6 : 1.0 / 20.0)) { timeline in
                    StarterJarView(health: store.starter.health, phase: timeline.date.timeIntervalSince(phaseStart), size: 46)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("\(store.starter.name) the starter")
                        .font(BakeTheme.heading(15))
                        .foregroundColor(BakeTheme.ink)
                    Text("Health \(Int(store.starter.health)) — \(store.starterMood)")
                        .font(BakeTheme.body(12))
                        .foregroundColor(store.starter.health < 40 ? BakeTheme.berry : BakeTheme.inkFaint)
                        .lineLimit(2)
                }
                Spacer()
                if !store.starterFedToday {
                    Text("Hungry")
                        .font(BakeTheme.body(11))
                        .foregroundColor(BakeTheme.berry)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(BakeTheme.berry.opacity(0.12)))
                }
                BIcon(kind: .chevronRight, size: 14, color: BakeTheme.inkFaint)
            }
            .bakeCard()
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func requestRow(_ request: BakeRequest) -> some View {
        let done = store.stats.requestsDone.contains(request.id)
        let ready = !done && request.satisfied(store)
        let (fraction, _) = request.progress(store)
        return HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(done ? BakeTheme.sage.opacity(0.16) : (ready ? BakeTheme.wheat.opacity(0.22) : BakeTheme.ink.opacity(0.05)))
                    .frame(width: 40, height: 40)
                if done {
                    BIcon(kind: .check, size: 16, color: BakeTheme.sageDeep)
                } else if ready {
                    BIcon(kind: .star, size: 17, color: BakeTheme.wheatDeep)
                } else {
                    Text("\(Int(fraction * 100))%")
                        .font(BakeTheme.mono(10))
                        .foregroundColor(BakeTheme.inkSoft)
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(request.title)
                    .font(BakeTheme.heading(15))
                    .foregroundColor(done ? BakeTheme.inkFaint : BakeTheme.ink)
                Text("From \(request.client) · \(request.rewardXP) XP")
                    .font(BakeTheme.body(11))
                    .foregroundColor(BakeTheme.inkFaint)
                if !done {
                    BakeProgressBar(progress: fraction, color: ready ? BakeTheme.wheat : BakeTheme.sage.opacity(0.7), height: 5)
                        .padding(.top, 3)
                }
            }
            Spacer()
            BIcon(kind: .chevronRight, size: 13, color: BakeTheme.inkFaint)
        }
        .bakeCard(padding: 13)
        .opacity(done ? 0.75 : 1)
    }
}

struct RequestDetailView: View {
    @EnvironmentObject var store: BakeStore
    @Environment(\.presentationMode) var presentationMode
    let request: BakeRequest
    @State private var celebrate = false

    var body: some View {
        ZStack {
            FlourBackdrop()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            BIcon(kind: .chevronRight, size: 15, color: BakeTheme.inkSoft)
                                .rotationEffect(.degrees(180))
                                .padding(9)
                                .background(Circle().fill(BakeTheme.ink.opacity(0.07)))
                        }
                        Spacer()
                        Text("\(request.rewardXP) XP")
                            .font(BakeTheme.heading(13))
                            .foregroundColor(BakeTheme.wheatDeep)
                            .padding(.horizontal, 11)
                            .padding(.vertical, 5)
                            .background(Capsule().fill(BakeTheme.wheat.opacity(0.15)))
                    }
                    Text(request.title)
                        .font(BakeTheme.title(25))
                        .foregroundColor(BakeTheme.ink)
                    Text("A request from \(request.client)")
                        .font(BakeTheme.body(13))
                        .foregroundColor(BakeTheme.inkFaint)
                    Text(request.brief)
                        .font(BakeTheme.serif(16))
                        .foregroundColor(BakeTheme.ink)
                        .lineSpacing(5)
                    BakeDivider()
                    let (fraction, text) = request.progress(store)
                    VStack(alignment: .leading, spacing: 8) {
                        Text(text)
                            .font(BakeTheme.body(13))
                            .foregroundColor(BakeTheme.inkSoft)
                        BakeProgressBar(progress: fraction, color: fraction >= 1 ? BakeTheme.sage : BakeTheme.wheat)
                    }
                    .bakeCard(padding: 14)
                    if store.stats.requestsDone.contains(request.id) {
                        HStack(spacing: 8) {
                            BIcon(kind: .check, size: 16, color: BakeTheme.sageDeep)
                            Text("Filled, delivered, and remembered fondly.")
                                .font(BakeTheme.heading(14))
                                .foregroundColor(BakeTheme.sageDeep)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(RoundedRectangle(cornerRadius: 14).fill(BakeTheme.sage.opacity(0.1)))
                    } else if request.satisfied(store) {
                        Button {
                            store.completeRequest(request)
                            celebrate = true
                        } label: {
                            Text("Hand it over the counter")
                        }
                        .buttonStyle(BakePrimaryButton(color: BakeTheme.wheatDeep))
                    } else {
                        Text("Keep baking — every loaf on any day counts toward the book.")
                            .font(BakeTheme.body(12))
                            .foregroundColor(BakeTheme.inkFaint)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 90)
            }
            if celebrate {
                BakeConfetti(seed: UInt64(abs(request.id.hashValue % 700)))
            }
        }
        .navigationBarHidden(true)
    }
}
