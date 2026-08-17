import SwiftUI

struct JournalView: View {
    @EnvironmentObject var store: BakeStore
    @State private var showReset = false
    @State private var showPrivacy = false

    private var awardColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 78), spacing: 12)]
    }

    var body: some View {
        ZStack {
            FlourBackdrop()
            ScrollView {
                VStack(spacing: 16) {
                    BakeSectionHeader(title: "The Flour Journal", subtitle: "Everything the bakery remembers")
                    rankCard
                    statsGrid
                    if !store.stats.records.isEmpty {
                        BakeSectionHeader(title: "Recent Bakes", subtitle: "The last loaves out of the oven")
                        recentBakes
                    }
                    BakeSectionHeader(title: "Awards", subtitle: "\(store.stats.awards.count) of \(BakeAwards.all.count) earned")
                    LazyVGrid(columns: awardColumns, spacing: 12) {
                        ForEach(BakeAwards.all) { award in
                            NavigationLink(destination: BakeAwardDetailView(award: award).environmentObject(store)) {
                                VStack(spacing: 5) {
                                    BakeAwardEmblem(index: award.emblem, earned: store.stats.awards.contains(award.id), size: 56)
                                    Text(award.name)
                                        .font(BakeTheme.body(10))
                                        .foregroundColor(BakeTheme.inkSoft)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.center)
                                        .frame(height: 26)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    BakeSectionHeader(title: "Bakery Settings")
                    settingsCard
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 90)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showPrivacy) {
            BakePrivacySheet()
        }
    }

    private var rankCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(store.rank.name)
                        .font(BakeTheme.title(20))
                        .foregroundColor(BakeTheme.ink)
                    if let next = store.nextRank {
                        Text("\(next.xp - store.stats.xp) XP to \(next.name)")
                            .font(BakeTheme.body(12))
                            .foregroundColor(BakeTheme.inkFaint)
                    } else {
                        Text("The guild has no higher honour to give")
                            .font(BakeTheme.body(12))
                            .foregroundColor(BakeTheme.inkFaint)
                    }
                }
                Spacer()
                ZStack {
                    BakeProgressRing(progress: store.rankProgress, size: 54, lineWidth: 6)
                    Text("\(store.stats.xp)")
                        .font(BakeTheme.mono(11))
                        .foregroundColor(BakeTheme.inkSoft)
                        .minimumScaleFactor(0.6)
                        .frame(width: 38)
                }
            }
            BakeProgressBar(progress: store.rankProgress)
            Text("Experience comes from bakes and their stars, requests, handbook chapters, the exam, and a well-fed starter. Ranks open new pages of the bake book.")
                .font(BakeTheme.body(12))
                .foregroundColor(BakeTheme.inkFaint)
        }
        .bakeCard()
    }

    private var statsGrid: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                BakeStatChip(icon: .oven, value: "\(store.stats.bakesFinished)", label: "Bakes")
                BakeStatChip(icon: .star, value: "\(store.stats.threeStarBakes)", label: "Three-star")
                BakeStatChip(icon: .book, value: "\(store.stats.bestStars.count)", label: "Recipes tried")
            }
            HStack(spacing: 10) {
                BakeStatChip(icon: .knife, value: "\(store.stats.slashesCut)", label: "Slashes cut")
                BakeStatChip(icon: .jar, value: "\(store.starter.totalFeeds)", label: "Starter feeds")
                BakeStatChip(icon: .timerGlass, value: "\(store.currentDayStreak)", label: "Day streak")
            }
        }
    }

    private var recentBakes: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(store.stats.records.prefix(10)) { record in
                    let recipe = BakeBook.recipe(record.recipeID)
                    VStack(spacing: 6) {
                        Canvas { ctx, size in
                            let rect = CGRect(origin: .zero, size: size).insetBy(dx: 6, dy: 6)
                            DoughArtist.drawLoaf(&ctx, rect: rect, shape: recipe.shapeKind, tint: recipe.doughTint, crust: record.crust, slashes: [], seed: 33)
                        }
                        .frame(width: 84, height: 60)
                        .background(RoundedRectangle(cornerRadius: 10).fill(BakeTheme.cream))
                        Text(recipe.name)
                            .font(BakeTheme.body(10))
                            .foregroundColor(BakeTheme.inkSoft)
                            .lineLimit(1)
                            .frame(width: 84)
                        StarRow(stars: record.stars, size: 9)
                    }
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 13).fill(BakeTheme.paper).shadow(color: BakeTheme.cardShadow, radius: 4, x: 0, y: 2))
                }
            }
            .padding(.vertical, 2)
        }
    }

    private var settingsCard: some View {
        VStack(spacing: 14) {
            Toggle(isOn: Binding(
                get: { store.reduceMotion },
                set: { store.reduceMotion = $0; store.scheduleSave() })) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Calm the animations")
                        .font(BakeTheme.body(14))
                        .foregroundColor(BakeTheme.ink)
                    Text("Slows the shop window and the jar")
                        .font(BakeTheme.body(11))
                        .foregroundColor(BakeTheme.inkFaint)
                }
            }
            .toggleStyle(SwitchToggleStyle(tint: BakeTheme.terracotta))
            BakeDivider()
            Button {
                showPrivacy = true
            } label: {
                HStack {
                    Text("Privacy")
                        .font(BakeTheme.body(14))
                        .foregroundColor(BakeTheme.ink)
                    Spacer()
                    BIcon(kind: .chevronRight, size: 12, color: BakeTheme.inkFaint)
                }
            }
            BakeDivider()
            Button {
                showReset = true
            } label: {
                HStack {
                    Text("Sweep the bakery and start again")
                        .font(BakeTheme.body(14))
                        .foregroundColor(BakeTheme.berry)
                    Spacer()
                }
            }
        }
        .bakeCard()
        .alert(isPresented: $showReset) {
            Alert(
                title: Text("Start the whole bakery again?"),
                message: Text("Every bake, request, award and the starter itself goes back in the cupboard. There is no way to undo this."),
                primaryButton: .destructive(Text("Start again")) {
                    store.resetAll()
                },
                secondaryButton: .cancel())
        }
    }
}

struct BakeAwardDetailView: View {
    @EnvironmentObject var store: BakeStore
    @Environment(\.presentationMode) var presentationMode
    let award: BakeAward

    var body: some View {
        ZStack {
            FlourBackdrop()
            VStack(spacing: 18) {
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
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                Spacer()
                BakeAwardEmblem(index: award.emblem, earned: store.stats.awards.contains(award.id), size: 148)
                Text(award.name)
                    .font(BakeTheme.title(24))
                    .foregroundColor(BakeTheme.ink)
                Text(award.blurb)
                    .font(BakeTheme.serif(16))
                    .foregroundColor(BakeTheme.inkSoft)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 44)
                let (fraction, text) = award.progress(store)
                VStack(spacing: 8) {
                    BakeProgressBar(progress: fraction, color: store.stats.awards.contains(award.id) ? BakeTheme.sage : BakeTheme.wheat)
                    Text(store.stats.awards.contains(award.id) ? "Earned, polished, and hung by the ovens" : text)
                        .font(BakeTheme.body(13))
                        .foregroundColor(BakeTheme.inkFaint)
                }
                .padding(.horizontal, 44)
                Spacer()
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
}

struct BakePrivacySheet: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            FlourBackdrop()
            VStack(spacing: 0) {
                HStack {
                    Text("Privacy")
                        .font(BakeTheme.title(20))
                        .foregroundColor(BakeTheme.ink)
                    Spacer()
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        BIcon(kind: .close, size: 15, color: BakeTheme.inkSoft)
                            .padding(8)
                            .background(Circle().fill(BakeTheme.ink.opacity(0.07)))
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 18)
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        privacyBlock(
                            title: "Everything stays on this device",
                            body: "Proof & Crumb is a fully offline app. Your bakes, requests, awards, and the starter itself live only on this device, in the app's own storage. Nothing is sent anywhere, because the app has no way to send anything: it contains no networking code at all.")
                        privacyBlock(
                            title: "No account, no tracking",
                            body: "There is no sign-up, no analytics, no advertising, and no third-party services of any kind. The app never asks for permissions because it does not use the camera, microphone, location, contacts, photos or notifications.")
                        privacyBlock(
                            title: "Deleting your data",
                            body: "Deleting the app removes everything it ever stored. You can also sweep the bakery clean from within the app in Journal, Bakery Settings, without deleting the app itself.")
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 12)
                    .padding(.bottom, 40)
                }
            }
        }
    }

    private func privacyBlock(title: String, body text: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(BakeTheme.heading(15))
                .foregroundColor(BakeTheme.ink)
            Text(text)
                .font(BakeTheme.body(14))
                .foregroundColor(BakeTheme.inkSoft)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bakeCard()
    }
}
