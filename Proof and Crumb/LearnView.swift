import SwiftUI

struct LearnView: View {
    @EnvironmentObject var store: BakeStore

    var body: some View {
        ZStack {
            FlourBackdrop()
            ScrollView {
                VStack(spacing: 16) {
                    BakeSectionHeader(title: "The Baker's Handbook", subtitle: "The real craft behind every stage")
                    quizCard
                    ForEach(BakeGuides.all) { guide in
                        NavigationLink(destination: BakeGuideDetailView(guide: guide).environmentObject(store)) {
                            guideRow(guide)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    NavigationLink(destination: BakeGlossaryView().environmentObject(store)) {
                        glossaryCard
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 90)
            }
        }
        .navigationBarHidden(true)
    }

    private var quizCard: some View {
        NavigationLink(destination: BakeQuizView().environmentObject(store)) {
            HStack(spacing: 14) {
                ZStack {
                    Circle().fill(BakeTheme.terraDeep).frame(width: 52, height: 52)
                    BIcon(kind: .ribbon, size: 26, color: BakeTheme.butter)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("The Guild Exam")
                        .font(BakeTheme.heading(16))
                        .foregroundColor(BakeTheme.ink)
                    Text(store.stats.quizBest > 0 ? "Best score \(store.stats.quizBest) of 10 · \(store.stats.quizRounds) sittings" : "Ten fresh questions every sitting")
                        .font(BakeTheme.body(12))
                        .foregroundColor(BakeTheme.inkFaint)
                }
                Spacer()
                BIcon(kind: .chevronRight, size: 14, color: BakeTheme.inkFaint)
            }
            .bakeCard()
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func guideRow(_ guide: BakeGuide) -> some View {
        let read = store.stats.guidesRead.contains(guide.id)
        return HStack(spacing: 12) {
            BakeArtImage(name: guide.plateArt)
                .frame(width: 78, height: 62)
                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
            VStack(alignment: .leading, spacing: 3) {
                Text(guide.title)
                    .font(BakeTheme.heading(15))
                    .foregroundColor(BakeTheme.ink)
                Text(guide.subtitle)
                    .font(BakeTheme.body(12))
                    .foregroundColor(BakeTheme.inkFaint)
                    .lineLimit(2)
                if read {
                    HStack(spacing: 4) {
                        BIcon(kind: .check, size: 10, color: BakeTheme.sageDeep)
                        Text("Read")
                            .font(BakeTheme.body(10))
                            .foregroundColor(BakeTheme.sageDeep)
                    }
                }
            }
            Spacer()
            BIcon(kind: .chevronRight, size: 13, color: BakeTheme.inkFaint)
        }
        .bakeCard(padding: 12)
    }

    private var glossaryCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(BakeTheme.wheat.opacity(0.2)).frame(width: 52, height: 52)
                BIcon(kind: .book, size: 24, color: BakeTheme.wheatDeep)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text("Baker's Glossary")
                    .font(BakeTheme.heading(16))
                    .foregroundColor(BakeTheme.ink)
                Text("\(BakeGlossary.terms.count) terms from autolyse to yeast")
                    .font(BakeTheme.body(12))
                    .foregroundColor(BakeTheme.inkFaint)
            }
            Spacer()
            BIcon(kind: .chevronRight, size: 14, color: BakeTheme.inkFaint)
        }
        .bakeCard()
    }
}

struct BakeGuideDetailView: View {
    @EnvironmentObject var store: BakeStore
    @Environment(\.presentationMode) var presentationMode
    let guide: BakeGuide

    var body: some View {
        ZStack {
            FlourBackdrop()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ZStack(alignment: .topLeading) {
                        BakeArtImage(name: guide.plateArt)
                            .frame(maxWidth: .infinity)
                            .frame(height: 230)
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
                        Text(guide.title)
                            .font(BakeTheme.title(25))
                            .foregroundColor(BakeTheme.ink)
                        Text(guide.subtitle)
                            .font(BakeTheme.body(14))
                            .foregroundColor(BakeTheme.inkFaint)
                    }
                    ForEach(guide.paragraphs.indices, id: \.self) { idx in
                        Text(guide.paragraphs[idx])
                            .font(BakeTheme.serif(16))
                            .foregroundColor(BakeTheme.ink)
                            .lineSpacing(5)
                    }
                    BakeDivider()
                    Text("Worth remembering")
                        .font(BakeTheme.heading(16))
                        .foregroundColor(BakeTheme.ink)
                    VStack(spacing: 8) {
                        ForEach(guide.facts.indices, id: \.self) { idx in
                            HStack(alignment: .top, spacing: 10) {
                                Circle().fill(BakeTheme.wheat).frame(width: 6, height: 6).padding(.top, 6)
                                Text(guide.facts[idx])
                                    .font(BakeTheme.body(14))
                                    .foregroundColor(BakeTheme.inkSoft)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .bakeCard(padding: 12)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 90)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            store.recordGuideRead(guide.id)
        }
    }
}

struct BakeGlossaryView: View {
    @EnvironmentObject var store: BakeStore
    @Environment(\.presentationMode) var presentationMode
    @State private var search = ""

    var filtered: [BakeTerm] {
        let trimmed = search.trimmingCharacters(in: .whitespaces).lowercased()
        if trimmed.isEmpty { return BakeGlossary.terms }
        return BakeGlossary.terms.filter { $0.term.lowercased().contains(trimmed) || $0.definition.lowercased().contains(trimmed) }
    }

    var body: some View {
        ZStack {
            FlourBackdrop()
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        BIcon(kind: .chevronRight, size: 15, color: BakeTheme.inkSoft)
                            .rotationEffect(.degrees(180))
                            .padding(9)
                            .background(Circle().fill(BakeTheme.ink.opacity(0.07)))
                    }
                    Text("Baker's Glossary")
                        .font(BakeTheme.title(20))
                        .foregroundColor(BakeTheme.ink)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                TextField("Search terms", text: $search)
                    .font(BakeTheme.body(15))
                    .padding(11)
                    .background(RoundedRectangle(cornerRadius: 12).fill(BakeTheme.paper))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(BakeTheme.ink.opacity(0.1), lineWidth: 1))
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                ScrollView {
                    VStack(spacing: 9) {
                        ForEach(filtered) { term in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(term.term)
                                    .font(BakeTheme.heading(15))
                                    .foregroundColor(BakeTheme.ink)
                                Text(term.definition)
                                    .font(BakeTheme.body(13))
                                    .foregroundColor(BakeTheme.inkSoft)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .bakeCard(padding: 13)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 90)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct BakeQuizView: View {
    @EnvironmentObject var store: BakeStore
    @Environment(\.presentationMode) var presentationMode
    @State private var questions: [BakeQuizQuestion] = []
    @State private var index = 0
    @State private var score = 0
    @State private var picked: Int?
    @State private var finished = false

    var body: some View {
        ZStack {
            FlourBackdrop()
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        BIcon(kind: .close, size: 14, color: BakeTheme.inkSoft)
                            .padding(9)
                            .background(Circle().fill(BakeTheme.ink.opacity(0.07)))
                    }
                    Text("The Guild Exam")
                        .font(BakeTheme.title(19))
                        .foregroundColor(BakeTheme.ink)
                    Spacer()
                    if !finished && !questions.isEmpty {
                        Text("\(index + 1)/\(questions.count)")
                            .font(BakeTheme.mono(13))
                            .foregroundColor(BakeTheme.inkSoft)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                if finished {
                    resultView
                } else if questions.isEmpty {
                    Spacer()
                    Button {
                        startRound()
                    } label: {
                        Text("Sit the exam")
                    }
                    .buttonStyle(BakePrimaryButton())
                    .padding(.horizontal, 40)
                    Text("Ten questions drawn fresh from the handbook, the glossary and the bake book.")
                        .font(BakeTheme.body(13))
                        .foregroundColor(BakeTheme.inkFaint)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.top, 12)
                    Spacer()
                } else {
                    questionView
                }
            }
        }
        .navigationBarHidden(true)
    }

    private func startRound() {
        questions = BakeQuiz.makeRound()
        index = 0
        score = 0
        picked = nil
        finished = false
    }

    private var questionView: some View {
        let q = questions[index]
        return ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                BakeProgressBar(progress: Double(index) / Double(questions.count), color: BakeTheme.terracotta, height: 6)
                Text(q.prompt)
                    .font(BakeTheme.heading(17))
                    .foregroundColor(BakeTheme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 4)
                ForEach(q.options.indices, id: \.self) { idx in
                    Button {
                        guard picked == nil else { return }
                        picked = idx
                        if idx == q.correctIndex {
                            score += 1
                            BakeHaptics.success()
                        } else {
                            BakeHaptics.warning()
                        }
                    } label: {
                        HStack {
                            Text(q.options[idx])
                                .font(BakeTheme.body(14))
                                .foregroundColor(optionColor(idx, q: q))
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer()
                            if let picked = picked {
                                if idx == q.correctIndex {
                                    BIcon(kind: .check, size: 14, color: BakeTheme.sageDeep)
                                } else if idx == picked {
                                    BIcon(kind: .close, size: 12, color: BakeTheme.berry)
                                }
                            }
                        }
                        .padding(13)
                        .background(
                            RoundedRectangle(cornerRadius: 13, style: .continuous)
                                .fill(optionBackground(idx, q: q))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 13, style: .continuous)
                                .stroke(optionBorder(idx, q: q), lineWidth: 1.4)
                        )
                    }
                    .disabled(picked != nil)
                }
                if picked != nil {
                    Text(q.explanation)
                        .font(BakeTheme.serif(14))
                        .foregroundColor(BakeTheme.inkSoft)
                        .lineSpacing(4)
                        .padding(13)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 13).fill(BakeTheme.wheat.opacity(0.10)))
                    Button {
                        if index + 1 < questions.count {
                            index += 1
                            picked = nil
                        } else {
                            store.recordQuiz(score: score)
                            finished = true
                        }
                    } label: {
                        Text(index + 1 < questions.count ? "Next question" : "See the result")
                    }
                    .buttonStyle(BakePrimaryButton())
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 60)
        }
    }

    private func optionColor(_ idx: Int, q: BakeQuizQuestion) -> Color {
        guard picked != nil else { return BakeTheme.ink }
        if idx == q.correctIndex { return BakeTheme.sageDeep }
        return BakeTheme.inkFaint
    }

    private func optionBackground(_ idx: Int, q: BakeQuizQuestion) -> Color {
        guard let picked = picked else { return BakeTheme.paper }
        if idx == q.correctIndex { return BakeTheme.sage.opacity(0.10) }
        if idx == picked { return BakeTheme.berry.opacity(0.08) }
        return BakeTheme.paper
    }

    private func optionBorder(_ idx: Int, q: BakeQuizQuestion) -> Color {
        guard let picked = picked else { return BakeTheme.ink.opacity(0.08) }
        if idx == q.correctIndex { return BakeTheme.sage.opacity(0.5) }
        if idx == picked { return BakeTheme.berry.opacity(0.4) }
        return BakeTheme.ink.opacity(0.05)
    }

    private var resultView: some View {
        VStack(spacing: 16) {
            Spacer()
            ZStack {
                BakeProgressRing(progress: Double(score) / 10.0, size: 110, lineWidth: 11, color: score >= 7 ? BakeTheme.sage : BakeTheme.wheat)
                VStack(spacing: 2) {
                    Text("\(score)")
                        .font(BakeTheme.title(36))
                        .foregroundColor(BakeTheme.ink)
                    Text("of 10")
                        .font(BakeTheme.body(12))
                        .foregroundColor(BakeTheme.inkFaint)
                }
            }
            Text(verdict)
                .font(BakeTheme.serif(16))
                .foregroundColor(BakeTheme.inkSoft)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            if score >= store.stats.quizBest && score > 0 {
                Text("A new personal best")
                    .font(BakeTheme.heading(13))
                    .foregroundColor(BakeTheme.wheatDeep)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(BakeTheme.wheat.opacity(0.15)))
            }
            Button {
                startRound()
            } label: {
                Text("Sit it again")
            }
            .buttonStyle(BakePrimaryButton())
            .padding(.horizontal, 60)
            Spacer()
        }
    }

    private var verdict: String {
        switch score {
        case 10: return "A perfect paper. The guild quietly wonders if you wrote the handbook."
        case 8...9: return "A fine pass. Your loaves may henceforth be discussed with respect."
        case 6...7: return "A solid showing, with a chapter or two worth rereading while the oven heats."
        case 4...5: return "The examiner smiles kindly and dusts the flour from your paper."
        default: return "Every master baker failed an exam once. Few of them admit it, but they did."
        }
    }
}
