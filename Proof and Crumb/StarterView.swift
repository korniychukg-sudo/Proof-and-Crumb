import SwiftUI

struct StarterView: View {
    @EnvironmentObject var store: BakeStore
    @State private var phaseStart = Date()
    @State private var renaming = false
    @State private var nameText = ""
    @State private var feedBurst = false

    var body: some View {
        ZStack {
            FlourBackdrop()
            ScrollView {
                VStack(spacing: 16) {
                    BakeSectionHeader(title: "The Jar on the Sill", subtitle: "A very slow pet that pays rent in bread")
                    ZStack {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(LinearGradient(colors: [BakeTheme.sky.opacity(0.5), BakeTheme.paper], startPoint: .top, endPoint: .bottom))
                            .shadow(color: BakeTheme.cardShadow, radius: 7, x: 0, y: 3)
                        VStack(spacing: 8) {
                            TimelineView(.animation(minimumInterval: store.reduceMotion ? 0.5 : 1.0 / 24.0)) { timeline in
                                StarterJarView(health: store.starter.health, phase: timeline.date.timeIntervalSince(phaseStart), size: 150)
                            }
                            if renaming {
                                TextField("Name the starter", text: $nameText, onCommit: {
                                    let trimmed = nameText.trimmingCharacters(in: .whitespaces)
                                    if !trimmed.isEmpty {
                                        store.starter.name = String(trimmed.prefix(16))
                                        store.scheduleSave()
                                    }
                                    renaming = false
                                })
                                .font(BakeTheme.heading(17))
                                .multilineTextAlignment(.center)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 200)
                            } else {
                                Button {
                                    nameText = store.starter.name
                                    renaming = true
                                } label: {
                                    HStack(spacing: 6) {
                                        Text(store.starter.name)
                                            .font(BakeTheme.title(20))
                                            .foregroundColor(BakeTheme.ink)
                                        Text("rename")
                                            .font(BakeTheme.body(11))
                                            .foregroundColor(BakeTheme.inkFaint)
                                    }
                                }
                            }
                            Text("is \(store.starterMood)")
                                .font(BakeTheme.serif(14))
                                .italic()
                                .foregroundColor(BakeTheme.inkSoft)
                        }
                        .padding(.vertical, 18)
                    }
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Health")
                                .font(BakeTheme.heading(13))
                                .foregroundColor(BakeTheme.inkFaint)
                            Spacer()
                            Text("\(Int(store.starter.health)) / 100")
                                .font(BakeTheme.mono(13))
                                .foregroundColor(BakeTheme.inkSoft)
                        }
                        BakeProgressBar(progress: store.starter.health / 100, color: store.starter.health >= 50 ? BakeTheme.sage : BakeTheme.berry)
                        Text(store.starter.health >= 50 ? "Strong enough to raise a sourdough loaf." : "Below 50, the sourdough pages of the book stay closed.")
                            .font(BakeTheme.body(12))
                            .foregroundColor(BakeTheme.inkFaint)
                    }
                    .bakeCard(padding: 14)
                    Button {
                        store.feedStarter()
                        feedBurst = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { feedBurst = false }
                    } label: {
                        Text(store.starterFedToday ? "A little extra flour (fed today)" : "Feed with flour and water")
                    }
                    .buttonStyle(BakePrimaryButton(color: store.starterFedToday ? BakeTheme.wheatDeep : BakeTheme.terracotta))
                    HStack(spacing: 10) {
                        BakeStatChip(icon: .timerGlass, value: "\(store.starter.feedStreak)", label: "Day streak")
                        BakeStatChip(icon: .drop, value: "\(store.starter.totalFeeds)", label: "Total feeds")
                        BakeStatChip(icon: .oven, value: "\(store.stats.starterBakes)", label: "Loaves raised")
                    }
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Keeping the jar")
                            .font(BakeTheme.heading(15))
                            .foregroundColor(BakeTheme.ink)
                        keepingRow("Feed once a day. A fed starter bubbles, rises, and holds its health.")
                        keepingRow("Miss a day and it forgives you; miss several and it sulks toward sleep.")
                        keepingRow("At health 50 or better it can raise the sourdough bakes in the book's last chapter.")
                        keepingRow("The float test in the handbook tells the truth about readiness — ripe starter floats.")
                    }
                    .bakeCard()
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 90)
            }
            if feedBurst {
                BakeConfetti(seed: 44)
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

    private func keepingRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Circle().fill(BakeTheme.wheat).frame(width: 6, height: 6).padding(.top, 6)
            Text(text)
                .font(BakeTheme.body(14))
                .foregroundColor(BakeTheme.inkSoft)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
