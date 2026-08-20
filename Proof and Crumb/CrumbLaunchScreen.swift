import SwiftUI

struct CrumbLaunchScreen: View {
    @State private var rise = false
    @State private var steamPhase: CGFloat = 0

    var body: some View {
        ZStack {
            FlourBackdrop(tone: BakeTheme.cream)
            VStack(spacing: 24) {
                Canvas { ctx, size in
                    let rect = CGRect(origin: .zero, size: size)
                    let baseY = rect.midY + rect.height * 0.22
                    ctx.fill(Path(roundedRect: CGRect(x: rect.minX + 20, y: baseY, width: rect.width - 40, height: 12), cornerRadius: 4), with: .color(BakeTheme.crust.opacity(0.75)))
                    let br = rect.width * 0.24
                    let c = CGPoint(x: rect.midX, y: baseY - br * 0.55)
                    ctx.fill(Path(ellipseIn: CGRect(x: c.x - br * 1.05, y: baseY - 8, width: br * 2.1, height: 16)), with: .color(Color.black.opacity(0.14)))
                    var dome = Path()
                    dome.move(to: CGPoint(x: c.x - br, y: baseY))
                    dome.addCurve(to: CGPoint(x: c.x + br, y: baseY),
                                  control1: CGPoint(x: c.x - br * 1.05, y: baseY - br * 1.5),
                                  control2: CGPoint(x: c.x + br * 1.05, y: baseY - br * 1.5))
                    dome.closeSubpath()
                    ctx.fill(dome, with: .linearGradient(Gradient(colors: [BakeTheme.honey, BakeTheme.crust]), startPoint: CGPoint(x: c.x, y: baseY - br), endPoint: CGPoint(x: c.x, y: baseY)))
                    ctx.stroke(dome, with: .color(BakeTheme.ink.opacity(0.45)), lineWidth: 1.6)
                    var slash = Path()
                    slash.move(to: CGPoint(x: c.x - br * 0.5, y: baseY - br * 0.62))
                    slash.addQuadCurve(to: CGPoint(x: c.x + br * 0.52, y: baseY - br * 0.72), control: CGPoint(x: c.x, y: baseY - br * 0.44))
                    ctx.stroke(slash, with: .color(BakeTheme.doughPale), style: StrokeStyle(lineWidth: 7, lineCap: .round))
                    var rng = BakeSeededRandom(seed: 11)
                    for _ in 0..<26 {
                        let a = rng.next() * .pi
                        let rr = rng.next()
                        let px = c.x + cos(a + .pi) * br * 0.8 * rr
                        let py = baseY - abs(sin(a)) * br * 1.1 * rr
                        ctx.fill(Path(ellipseIn: CGRect(x: px, y: py, width: 2.6, height: 2.2)), with: .color(BakeTheme.flour.opacity(0.7)))
                    }
                    for i in 0..<3 {
                        let t = (steamPhase + CGFloat(i) * 0.33).truncatingRemainder(dividingBy: 1)
                        let sx = c.x + CGFloat(i - 1) * 26 + sin(t * 6) * 6
                        let sy = baseY - br * 1.5 - t * 46
                        let r = 5 + t * 9
                        ctx.fill(Path(ellipseIn: CGRect(x: sx - r, y: sy - r, width: r * 2, height: r * 1.5)), with: .color(Color.white.opacity(Double(0.45 * (1 - t)))))
                    }
                }
                .frame(width: 260, height: 170)
                Text("Proof & Crumb")
                    .font(BakeTheme.title(24))
                    .foregroundColor(BakeTheme.ink)
                ZStack {
                    Capsule().fill(BakeTheme.ink.opacity(0.10)).frame(width: 132, height: 6)
                    Capsule()
                        .fill(BakeTheme.terracotta)
                        .frame(width: 46, height: 6)
                        .offset(x: rise ? 43 : -43)
                        .animation(Animation.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: rise)
                }
            }
        }
        .onAppear {
            rise = true
            withAnimation(Animation.linear(duration: 2.4).repeatForever(autoreverses: false)) {
                steamPhase = 1
            }
        }
    }
}
