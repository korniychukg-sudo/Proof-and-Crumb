import SwiftUI

enum BakeTheme {
    static let cream = Color(red: 0.969, green: 0.937, blue: 0.871)
    static let paper = Color(red: 0.984, green: 0.961, blue: 0.910)
    static let flour = Color(red: 0.973, green: 0.957, blue: 0.925)
    static let butter = Color(red: 0.949, green: 0.867, blue: 0.639)
    static let wheat = Color(red: 0.851, green: 0.643, blue: 0.255)
    static let wheatDeep = Color(red: 0.722, green: 0.518, blue: 0.173)
    static let honey = Color(red: 0.898, green: 0.718, blue: 0.353)
    static let crust = Color(red: 0.557, green: 0.329, blue: 0.149)
    static let crustLight = Color(red: 0.729, green: 0.478, blue: 0.243)
    static let terracotta = Color(red: 0.725, green: 0.420, blue: 0.247)
    static let terraDeep = Color(red: 0.573, green: 0.310, blue: 0.173)
    static let rye = Color(red: 0.420, green: 0.290, blue: 0.173)
    static let ink = Color(red: 0.200, green: 0.141, blue: 0.102)
    static let inkSoft = Color(red: 0.365, green: 0.286, blue: 0.220)
    static let inkFaint = Color(red: 0.541, green: 0.463, blue: 0.384)
    static let sage = Color(red: 0.478, green: 0.557, blue: 0.416)
    static let sageDeep = Color(red: 0.353, green: 0.435, blue: 0.302)
    static let berry = Color(red: 0.639, green: 0.286, blue: 0.243)
    static let sky = Color(red: 0.788, green: 0.835, blue: 0.812)
    static let doughPale = Color(red: 0.937, green: 0.894, blue: 0.792)
    static let doughShade = Color(red: 0.851, green: 0.784, blue: 0.647)
    static let cardShadow = Color.black.opacity(0.10)

    static func title(_ size: CGFloat) -> Font { Font.system(size: size, weight: .bold, design: .rounded) }
    static func heading(_ size: CGFloat) -> Font { Font.system(size: size, weight: .semibold, design: .rounded) }
    static func body(_ size: CGFloat) -> Font { Font.system(size: size, weight: .regular, design: .rounded) }
    static func serif(_ size: CGFloat) -> Font { Font.custom("Georgia", size: size) }
    static func serifBold(_ size: CGFloat) -> Font { Font.custom("Georgia-Bold", size: size) }
    static func mono(_ size: CGFloat) -> Font { Font.system(size: size, weight: .medium, design: .monospaced) }
}

struct BakeSeededRandom {
    private var state: UInt64
    init(seed: UInt64) { state = seed &* 6364136223846793005 &+ 1442695040888963407 }
    mutating func next() -> CGFloat {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return CGFloat((state >> 33) & 0xFFFFFF) / CGFloat(0xFFFFFF)
    }
    mutating func nextInt(_ upper: Int) -> Int {
        guard upper > 0 else { return 0 }
        return min(upper - 1, Int(next() * CGFloat(upper)))
    }
}

extension Double {
    func bakeClamped(_ lo: Double, _ hi: Double) -> Double { Swift.max(lo, Swift.min(hi, self)) }
}

extension CGFloat {
    func bakeClamped(_ lo: CGFloat, _ hi: CGFloat) -> CGFloat { Swift.max(lo, Swift.min(hi, self)) }
}

struct FlourBackdrop: View {
    var tone: Color = BakeTheme.cream
    var body: some View {
        ZStack {
            tone
            GeometryReader { geo in
                Canvas { ctx, size in
                    var rng = BakeSeededRandom(seed: 23)
                    for _ in 0..<260 {
                        let x = rng.next() * size.width
                        let y = rng.next() * size.height
                        let r = 0.6 + rng.next() * 1.6
                        ctx.fill(Path(ellipseIn: CGRect(x: x, y: y, width: r, height: r * (0.7 + rng.next() * 0.6))), with: .color(BakeTheme.ink.opacity(0.015 + Double(rng.next()) * 0.035)))
                    }
                    for _ in 0..<10 {
                        let x = rng.next() * size.width
                        let y = rng.next() * size.height
                        let r = 20 + rng.next() * 60
                        ctx.fill(Path(ellipseIn: CGRect(x: x - r, y: y - r * 0.6, width: r * 2, height: r * 1.2)), with: .color(BakeTheme.wheat.opacity(0.02 + Double(rng.next()) * 0.03)))
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
}

struct BakeHaptics {
    static func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    static func thump() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
}
