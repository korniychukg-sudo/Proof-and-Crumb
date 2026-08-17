import SwiftUI
import Combine

struct BakeFlowView: View {
    let recipe: BakeRecipe
    @EnvironmentObject var store: BakeStore
    @Environment(\.presentationMode) var presentationMode

    @State private var stageIndex = 0
    @State private var marks = StageMarks()

    @State private var addedIngredients: [String] = []
    @State private var shuffledIngredients: [String] = []
    @State private var orderErrors = 0
    @State private var hydrationSet: Double = 0.62
    @State private var mixCombined = false

    @State private var glutenWork: Double = 0
    @State private var lastDrag: CGPoint?

    @State private var foldsDone = 0
    @State private var rushedFolds = 0
    @State private var butterCold: Double = 1.0

    @State private var ferment: Double = 0
    @State private var warmth: Double = 0.5
    @State private var pokeText: String?

    @State private var drawnPoints: [CGPoint] = []
    @State private var shapeAccuracy: Double = 0

    @State private var slashes: [DoughArtist.Slash] = []
    @State private var slashStart: CGPoint?
    @State private var slashLive: DoughArtist.Slash?

    @State private var crust: Double = 0
    @State private var ovenHeat: Double = 0.55
    @State private var bakeElapsed: Double = 0
    @State private var steamUsed = false
    @State private var pulled = false

    @State private var record: BakeRecord?
    @State private var phase: Double = 0

    private let ticker = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    private var stage: BakeStage {
        recipe.stages[min(stageIndex, recipe.stages.count - 1)]
    }

    var body: some View {
        ZStack {
            FlourBackdrop(tone: BakeTheme.cream)
            VStack(spacing: 0) {
                header
                ScrollView {
                    VStack(spacing: 16) {
                        switch stage {
                        case .mix: mixStage
                        case .knead: kneadStage
                        case .laminate: laminateStage
                        case .proofRise: proofStage
                        case .shape: shapeStage
                        case .slash: slashStage
                        case .bake: bakeStage
                        case .reveal: revealStage
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 40)
                }
            }
            if let record = record, record.stars == 3 {
                BakeConfetti(seed: UInt64(abs(recipe.id.hashValue % 900)))
            }
        }
        .onAppear {
            hydrationSet = 0.62
            var rng = BakeSeededRandom(seed: UInt64(Date().timeIntervalSince1970))
            var pool = recipe.ingredients
            shuffledIngredients = []
            while !pool.isEmpty {
                shuffledIngredients.append(pool.remove(at: rng.nextInt(pool.count)))
            }
        }
        .onReceive(ticker) { _ in
            tick(0.1)
        }
    }

    private func tick(_ dt: Double) {
        phase += dt
        switch stage {
        case .laminate:
            butterCold = (butterCold + dt * 0.09).bakeClamped(0, 1)
        case .proofRise:
            ferment += dt * (0.014 + warmth * 0.048)
        case .bake:
            guard !pulled else { break }
            bakeElapsed += dt
            crust = (crust + dt * (0.016 + ovenHeat * 0.052)).bakeClamped(0, 1)
        default:
            break
        }
    }

    private func advance() {
        if stageIndex + 1 < recipe.stages.count {
            stageIndex += 1
            BakeHaptics.thump()
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            HStack {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    BIcon(kind: .close, size: 14, color: BakeTheme.inkSoft)
                        .padding(9)
                        .background(Circle().fill(BakeTheme.ink.opacity(0.07)))
                }
                Spacer()
                VStack(spacing: 1) {
                    Text(recipe.name)
                        .font(BakeTheme.heading(15))
                        .foregroundColor(BakeTheme.ink)
                    Text(stage.title)
                        .font(BakeTheme.body(12))
                        .foregroundColor(BakeTheme.terraDeep)
                }
                Spacer()
                Color.clear.frame(width: 32, height: 32)
            }
            HStack(spacing: 5) {
                ForEach(recipe.stages.indices, id: \.self) { idx in
                    Capsule()
                        .fill(idx <= stageIndex ? BakeTheme.terracotta : BakeTheme.ink.opacity(0.12))
                        .frame(height: 4)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
    }

    private var mixStage: some View {
        VStack(spacing: 14) {
            Text("Add the ingredients in the order the recipe calls them, top of the list first.")
                .font(BakeTheme.serif(15))
                .foregroundColor(BakeTheme.inkSoft)
                .frame(maxWidth: .infinity, alignment: .leading)
            ZStack {
                RoundedRectangle(cornerRadius: 18).fill(BakeTheme.paper)
                    .shadow(color: BakeTheme.cardShadow, radius: 6, x: 0, y: 3)
                Canvas { ctx, size in
                    let rect = CGRect(origin: .zero, size: size).insetBy(dx: size.width * 0.2, dy: size.height * 0.12)
                    let fill = Double(addedIngredients.count) / Double(max(1, recipe.ingredients.count))
                    DoughArtist.drawDoughBall(&ctx, rect: CGRect(x: rect.minX, y: rect.minY + rect.height * (1 - fill) * 0.3, width: rect.width, height: rect.height * (0.4 + fill * 0.6)), tint: recipe.doughTint, smoothness: 0.2 + fill * 0.2, phase: phase)
                }
            }
            .frame(height: 170)
            VStack(alignment: .leading, spacing: 8) {
                Text("The recipe calls for:")
                    .font(BakeTheme.heading(13))
                    .foregroundColor(BakeTheme.inkFaint)
                ForEach(recipe.ingredients.indices, id: \.self) { idx in
                    HStack(spacing: 8) {
                        if idx < addedIngredients.count {
                            BIcon(kind: .check, size: 12, color: BakeTheme.sageDeep)
                        } else {
                            Circle().stroke(BakeTheme.inkFaint, lineWidth: 1.2).frame(width: 11, height: 11)
                        }
                        Text(recipe.ingredients[idx])
                            .font(BakeTheme.body(14))
                            .foregroundColor(idx < addedIngredients.count ? BakeTheme.inkFaint : BakeTheme.ink)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .bakeCard(padding: 14)
            if addedIngredients.count < recipe.ingredients.count {
                VStack(alignment: .leading, spacing: 8) {
                    Text("The counter (tap to add):")
                        .font(BakeTheme.heading(13))
                        .foregroundColor(BakeTheme.inkFaint)
                    FlowChips(items: shuffledIngredients.filter { item in
                        countOf(item, in: shuffledIngredients) > countOf(item, in: addedIngredients)
                    }) { item in
                        addIngredient(item)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Set the water")
                            .font(BakeTheme.heading(15))
                            .foregroundColor(BakeTheme.ink)
                        Spacer()
                        Text("\(Int(hydrationSet * 100))% hydration")
                            .font(BakeTheme.mono(13))
                            .foregroundColor(BakeTheme.terraDeep)
                    }
                    Slider(value: $hydrationSet, in: 0.4...0.9)
                        .accentColor(BakeTheme.terracotta)
                    Text("This dough wants about \(Int(recipe.hydration * 100))% — the recipe page always knows.")
                        .font(BakeTheme.body(12))
                        .foregroundColor(BakeTheme.inkFaint)
                }
                .bakeCard(padding: 14)
                Button {
                    marks.mix = BakeMath.mixMark(orderErrors: orderErrors, total: recipe.ingredients.count, hydrationSet: hydrationSet, target: recipe.hydration)
                    advance()
                } label: {
                    Text("Bring the dough together")
                }
                .buttonStyle(BakePrimaryButton())
            }
        }
    }

    private func countOf(_ item: String, in list: [String]) -> Int {
        list.filter { $0 == item }.count
    }

    private func addIngredient(_ item: String) {
        let nextExpected = recipe.ingredients[min(addedIngredients.count, recipe.ingredients.count - 1)]
        if item == nextExpected {
            addedIngredients.append(item)
            BakeHaptics.tap()
        } else {
            orderErrors += 1
            addedIngredients.append(nextExpected)
            BakeHaptics.warning()
        }
    }

    private var kneadStage: some View {
        VStack(spacing: 14) {
            Text("Work the dough in circles with your finger. Stop when it turns smooth and glossy — the meter knows when to say when.")
                .font(BakeTheme.serif(15))
                .foregroundColor(BakeTheme.inkSoft)
                .frame(maxWidth: .infinity, alignment: .leading)
            ZStack {
                RoundedRectangle(cornerRadius: 18).fill(BakeTheme.paper)
                    .shadow(color: BakeTheme.cardShadow, radius: 6, x: 0, y: 3)
                Canvas { ctx, size in
                    let rect = CGRect(origin: .zero, size: size).insetBy(dx: size.width * 0.24, dy: size.height * 0.14)
                    DoughArtist.drawDoughBall(&ctx, rect: rect, tint: recipe.doughTint, smoothness: (glutenWork).bakeClamped(0, 1), phase: phase, seed: 13)
                    if glutenWork > 1.15 {
                        let warn = "the dough is tiring"
                        ctx.draw(Text(warn).font(BakeTheme.body(12)).foregroundColor(BakeTheme.berry), at: CGPoint(x: size.width / 2, y: size.height * 0.9))
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            if let last = lastDrag {
                                let d = hypot(value.location.x - last.x, value.location.y - last.y)
                                glutenWork += Double(d) / 2600
                            }
                            lastDrag = value.location
                        }
                        .onEnded { _ in lastDrag = nil }
                )
            }
            .frame(height: 240)
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Gluten")
                        .font(BakeTheme.heading(13))
                        .foregroundColor(BakeTheme.inkFaint)
                    Spacer()
                    Text(kneadLabel)
                        .font(BakeTheme.body(12))
                        .foregroundColor(glutenWork > 1.15 ? BakeTheme.berry : BakeTheme.terraDeep)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(BakeTheme.wheat.opacity(0.16))
                        Capsule().fill(BakeTheme.sage.opacity(0.35))
                            .frame(width: geo.size.width * 0.24)
                            .offset(x: geo.size.width * 0.72)
                        Capsule().fill(glutenWork > 1.15 ? BakeTheme.berry : BakeTheme.wheat)
                            .frame(width: max(8, geo.size.width * CGFloat((glutenWork / 1.4).bakeClamped(0, 1))))
                    }
                }
                .frame(height: 10)
                Text("The green band is the windowpane zone: stretchy, smooth, ready.")
                    .font(BakeTheme.body(12))
                    .foregroundColor(BakeTheme.inkFaint)
            }
            .bakeCard(padding: 14)
            Button {
                marks.knead = BakeMath.kneadMark(glutenWork)
                advance()
            } label: {
                Text("The dough is ready")
            }
            .buttonStyle(BakePrimaryButton())
            .disabled(glutenWork < 0.2)
            .opacity(glutenWork < 0.2 ? 0.5 : 1)
        }
    }

    private var kneadLabel: String {
        if glutenWork < 0.3 { return "shaggy" }
        if glutenWork < 0.6 { return "coming together" }
        if glutenWork < 0.85 { return "smooth" }
        if glutenWork <= 1.15 { return "windowpane — perfect" }
        return "overworked"
    }

    private var laminateStage: some View {
        VStack(spacing: 14) {
            Text("Swipe down across the dough to roll and fold. Fold only when the butter is cold — the thermometer refills as the parcel rests.")
                .font(BakeTheme.serif(15))
                .foregroundColor(BakeTheme.inkSoft)
                .frame(maxWidth: .infinity, alignment: .leading)
            ZStack {
                RoundedRectangle(cornerRadius: 18).fill(BakeTheme.paper)
                    .shadow(color: BakeTheme.cardShadow, radius: 6, x: 0, y: 3)
                Canvas { ctx, size in
                    let layers = Int(pow(3.0, Double(foldsDone + 1)))
                    let rect = CGRect(x: size.width * 0.2, y: size.height * 0.3, width: size.width * 0.6, height: size.height * 0.4)
                    ctx.fill(Path(roundedRect: rect, cornerRadius: 10), with: .color(BakeTheme.doughPale))
                    ctx.stroke(Path(roundedRect: rect, cornerRadius: 10), with: .color(BakeTheme.ink.opacity(0.4)), lineWidth: 1.4)
                    let lines = min(14, foldsDone * 4 + 2)
                    for i in 1...lines {
                        let y = rect.minY + rect.height * CGFloat(i) / CGFloat(lines + 1)
                        var p = Path()
                        p.move(to: CGPoint(x: rect.minX + 6, y: y))
                        p.addLine(to: CGPoint(x: rect.maxX - 6, y: y))
                        ctx.stroke(p, with: .color(BakeTheme.butter.opacity(0.9)), lineWidth: 2)
                    }
                    ctx.draw(Text("\(layers) layers").font(BakeTheme.heading(14)).foregroundColor(BakeTheme.terraDeep), at: CGPoint(x: size.width / 2, y: size.height * 0.16))
                }
                .gesture(
                    DragGesture(minimumDistance: 30)
                        .onEnded { value in
                            guard foldsDone < recipe.laminateFolds else { return }
                            if value.translation.height > 40 {
                                if butterCold >= 0.5 {
                                    foldsDone += 1
                                    BakeHaptics.thump()
                                } else {
                                    foldsDone += 1
                                    rushedFolds += 1
                                    BakeHaptics.warning()
                                }
                                butterCold = 0.08
                            }
                        }
                )
            }
            .frame(height: 220)
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Butter")
                        .font(BakeTheme.heading(13))
                        .foregroundColor(BakeTheme.inkFaint)
                    BakeProgressBar(progress: butterCold, color: butterCold >= 0.5 ? BakeTheme.sage : BakeTheme.berry)
                    Text(butterCold >= 0.5 ? "Cold and obedient — safe to fold." : "Warming and soft — let the parcel rest.")
                        .font(BakeTheme.body(12))
                        .foregroundColor(BakeTheme.inkFaint)
                }
                VStack(spacing: 3) {
                    Text("\(foldsDone)/\(recipe.laminateFolds)")
                        .font(BakeTheme.title(20))
                        .foregroundColor(BakeTheme.ink)
                    Text("folds")
                        .font(BakeTheme.body(11))
                        .foregroundColor(BakeTheme.inkFaint)
                }
                .frame(width: 64)
            }
            .bakeCard(padding: 14)
            if foldsDone >= recipe.laminateFolds {
                Button {
                    marks.laminate = BakeMath.laminateMark(goodFolds: foldsDone - rushedFolds, rushedFolds: rushedFolds, targetFolds: recipe.laminateFolds)
                    advance()
                } label: {
                    Text("The parcel is folded")
                }
                .buttonStyle(BakePrimaryButton())
            }
        }
    }

    private var proofStage: some View {
        VStack(spacing: 14) {
            Text("The dough keeps its own clock. Warm the corner to hurry it, poke it to ask how it feels, and shape it at its peak.")
                .font(BakeTheme.serif(15))
                .foregroundColor(BakeTheme.inkSoft)
                .frame(maxWidth: .infinity, alignment: .leading)
            ZStack {
                RoundedRectangle(cornerRadius: 18).fill(BakeTheme.paper)
                    .shadow(color: BakeTheme.cardShadow, radius: 6, x: 0, y: 3)
                Canvas { ctx, size in
                    let rect = CGRect(origin: .zero, size: size).insetBy(dx: size.width * 0.16, dy: size.height * 0.1)
                    DoughArtist.drawProofBowl(&ctx, rect: rect, ferment: ferment, tint: recipe.doughTint, phase: phase)
                }
            }
            .frame(height: 220)
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    BIcon(kind: .flame, size: 16, color: BakeTheme.terracotta)
                    Slider(value: $warmth, in: 0...1)
                        .accentColor(BakeTheme.terracotta)
                    Text(warmth < 0.33 ? "Larder" : (warmth < 0.7 ? "Kitchen" : "By the oven"))
                        .font(BakeTheme.body(12))
                        .foregroundColor(BakeTheme.inkSoft)
                        .frame(width: 74, alignment: .trailing)
                }
                if let pokeText = pokeText {
                    Text(pokeText)
                        .font(BakeTheme.serif(14))
                        .foregroundColor(BakeTheme.terraDeep)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .bakeCard(padding: 14)
            HStack(spacing: 10) {
                Button {
                    pokeText = BakeMath.pokeVerdict(ferment)
                    BakeHaptics.tap()
                } label: {
                    Text("Poke test")
                }
                .buttonStyle(BakeSoftButton())
                Button {
                    marks.proofRise = BakeMath.proofMark(ferment)
                    advance()
                } label: {
                    Text("Shape it now")
                }
                .buttonStyle(BakePrimaryButton())
            }
        }
    }

    private var shapeGuide: [CGPoint] {
        switch recipe.shapeKind {
        case .round, .dimple:
            return (0...36).map { i in
                let a = CGFloat(i) / 36 * 2 * .pi - .pi / 2
                return CGPoint(x: 0.5 + cos(a) * 0.32, y: 0.5 + sin(a) * 0.3)
            }
        case .log, .crescent:
            return (0...24).map { i in
                let t = CGFloat(i) / 24
                let a = .pi * 0.86 - t * .pi * 0.72
                return CGPoint(x: 0.5 + cos(a) * 0.36, y: 0.62 - sin(a) * 0.3)
            }
        case .sticks:
            var pts: [CGPoint] = []
            for row in 0..<3 {
                let y = 0.3 + CGFloat(row) * 0.2
                for i in 0...10 {
                    let t = CGFloat(i) / 10
                    pts.append(CGPoint(x: row % 2 == 0 ? 0.15 + t * 0.7 : 0.85 - t * 0.7, y: y))
                }
            }
            return pts
        case .braid, .twist:
            return (0...40).map { i in
                let t = CGFloat(i) / 40
                return CGPoint(x: 0.15 + t * 0.7, y: 0.5 + sin(t * .pi * 3) * 0.2)
            }
        case .star:
            var pts: [CGPoint] = []
            for arm in 0..<8 {
                let a = CGFloat(arm) / 8 * 2 * .pi - .pi / 2
                for i in 0...4 {
                    let t = CGFloat(i) / 4
                    pts.append(CGPoint(x: 0.5 + cos(a) * 0.34 * t, y: 0.5 + sin(a) * 0.32 * t))
                }
            }
            return pts
        }
    }

    private var shapeStage: some View {
        VStack(spacing: 14) {
            Text(shapeInstruction)
                .font(BakeTheme.serif(15))
                .foregroundColor(BakeTheme.inkSoft)
                .frame(maxWidth: .infinity, alignment: .leading)
            GeometryReader { geo in
                ZStack {
                    RoundedRectangle(cornerRadius: 18).fill(BakeTheme.paper)
                        .shadow(color: BakeTheme.cardShadow, radius: 6, x: 0, y: 3)
                    Canvas { ctx, size in
                        var guide = Path()
                        let pts = shapeGuide.map { CGPoint(x: $0.x * size.width, y: $0.y * size.height) }
                        if recipe.shapeKind == .sticks {
                            for (i, pt) in pts.enumerated() {
                                if i % 11 == 0 { guide.move(to: pt) } else { guide.addLine(to: pt) }
                            }
                        } else if recipe.shapeKind == .star {
                            for (i, pt) in pts.enumerated() {
                                if i % 5 == 0 { guide.move(to: pt) } else { guide.addLine(to: pt) }
                            }
                        } else {
                            for (i, pt) in pts.enumerated() {
                                if i == 0 { guide.move(to: pt) } else { guide.addLine(to: pt) }
                            }
                        }
                        ctx.stroke(guide, with: .color(BakeTheme.wheat.opacity(0.5)), style: StrokeStyle(lineWidth: 14, lineCap: .round, lineJoin: .round, dash: [0.5, 22]))
                        var drawn = Path()
                        for (i, pt) in drawnPoints.enumerated() {
                            if i == 0 { drawn.move(to: pt) } else { drawn.addLine(to: pt) }
                        }
                        ctx.stroke(drawn, with: .color(BakeTheme.terracotta.opacity(0.85)), style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round))
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                drawnPoints.append(value.location)
                                shapeAccuracy = computeShapeAccuracy(canvas: geo.size)
                            }
                    )
                }
            }
            .frame(height: 280)
            HStack {
                Text("Shape")
                    .font(BakeTheme.heading(13))
                    .foregroundColor(BakeTheme.inkFaint)
                BakeProgressBar(progress: shapeAccuracy, color: BakeTheme.sage)
                Text("\(Int(shapeAccuracy * 100))%")
                    .font(BakeTheme.mono(12))
                    .foregroundColor(BakeTheme.inkSoft)
                    .frame(width: 44, alignment: .trailing)
            }
            .bakeCard(padding: 13)
            HStack(spacing: 10) {
                Button {
                    drawnPoints = []
                    shapeAccuracy = 0
                    BakeHaptics.tap()
                } label: {
                    Text("Start over")
                }
                .buttonStyle(BakeSoftButton())
                Button {
                    marks.shape = shapeAccuracy
                    advance()
                } label: {
                    Text("It holds its shape")
                }
                .buttonStyle(BakePrimaryButton())
                .disabled(shapeAccuracy < 0.15)
                .opacity(shapeAccuracy < 0.15 ? 0.5 : 1)
            }
        }
    }

    private var shapeInstruction: String {
        switch recipe.shapeKind {
        case .round: return "Trace the round: one steady circle to build surface tension, the skin that holds a boule tall."
        case .log: return "Trace the curve of the roll, end to end, to seal the seam."
        case .sticks: return "Trace each stick from end to end — three even lengths."
        case .braid: return "Trace the weaving path, over and under, one flowing line."
        case .twist: return "Trace the twisting path so the two strands wrap each other."
        case .dimple: return "Trace around the pan — then imagine your fingertips dimpling every inch."
        case .crescent: return "Trace the crescent's sweep from tip to tip."
        case .star: return "Trace from the centre out along each ray of the star."
        }
    }

    private func computeShapeAccuracy(canvas: CGSize) -> Double {
        let guidePts = shapeGuide.map { CGPoint(x: $0.x * canvas.width, y: $0.y * canvas.height) }
        guard !drawnPoints.isEmpty, !guidePts.isEmpty else { return 0 }
        let threshold: CGFloat = 34
        var covered = 0
        for g in guidePts {
            var hit = false
            var i = 0
            while i < drawnPoints.count {
                let d = drawnPoints[i]
                if abs(d.x - g.x) < threshold && abs(d.y - g.y) < threshold && hypot(d.x - g.x, d.y - g.y) < threshold {
                    hit = true
                    break
                }
                i += 3
            }
            if hit { covered += 1 }
        }
        var offTrack = 0
        var i = 0
        while i < drawnPoints.count {
            let d = drawnPoints[i]
            var minD: CGFloat = .infinity
            for g in guidePts {
                let dist = hypot(d.x - g.x, d.y - g.y)
                if dist < minD { minD = dist }
            }
            if minD > threshold * 1.6 { offTrack += 1 }
            i += 4
        }
        let coverage = Double(covered) / Double(guidePts.count)
        let sloppy = Double(offTrack) / Double(max(1, drawnPoints.count / 4))
        return (coverage - sloppy * 0.35).bakeClamped(0, 1)
    }

    private var slashStage: some View {
        VStack(spacing: 14) {
            Text("Draw \(recipe.slashCount == 1 ? "one confident slash" : "\(recipe.slashCount) confident slashes") across the loaf — quick, straight, and unapologetic.")
                .font(BakeTheme.serif(15))
                .foregroundColor(BakeTheme.inkSoft)
                .frame(maxWidth: .infinity, alignment: .leading)
            ZStack {
                RoundedRectangle(cornerRadius: 18).fill(BakeTheme.paper)
                    .shadow(color: BakeTheme.cardShadow, radius: 6, x: 0, y: 3)
                Canvas { ctx, size in
                    let rect = CGRect(origin: .zero, size: size).insetBy(dx: size.width * 0.1, dy: size.height * 0.08)
                    var all = slashes
                    if let live = slashLive { all.append(live) }
                    DoughArtist.drawLoaf(&ctx, rect: rect, shape: recipe.shapeKind, tint: recipe.doughTint, crust: 0.06, slashes: all, seed: 21)
                }
                .gesture(
                    DragGesture(minimumDistance: 4)
                        .onChanged { value in
                            if slashStart == nil { slashStart = value.startLocation }
                            slashLive = DoughArtist.Slash(from: value.startLocation, to: value.location)
                        }
                        .onEnded { value in
                            guard slashes.count < recipe.slashCount + 2 else {
                                slashStart = nil
                                slashLive = nil
                                return
                            }
                            let stroke = DoughArtist.Slash(from: value.startLocation, to: value.location)
                            if hypot(stroke.to.x - stroke.from.x, stroke.to.y - stroke.from.y) > 30 {
                                slashes.append(stroke)
                                BakeHaptics.tap()
                            }
                            slashStart = nil
                            slashLive = nil
                        }
                )
            }
            .frame(height: 250)
            HStack {
                Text("\(slashes.count) of \(recipe.slashCount) cuts")
                    .font(BakeTheme.heading(13))
                    .foregroundColor(BakeTheme.inkSoft)
                Spacer()
                Button {
                    slashes = []
                    BakeHaptics.tap()
                } label: {
                    Text("Smooth it over")
                        .font(BakeTheme.body(13))
                        .foregroundColor(BakeTheme.terraDeep)
                }
            }
            .bakeCard(padding: 13)
            if slashes.count >= recipe.slashCount {
                Button {
                    marks.slash = slashMark()
                    advance()
                } label: {
                    Text("Signed — to the oven")
                }
                .buttonStyle(BakePrimaryButton())
            }
        }
    }

    private func slashMark() -> Double {
        guard recipe.slashCount > 0 else { return 1 }
        let countPart = 1.0 - Double(abs(slashes.count - recipe.slashCount)) * 0.25
        var lengths: [CGFloat] = []
        var angles: [CGFloat] = []
        for s in slashes {
            lengths.append(hypot(s.to.x - s.from.x, s.to.y - s.from.y))
            angles.append(atan2(s.to.y - s.from.y, s.to.x - s.from.x))
        }
        var anglePart = 1.0
        if angles.count > 1 {
            let first = angles[0]
            var spread: CGFloat = 0
            for a in angles {
                var diff = abs(a - first)
                while diff > .pi { diff -= .pi }
                spread = max(spread, min(diff, .pi - diff))
            }
            anglePart = Double(1 - (spread / (.pi / 2)).bakeClamped(0, 1) * 0.5)
        }
        let lengthPart = lengths.allSatisfy { $0 > 60 } ? 1.0 : 0.75
        return (countPart * 0.5 + anglePart * 0.3 + lengthPart * 0.2).bakeClamped(0.1, 1)
    }

    private var bakeStage: some View {
        VStack(spacing: 14) {
            Text("Watch the colour, not the clock. \(recipe.wantsSteam ? "Throw in steam early so the loaf can climb, then " : "")pull it at \(crustWord(recipe.crustTarget)).")
                .font(BakeTheme.serif(15))
                .foregroundColor(BakeTheme.inkSoft)
                .frame(maxWidth: .infinity, alignment: .leading)
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(LinearGradient(colors: [Color(red: 0.24, green: 0.15, blue: 0.10), Color(red: 0.38, green: 0.22, blue: 0.13)], startPoint: .top, endPoint: .bottom))
                    .shadow(color: BakeTheme.cardShadow, radius: 6, x: 0, y: 3)
                Canvas { ctx, size in
                    let glow = Path(ellipseIn: CGRect(x: size.width * 0.1, y: size.height * 0.55, width: size.width * 0.8, height: size.height * 0.5))
                    ctx.fill(glow, with: .radialGradient(Gradient(colors: [Color(red: 1, green: 0.6, blue: 0.25).opacity(0.24 + ovenHeat * 0.3), .clear]), center: CGPoint(x: size.width / 2, y: size.height * 0.85), startRadius: 0, endRadius: size.width * 0.5))
                    let rect = CGRect(origin: .zero, size: size).insetBy(dx: size.width * 0.16, dy: size.height * 0.14)
                    DoughArtist.drawLoaf(&ctx, rect: rect, shape: recipe.shapeKind, tint: recipe.doughTint, crust: crust, slashes: [], seed: 21, seeds: recipe.id == "crown")
                    if steamUsed && bakeElapsed < 8 {
                        var rng = BakeSeededRandom(seed: 3)
                        for _ in 0..<8 {
                            let sx = size.width * (0.2 + rng.next() * 0.6)
                            let sy = size.height * (0.12 + rng.next() * 0.2) - CGFloat(phase.truncatingRemainder(dividingBy: 2)) * 8
                            ctx.fill(Path(ellipseIn: CGRect(x: sx, y: sy, width: 14, height: 8)), with: .color(Color.white.opacity(0.18)))
                        }
                    }
                    if crust > 0.9 {
                        ctx.draw(Text("it is burning").font(BakeTheme.heading(13)).foregroundColor(Color(red: 1, green: 0.5, blue: 0.4)), at: CGPoint(x: size.width / 2, y: size.height * 0.1))
                    }
                }
            }
            .frame(height: 250)
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    BIcon(kind: .flame, size: 16, color: BakeTheme.terracotta)
                    Slider(value: $ovenHeat, in: 0...1)
                        .accentColor(BakeTheme.terracotta)
                    Text("\(180 + Int(ovenHeat * 70))°")
                        .font(BakeTheme.mono(13))
                        .foregroundColor(BakeTheme.inkSoft)
                        .frame(width: 44, alignment: .trailing)
                }
                HStack(spacing: 8) {
                    Text("Crust:")
                        .font(BakeTheme.heading(13))
                        .foregroundColor(BakeTheme.inkFaint)
                    Text(crustWord(crust))
                        .font(BakeTheme.body(13))
                        .foregroundColor(DoughArtist.crustColor(max(0.2, crust), tint: 0))
                    Spacer()
                    Text("aim: \(crustWord(recipe.crustTarget))")
                        .font(BakeTheme.body(12))
                        .foregroundColor(BakeTheme.inkFaint)
                }
            }
            .bakeCard(padding: 14)
            HStack(spacing: 10) {
                if recipe.wantsSteam {
                    Button {
                        guard !steamUsed && bakeElapsed < 6 else { return }
                        steamUsed = true
                        BakeHaptics.thump()
                    } label: {
                        HStack(spacing: 6) {
                            BIcon(kind: .drop, size: 14, color: steamUsed ? BakeTheme.inkFaint : BakeTheme.terraDeep)
                            Text(steamUsed ? "Steam is in" : "Throw in steam")
                        }
                    }
                    .buttonStyle(BakeSoftButton())
                    .disabled(steamUsed || bakeElapsed >= 6)
                    .opacity(steamUsed || bakeElapsed >= 6 ? 0.55 : 1)
                }
                Button {
                    pulled = true
                    let steamOK = !recipe.wantsSteam || steamUsed
                    marks.bake = BakeMath.bakeMark(crust: crust, target: recipe.crustTarget, steamOK: steamOK, wantsSteam: recipe.wantsSteam)
                    let rec = store.recordBake(
                        recipe: recipe, marks: marks, crust: crust,
                        hydration: hydrationSet, ferment: ferment, gluten: glutenWork,
                        usedSteam: steamUsed)
                    record = rec
                    advance()
                } label: {
                    Text("Pull it out")
                }
                .buttonStyle(BakePrimaryButton())
            }
        }
    }

    private func crustWord(_ c: Double) -> String {
        if c < 0.15 { return "raw dough" }
        if c < 0.35 { return "pale" }
        if c < 0.5 { return "first gold" }
        if c < 0.62 { return "golden" }
        if c < 0.74 { return "deep gold" }
        if c < 0.84 { return "bold brown" }
        if c < 0.93 { return "mahogany" }
        return "burnt"
    }

    private var revealStage: some View {
        VStack(spacing: 16) {
            if let record = record {
                Text(BakeVerdicts.title(stars: record.stars))
                    .font(BakeTheme.title(22))
                    .foregroundColor(BakeTheme.ink)
                    .multilineTextAlignment(.center)
                StarRow(stars: record.stars, size: 26)
                ZStack {
                    RoundedRectangle(cornerRadius: 18).fill(BakeTheme.paper)
                        .shadow(color: BakeTheme.cardShadow, radius: 6, x: 0, y: 3)
                    Canvas { ctx, size in
                        let half = size.width / 2
                        let loafRect = CGRect(x: 8, y: size.height * 0.08, width: half - 16, height: size.height * 0.84)
                        DoughArtist.drawLoaf(&ctx, rect: loafRect, shape: recipe.shapeKind, tint: recipe.doughTint, crust: record.crust, slashes: [], seed: 21)
                        let crumbRect = CGRect(x: half + 8, y: size.height * 0.08, width: half - 16, height: size.height * 0.84)
                        let spec = CrumbSpec.from(hydration: record.hydration, ferment: record.ferment, gluten: record.gluten, seed: 5)
                        var inner = ctx
                        DoughArtist.drawCrumbSlice(&inner, rect: crumbRect, spec: spec, tint: recipe.doughTint, crust: record.crust)
                    }
                }
                .frame(height: 200)
                VStack(alignment: .leading, spacing: 10) {
                    verdictRow(icon: .knife, text: BakeVerdicts.crumbLine(hydration: record.hydration, ferment: record.ferment, gluten: record.gluten))
                    verdictRow(icon: .flame, text: BakeVerdicts.crustLine(crust: record.crust, target: recipe.crustTarget, steamOK: !recipe.wantsSteam || steamUsed))
                    verdictRow(icon: .sparkle, text: recipe.tip)
                }
                .bakeCard()
                HStack(spacing: 12) {
                    stageScore("Mix", marks.mix, show: recipe.stages.contains(.mix))
                    stageScore("Knead", marks.knead, show: recipe.stages.contains(.knead))
                    stageScore("Fold", marks.laminate, show: recipe.stages.contains(.laminate))
                    stageScore("Proof", marks.proofRise, show: recipe.stages.contains(.proofRise))
                    stageScore("Shape", marks.shape, show: recipe.stages.contains(.shape))
                    stageScore("Score", marks.slash, show: recipe.stages.contains(.slash))
                    stageScore("Bake", marks.bake, show: recipe.stages.contains(.bake))
                }
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Set it in the window")
                }
                .buttonStyle(BakePrimaryButton())
            }
        }
    }

    private func verdictRow(icon: BIconKind, text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            BIcon(kind: icon, size: 16, color: BakeTheme.terraDeep)
                .padding(.top, 1)
            Text(text)
                .font(BakeTheme.serif(14))
                .foregroundColor(BakeTheme.inkSoft)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func stageScore(_ label: String, _ value: Double, show: Bool) -> some View {
        if show {
            VStack(spacing: 4) {
                BakeProgressRing(progress: value, size: 34, lineWidth: 4, color: value >= 0.8 ? BakeTheme.sage : (value >= 0.5 ? BakeTheme.wheat : BakeTheme.berry))
                Text(label)
                    .font(BakeTheme.body(9))
                    .foregroundColor(BakeTheme.inkFaint)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct FlowChips: View {
    let items: [String]
    let onTap: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(row, id: \.self) { item in
                        Button {
                            onTap(item)
                        } label: {
                            Text(item)
                                .font(BakeTheme.body(14))
                                .foregroundColor(BakeTheme.ink)
                                .padding(.horizontal, 13)
                                .padding(.vertical, 9)
                                .background(Capsule().fill(BakeTheme.butter.opacity(0.55)))
                                .overlay(Capsule().stroke(BakeTheme.wheat.opacity(0.6), lineWidth: 1))
                        }
                    }
                    Spacer(minLength: 0)
                }
            }
        }
    }

    private var rows: [[String]] {
        var result: [[String]] = []
        var current: [String] = []
        var width = 0
        for item in items {
            let w = item.count + 4
            if width + w > 34 && !current.isEmpty {
                result.append(current)
                current = []
                width = 0
            }
            current.append(item)
            width += w
        }
        if !current.isEmpty { result.append(current) }
        return result
    }
}
