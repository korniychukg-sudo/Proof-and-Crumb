import SwiftUI

struct RootView: View {
    @EnvironmentObject var store: BakeStore
    @State private var selectedTab = 0

    var body: some View {
        if !store.onboardingDone {
            OnboardingView()
                .environmentObject(store)
        } else {
            VStack(spacing: 0) {
                Group {
                    switch selectedTab {
                    case 0:
                        NavigationView { BakeryView().environmentObject(store) }
                            .navigationViewStyle(StackNavigationViewStyle())
                    case 1:
                        NavigationView { BookView().environmentObject(store) }
                            .navigationViewStyle(StackNavigationViewStyle())
                    case 2:
                        NavigationView { StarterView().environmentObject(store) }
                            .navigationViewStyle(StackNavigationViewStyle())
                    case 3:
                        NavigationView { LearnView().environmentObject(store) }
                            .navigationViewStyle(StackNavigationViewStyle())
                    default:
                        NavigationView { JournalView().environmentObject(store) }
                            .navigationViewStyle(StackNavigationViewStyle())
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                tabBar
            }
            .ignoresSafeArea(.keyboard)
        }
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            tabButton(0, icon: .bakery, label: "Bakery")
            tabButton(1, icon: .book, label: "Bake Book")
            tabButton(2, icon: .starter, label: "Starter")
            tabButton(3, icon: .learn, label: "Learn")
            tabButton(4, icon: .journal, label: "Journal")
        }
        .padding(.top, 9)
        .padding(.bottom, 3)
        .background(
            BakeTheme.paper
                .overlay(Rectangle().fill(BakeTheme.ink.opacity(0.08)).frame(height: 1), alignment: .top)
                .edgesIgnoringSafeArea(.bottom)
        )
    }

    private func tabButton(_ index: Int, icon: BIconKind, label: String) -> some View {
        Button {
            if selectedTab != index {
                selectedTab = index
                BakeHaptics.tap()
            }
        } label: {
            VStack(spacing: 3) {
                BIcon(kind: icon, size: 23, color: selectedTab == index ? BakeTheme.terraDeep : BakeTheme.inkFaint.opacity(0.75))
                Text(label)
                    .font(BakeTheme.body(10))
                    .foregroundColor(selectedTab == index ? BakeTheme.terraDeep : BakeTheme.inkFaint.opacity(0.75))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
