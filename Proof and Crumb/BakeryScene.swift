import SwiftUI

struct ShopWindowScene: View {
    let records: [BakeRecord]
    var phase: Double
    var daylight: Double

    var body: some View {
        Canvas { ctx, size in
            let w = size.width
            let h = size.height
            ctx.fill(Path(roundedRect: CGRect(x: 0, y: 0, width: w, height: h), cornerRadius: 18), with: .linearGradient(Gradient(colors: [Color(red: 0.55, green: 0.38, blue: 0.22), Color(red: 0.42, green: 0.28, blue: 0.16)]), startPoint: .zero, endPoint: CGPoint(x: 0, y: h)))
            var rng = BakeSeededRandom(seed: 8)
            for _ in 0..<24 {
                let gy = rng.next() * h
                var grain = Path()
                grain.move(to: CGPoint(x: 0, y: gy))
                grain.addQuadCurve(to: CGPoint(x: w, y: gy + rng.next() * 8 - 4), control: CGPoint(x: w / 2, y: gy + rng.next() * 10 - 5))
                ctx.stroke(grain, with: .color(Color.black.opacity(0.06 + Double(rng.next()) * 0.05)), lineWidth: 0.8 + rng.next() * 1.2)
            }
            let windowRect = CGRect(x: w * 0.05, y: h * 0.08, width: w * 0.9, height: h * 0.84)
            let skyTop = Color(red: 0.55 + daylight * 0.3, green: 0.62 + daylight * 0.25, blue: 0.72 + daylight * 0.15)
            ctx.fill(Path(roundedRect: windowRect, cornerRadius: 12), with: .linearGradient(Gradient(colors: [skyTop.opacity(0.5), BakeTheme.cream.opacity(0.9)]), startPoint: CGPoint(x: 0, y: windowRect.minY), endPoint: CGPoint(x: 0, y: windowRect.maxY)))
            ctx.stroke(Path(roundedRect: windowRect, cornerRadius: 12), with: .color(Color(red: 0.35, green: 0.22, blue: 0.12)), lineWidth: 3)

            let shelfYs = [windowRect.minY + windowRect.height * 0.36, windowRect.minY + windowRect.height * 0.66, windowRect.minY + windowRect.height * 0.94]
            for sy in shelfYs {
                var shelf = Path()
                shelf.move(to: CGPoint(x: windowRect.minX + 6, y: sy))
                shelf.addLine(to: CGPoint(x: windowRect.maxX - 6, y: sy))
                ctx.stroke(shelf, with: .color(Color(red: 0.45, green: 0.30, blue: 0.17)), lineWidth: 5)
            }
            let perShelf = 4
            let slotW = (windowRect.width - 24) / CGFloat(perShelf)
            for (i, record) in records.prefix(12).enumerated() {
                let shelfIdx = i / perShelf
                let slot = i % perShelf
                let sy = shelfYs[min(shelfIdx, shelfYs.count - 1)]
                let cx = windowRect.minX + 12 + slotW * CGFloat(slot) + slotW / 2
                let recipe = BakeBook.recipe(record.recipeID)
                let bob = CGFloat(sin(phase * 0.8 + Double(i))) * 0.6
                let loafRect = CGRect(x: cx - slotW * 0.4, y: sy - slotW * 0.52 + bob, width: slotW * 0.8, height: slotW * 0.5)
                var inner = ctx
                DoughArtist.drawLoaf(&inner, rect: loafRect, shape: recipe.shapeKind, tint: recipe.doughTint, crust: record.crust, slashes: [], seed: UInt64(50 + i))
                if record.stars == 3 {
                    let tw = CGFloat(4)
                    let sparkX = loafRect.maxX - 6 + CGFloat(sin(phase * 3 + Double(i))) * 1.5
                    ctx.fill(Path(ellipseIn: CGRect(x: sparkX, y: loafRect.minY + 2, width: tw, height: tw)), with: .color(BakeTheme.butter.opacity(0.5 + 0.5 * sin(phase * 3 + Double(i)))))
                }
            }
            if records.isEmpty {
                ctx.draw(Text("The window waits for its first bake").font(BakeTheme.serif(14)).foregroundColor(BakeTheme.inkFaint), at: CGPoint(x: w / 2, y: h / 2))
            }
            let signRect = CGRect(x: w * 0.30, y: h * 0.012, width: w * 0.4, height: h * 0.075)
            ctx.fill(Path(roundedRect: signRect, cornerRadius: 6), with: .color(BakeTheme.cream))
            ctx.stroke(Path(roundedRect: signRect, cornerRadius: 6), with: .color(Color(red: 0.35, green: 0.22, blue: 0.12)), lineWidth: 1.6)
            ctx.draw(Text("PROOF & CRUMB").font(BakeTheme.serifBold(11)).foregroundColor(BakeTheme.crust), at: CGPoint(x: signRect.midX, y: signRect.midY))
        }
    }
}

struct StarterJarView: View {
    let health: Double
    var phase: Double
    var size: CGFloat = 90

    var body: some View {
        Canvas { ctx, canvasSize in
            let w = canvasSize.width
            let h = canvasSize.height
            let jarRect = CGRect(x: w * 0.16, y: h * 0.16, width: w * 0.68, height: h * 0.76)
            let level = 0.3 + (health / 100) * 0.44
            let liquidTop = jarRect.maxY - jarRect.height * CGFloat(level)
            var body = Path()
            body.move(to: CGPoint(x: jarRect.minX, y: jarRect.minY + 6))
            body.addLine(to: CGPoint(x: jarRect.minX + 3, y: jarRect.maxY - 8))
            body.addQuadCurve(to: CGPoint(x: jarRect.maxX - 3, y: jarRect.maxY - 8), control: CGPoint(x: jarRect.midX, y: jarRect.maxY + 4))
            body.addLine(to: CGPoint(x: jarRect.maxX, y: jarRect.minY + 6))
            ctx.fill(body, with: .color(Color.white.opacity(0.35)))
            let starterColor = health > 55 ? BakeTheme.doughPale : Color(red: 0.80, green: 0.76, blue: 0.68)
            var starter = Path()
            let bump = CGFloat(sin(phase * 1.6)) * (health > 60 ? 2.2 : 0.5)
            starter.move(to: CGPoint(x: jarRect.minX + 3, y: liquidTop + bump))
            starter.addQuadCurve(to: CGPoint(x: jarRect.maxX - 3, y: liquidTop - bump), control: CGPoint(x: jarRect.midX, y: liquidTop - 5 - bump))
            starter.addLine(to: CGPoint(x: jarRect.maxX - 3, y: jarRect.maxY - 8))
            starter.addQuadCurve(to: CGPoint(x: jarRect.minX + 3, y: jarRect.maxY - 8), control: CGPoint(x: jarRect.midX, y: jarRect.maxY + 4))
            starter.closeSubpath()
            ctx.fill(starter, with: .color(starterColor))
            var rng = BakeSeededRandom(seed: 91)
            let bubbleCount = Int(health / 9)
            for i in 0..<bubbleCount {
                let bx = jarRect.minX + 8 + rng.next() * (jarRect.width - 16)
                let cycle = (phase * (0.3 + Double(rng.next()) * 0.5) + Double(rng.next()) * 4).truncatingRemainder(dividingBy: 4) / 4
                let by = jarRect.maxY - 12 - CGFloat(cycle) * (jarRect.maxY - liquidTop - 16)
                let r = 1.2 + rng.next() * 2.4
                if by > liquidTop + 4 {
                    ctx.stroke(Path(ellipseIn: CGRect(x: bx - r, y: by - r, width: r * 2, height: r * 2)), with: .color(BakeTheme.ink.opacity(0.14)), lineWidth: 1)
                }
                _ = i
            }
            ctx.stroke(body, with: .color(BakeTheme.ink.opacity(0.5)), lineWidth: 1.8)
            let lid = Path(roundedRect: CGRect(x: jarRect.minX - 4, y: h * 0.06, width: jarRect.width + 8, height: h * 0.1), cornerRadius: 3)
            ctx.fill(lid, with: .color(BakeTheme.terracotta))
            ctx.stroke(lid, with: .color(BakeTheme.ink.opacity(0.5)), lineWidth: 1.4)
            var mark = Path()
            mark.move(to: CGPoint(x: jarRect.maxX + 3, y: liquidTop))
            mark.addLine(to: CGPoint(x: jarRect.maxX + 8, y: liquidTop))
            ctx.stroke(mark, with: .color(BakeTheme.berry.opacity(0.8)), lineWidth: 2)
        }
        .frame(width: size, height: size * 1.1)
    }
}
