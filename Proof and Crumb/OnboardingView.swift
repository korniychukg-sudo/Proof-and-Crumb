import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var store: BakeStore
    @State private var page = 0

    private let pages: [(art: String, title: String, text: String)] = [
        ("onboard_1", "A bakery in your pocket", "Twenty-four real bakes, from a humble tin loaf to croissants and star bread. Every one is made by hand: mix, knead, proof, shape, score, and bake — and every choice you make shows in the loaf."),
        ("onboard_2", "The dough keeps its own clock", "Poke it to ask if it is ready. Watch the crust turn from pale to deep gold and pull it at the right shade. Steam, slashes, warmth and patience all matter, exactly the way they do in a real kitchen."),
        ("onboard_3", "A shop that fills with your work", "Finished bakes stand in the shop window. A sourdough starter waits on the sill for its daily feed, the counter book fills with requests, and the guild exam is always ready. Everything stays on this device."),
    ]

    var body: some View {
        ZStack {
            FlourBackdrop(tone: BakeTheme.cream)
            VStack(spacing: 0) {
                TabView(selection: $page) {
                    ForEach(pages.indices, id: \.self) { idx in
                        VStack(spacing: 22) {
                            BakeArtImage(name: pages[idx].art)
                                .frame(maxWidth: 480)
                                .frame(height: 320)
                                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .stroke(BakeTheme.crust.opacity(0.3), lineWidth: 1.5)
                                )
                                .padding(.horizontal, 26)
                            VStack(spacing: 10) {
                                Text(pages[idx].title)
                                    .font(BakeTheme.title(26))
                                    .foregroundColor(BakeTheme.ink)
                                    .multilineTextAlignment(.center)
                                Text(pages[idx].text)
                                    .font(BakeTheme.serif(16))
                                    .foregroundColor(BakeTheme.inkSoft)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(5)
                                    .padding(.horizontal, 34)
                            }
                            Spacer(minLength: 0)
                        }
                        .padding(.top, 30)
                        .tag(idx)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                HStack(spacing: 7) {
                    ForEach(pages.indices, id: \.self) { idx in
                        Capsule()
                            .fill(idx == page ? BakeTheme.terracotta : BakeTheme.ink.opacity(0.15))
                            .frame(width: idx == page ? 22 : 7, height: 7)
                            .animation(.easeOut(duration: 0.2), value: page)
                    }
                }
                .padding(.bottom, 18)
                Button {
                    if page < pages.count - 1 {
                        withAnimation { page += 1 }
                    } else {
                        store.onboardingDone = true
                        store.scheduleSave()
                        BakeHaptics.success()
                    }
                } label: {
                    Text(page < pages.count - 1 ? "Next" : "Tie the apron")
                }
                .buttonStyle(BakePrimaryButton())
                .padding(.horizontal, 34)
                if page < pages.count - 1 {
                    Button {
                        store.onboardingDone = true
                        store.scheduleSave()
                    } label: {
                        Text("Skip")
                            .font(BakeTheme.body(14))
                            .foregroundColor(BakeTheme.inkFaint)
                    }
                    .padding(.top, 10)
                } else {
                    Color.clear.frame(height: 30)
                }
                Spacer(minLength: 20)
            }
        }
    }
}
