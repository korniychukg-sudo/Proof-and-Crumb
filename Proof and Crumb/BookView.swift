import SwiftUI

struct BookView: View {
    @EnvironmentObject var store: BakeStore

    var body: some View {
        ZStack {
            FlourBackdrop()
            ScrollView {
                VStack(spacing: 16) {
                    BakeSectionHeader(title: "The Bake Book", subtitle: "\(store.stats.bestStars.count) of \(BakeBook.recipes.count) bakes made at least once")
                    ForEach(BakeBook.chapters) { chapter in
                        chapterSection(chapter)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 90)
            }
        }
        .navigationBarHidden(true)
    }

    private func chapterSection(_ chapter: BakeChapter) -> some View {
        let recipes = BakeBook.recipes.filter { $0.chapter == chapter.id }
        let doneCount = recipes.filter { store.stats.bestStars[$0.id] != nil }.count
        return VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .bottomLeading) {
                BakeArtImage(name: chapter.banner)
                    .frame(height: 92)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                LinearGradient(colors: [.clear, Color.black.opacity(0.55)], startPoint: .top, endPoint: .bottom)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                VStack(alignment: .leading, spacing: 2) {
                    Text(chapter.name)
                        .font(BakeTheme.title(17))
                        .foregroundColor(.white)
                    Text(chapter.motto)
                        .font(BakeTheme.serif(12))
                        .italic()
                        .foregroundColor(.white.opacity(0.85))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .padding(12)
            }
            .frame(height: 92)
            .overlay(
                Text("\(doneCount)/\(recipes.count)")
                    .font(BakeTheme.mono(12))
                    .foregroundColor(.white)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.black.opacity(0.45)))
                    .padding(10),
                alignment: .topTrailing)
            ForEach(recipes) { recipe in
                NavigationLink(destination: RecipeDetailView(recipe: recipe).environmentObject(store)) {
                    recipeRow(recipe)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    private func recipeRow(_ recipe: BakeRecipe) -> some View {
        let unlocked = store.isUnlocked(recipe)
        let best = store.stats.bestStars[recipe.id] ?? 0
        return HStack(spacing: 12) {
            BakeArtImage(name: "bake_\(recipe.id)")
                .frame(width: 76, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                .opacity(unlocked ? 1 : 0.4)
            VStack(alignment: .leading, spacing: 3) {
                Text(recipe.name)
                    .font(BakeTheme.heading(15))
                    .foregroundColor(BakeTheme.ink)
                Text(recipe.blurb)
                    .font(BakeTheme.body(12))
                    .foregroundColor(BakeTheme.inkFaint)
                    .lineLimit(2)
                HStack(spacing: 8) {
                    if best > 0 {
                        StarRow(stars: best, size: 11)
                    }
                    if !unlocked {
                        BakeLockBadge(rankName: BakeStore.ranks[recipe.unlockRank].name)
                    }
                    if recipe.needsStarter {
                        HStack(spacing: 3) {
                            BIcon(kind: .jar, size: 11, color: store.starterReady(recipe) ? BakeTheme.sageDeep : BakeTheme.berry)
                            Text("starter")
                                .font(BakeTheme.body(10))
                                .foregroundColor(store.starterReady(recipe) ? BakeTheme.sageDeep : BakeTheme.berry)
                        }
                    }
                }
            }
            Spacer()
            BIcon(kind: .chevronRight, size: 13, color: BakeTheme.inkFaint)
        }
        .bakeCard(padding: 12)
    }
}

struct RecipeDetailView: View {
    @EnvironmentObject var store: BakeStore
    @Environment(\.presentationMode) var presentationMode
    let recipe: BakeRecipe
    @State private var showFlow = false

    var body: some View {
        ZStack {
            FlourBackdrop()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ZStack(alignment: .topLeading) {
                        BakeArtImage(name: "bake_\(recipe.id)")
                            .frame(maxWidth: .infinity)
                            .frame(height: 250)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(BakeTheme.crust.opacity(0.35), lineWidth: 1.5)
                            )
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            BIcon(kind: .chevronRight, size: 15, color: BakeTheme.flour)
                                .rotationEffect(.degrees(180))
                                .padding(10)
                                .background(Circle().fill(Color.black.opacity(0.4)))
                        }
                        .padding(12)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(recipe.name)
                                .font(BakeTheme.title(26))
                                .foregroundColor(BakeTheme.ink)
                            Spacer()
                            if let best = store.stats.bestStars[recipe.id] {
                                StarRow(stars: best, size: 15)
                            }
                        }
                        Text(recipe.blurb)
                            .font(BakeTheme.serif(15))
                            .italic()
                            .foregroundColor(BakeTheme.inkSoft)
                    }
                    HStack(spacing: 10) {
                        specChip(label: "Hydration", value: "\(Int(recipe.hydration * 100))%")
                        specChip(label: "Stages", value: "\(recipe.stages.count - 1)")
                        specChip(label: "Crust", value: crustWord(recipe.crustTarget))
                    }
                    if !store.isUnlocked(recipe) {
                        HStack(spacing: 8) {
                            BIcon(kind: .lock, size: 15, color: BakeTheme.wheatDeep)
                            Text("This page opens at the rank of \(BakeStore.ranks[recipe.unlockRank].name).")
                                .font(BakeTheme.body(13))
                                .foregroundColor(BakeTheme.inkSoft)
                        }
                        .bakeCard(padding: 12)
                    }
                    if recipe.needsStarter && !store.starterReady(recipe) {
                        HStack(spacing: 8) {
                            BIcon(kind: .jar, size: 15, color: BakeTheme.berry)
                            Text("\(store.starter.name) is too sleepy to raise this loaf. Feed the starter to health 50 or better.")
                                .font(BakeTheme.body(13))
                                .foregroundColor(BakeTheme.inkSoft)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .bakeCard(padding: 12)
                    }
                    BakeDivider()
                    Text(recipe.story)
                        .font(BakeTheme.serif(16))
                        .foregroundColor(BakeTheme.ink)
                        .lineSpacing(5)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Into the bowl, in order")
                            .font(BakeTheme.heading(14))
                            .foregroundColor(BakeTheme.ink)
                        ForEach(recipe.ingredients.indices, id: \.self) { idx in
                            HStack(spacing: 8) {
                                Text("\(idx + 1)")
                                    .font(BakeTheme.mono(11))
                                    .foregroundColor(BakeTheme.wheatDeep)
                                    .frame(width: 18)
                                Text(recipe.ingredients[idx])
                                    .font(BakeTheme.body(14))
                                    .foregroundColor(BakeTheme.inkSoft)
                            }
                        }
                    }
                    .bakeCard(padding: 14)
                    HStack(alignment: .top, spacing: 10) {
                        BIcon(kind: .sparkle, size: 15, color: BakeTheme.wheatDeep)
                        Text(recipe.tip)
                            .font(BakeTheme.serif(14))
                            .foregroundColor(BakeTheme.inkSoft)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .bakeCard(padding: 13)
                    if store.isUnlocked(recipe) && store.starterReady(recipe) {
                        Button {
                            showFlow = true
                        } label: {
                            Text("Tie the apron — start baking")
                        }
                        .buttonStyle(BakePrimaryButton())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 90)
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showFlow) {
            BakeFlowView(recipe: recipe)
                .environmentObject(store)
        }
    }

    private func crustWord(_ c: Double) -> String {
        if c < 0.5 { return "blushed" }
        if c < 0.62 { return "golden" }
        if c < 0.74 { return "deep gold" }
        return "bold"
    }

    private func specChip(label: String, value: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(BakeTheme.heading(13))
                .foregroundColor(BakeTheme.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(BakeTheme.body(10))
                .foregroundColor(BakeTheme.inkFaint)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 9)
        .background(RoundedRectangle(cornerRadius: 11).fill(BakeTheme.cream))
    }
}
