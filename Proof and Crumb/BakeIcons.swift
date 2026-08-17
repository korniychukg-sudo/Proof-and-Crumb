import SwiftUI

enum BIconKind {
    case bakery, book, starter, learn, journal
    case play, check, lock, chevronRight, chevronDown, star, close, plus, flame, wheatStalk, whisk, timerGlass, ribbon, jar, oven, knife, drop, sparkle
}

struct BIcon: View {
    let kind: BIconKind
    var size: CGFloat = 24
    var color: Color = BakeTheme.ink

    var body: some View {
        Canvas { ctx, canvasSize in
            let rect = CGRect(origin: .zero, size: canvasSize).insetBy(dx: canvasSize.width * 0.08, dy: canvasSize.height * 0.08)
            draw(&ctx, rect: rect)
        }
        .frame(width: size, height: size)
    }

    private func stroke(_ ctx: inout GraphicsContext, _ p: Path, _ w: CGFloat) {
        ctx.stroke(p, with: .color(color), style: StrokeStyle(lineWidth: w, lineCap: .round, lineJoin: .round))
    }

    private func draw(_ ctx: inout GraphicsContext, rect: CGRect) {
        let w = rect.width
        let h = rect.height
        let lw = max(1.4, w * 0.09)
        switch kind {
        case .bakery:
            var awning = Path()
            awning.move(to: CGPoint(x: rect.minX, y: rect.minY + h * 0.30))
            awning.addLine(to: CGPoint(x: rect.minX, y: rect.minY + h * 0.14))
            awning.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + h * 0.14))
            awning.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + h * 0.30))
            stroke(&ctx, awning, lw)
            for i in 0..<4 {
                let x0 = rect.minX + w * CGFloat(i) / 4
                var scallop = Path()
                scallop.addArc(center: CGPoint(x: x0 + w / 8, y: rect.minY + h * 0.30), radius: w / 8, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 180), clockwise: false)
                stroke(&ctx, scallop, lw * 0.8)
            }
            var shop = Path()
            shop.move(to: CGPoint(x: rect.minX + w * 0.12, y: rect.minY + h * 0.42))
            shop.addLine(to: CGPoint(x: rect.minX + w * 0.12, y: rect.maxY))
            shop.move(to: CGPoint(x: rect.maxX - w * 0.12, y: rect.minY + h * 0.42))
            shop.addLine(to: CGPoint(x: rect.maxX - w * 0.12, y: rect.maxY))
            shop.move(to: CGPoint(x: rect.minX + w * 0.12, y: rect.maxY))
            shop.addLine(to: CGPoint(x: rect.maxX - w * 0.12, y: rect.maxY))
            stroke(&ctx, shop, lw)
            var loafP = Path()
            loafP.addArc(center: CGPoint(x: rect.midX, y: rect.maxY - h * 0.12), radius: w * 0.18, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 0), clockwise: false)
            loafP.closeSubpath()
            ctx.fill(loafP, with: .color(color))
        case .book:
            var book = Path()
            book.move(to: CGPoint(x: rect.midX, y: rect.minY + h * 0.16))
            book.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.minY + h * 0.10), control: CGPoint(x: rect.minX + w * 0.22, y: rect.minY))
            book.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - h * 0.12))
            book.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.maxY), control: CGPoint(x: rect.minX + w * 0.24, y: rect.maxY - h * 0.06))
            book.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.maxY - h * 0.12), control: CGPoint(x: rect.maxX - w * 0.24, y: rect.maxY - h * 0.06))
            book.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + h * 0.10))
            book.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.minY + h * 0.16), control: CGPoint(x: rect.maxX - w * 0.22, y: rect.minY))
            book.move(to: CGPoint(x: rect.midX, y: rect.minY + h * 0.16))
            book.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            stroke(&ctx, book, lw)
        case .starter, .jar:
            var jar = Path()
            jar.move(to: CGPoint(x: rect.minX + w * 0.2, y: rect.minY + h * 0.22))
            jar.addLine(to: CGPoint(x: rect.minX + w * 0.18, y: rect.maxY - h * 0.08))
            jar.addQuadCurve(to: CGPoint(x: rect.maxX - w * 0.18, y: rect.maxY - h * 0.08), control: CGPoint(x: rect.midX, y: rect.maxY + h * 0.02))
            jar.addLine(to: CGPoint(x: rect.maxX - w * 0.2, y: rect.minY + h * 0.22))
            stroke(&ctx, jar, lw)
            var lid = Path()
            lid.addRoundedRect(in: CGRect(x: rect.minX + w * 0.14, y: rect.minY + h * 0.06, width: w * 0.72, height: h * 0.14), cornerSize: CGSize(width: 2, height: 2))
            stroke(&ctx, lid, lw)
            for (bx, by, br) in [(0.36, 0.52, 0.05), (0.6, 0.62, 0.07), (0.46, 0.74, 0.045)] {
                var bubble = Path()
                bubble.addEllipse(in: CGRect(x: rect.minX + w * CGFloat(bx), y: rect.minY + h * CGFloat(by), width: w * CGFloat(br) * 2, height: w * CGFloat(br) * 2))
                stroke(&ctx, bubble, lw * 0.7)
            }
        case .learn:
            var cap = Path()
            cap.move(to: CGPoint(x: rect.minX, y: rect.minY + h * 0.34))
            cap.addLine(to: CGPoint(x: rect.midX, y: rect.minY + h * 0.1))
            cap.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + h * 0.34))
            cap.addLine(to: CGPoint(x: rect.midX, y: rect.minY + h * 0.58))
            cap.closeSubpath()
            stroke(&ctx, cap, lw)
            var tassel = Path()
            tassel.move(to: CGPoint(x: rect.maxX - w * 0.16, y: rect.minY + h * 0.4))
            tassel.addLine(to: CGPoint(x: rect.maxX - w * 0.16, y: rect.maxY - h * 0.2))
            stroke(&ctx, tassel, lw * 0.8)
            var base = Path()
            base.move(to: CGPoint(x: rect.minX + w * 0.24, y: rect.minY + h * 0.5))
            base.addLine(to: CGPoint(x: rect.minX + w * 0.24, y: rect.maxY - h * 0.16))
            base.addQuadCurve(to: CGPoint(x: rect.maxX - w * 0.24, y: rect.maxY - h * 0.16), control: CGPoint(x: rect.midX, y: rect.maxY))
            base.addLine(to: CGPoint(x: rect.maxX - w * 0.24, y: rect.minY + h * 0.5))
            stroke(&ctx, base, lw)
        case .journal:
            var medal = Path()
            medal.addEllipse(in: CGRect(x: rect.midX - w * 0.24, y: rect.minY, width: w * 0.48, height: w * 0.48))
            stroke(&ctx, medal, lw)
            var star = Path()
            let c = CGPoint(x: rect.midX, y: rect.minY + w * 0.24)
            for i in 0..<5 {
                let ang = CGFloat(i) * 2 * .pi / 5 - .pi / 2
                let pt = CGPoint(x: c.x + cos(ang) * w * 0.11, y: c.y + sin(ang) * w * 0.11)
                if i == 0 { star.move(to: pt) } else { star.addLine(to: pt) }
                let ang2 = ang + .pi / 5
                star.addLine(to: CGPoint(x: c.x + cos(ang2) * w * 0.045, y: c.y + sin(ang2) * w * 0.045))
            }
            star.closeSubpath()
            ctx.fill(star, with: .color(color))
            var ribbons = Path()
            ribbons.move(to: CGPoint(x: rect.midX - w * 0.13, y: rect.minY + w * 0.44))
            ribbons.addLine(to: CGPoint(x: rect.midX - w * 0.20, y: rect.maxY))
            ribbons.move(to: CGPoint(x: rect.midX + w * 0.13, y: rect.minY + w * 0.44))
            ribbons.addLine(to: CGPoint(x: rect.midX + w * 0.20, y: rect.maxY))
            stroke(&ctx, ribbons, lw)
        case .play:
            var p = Path()
            p.move(to: CGPoint(x: rect.minX + w * 0.16, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            p.addLine(to: CGPoint(x: rect.minX + w * 0.16, y: rect.maxY))
            p.closeSubpath()
            ctx.fill(p, with: .color(color))
        case .check:
            var p = Path()
            p.move(to: CGPoint(x: rect.minX, y: rect.midY + h * 0.06))
            p.addLine(to: CGPoint(x: rect.minX + w * 0.34, y: rect.maxY - h * 0.12))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + h * 0.10))
            stroke(&ctx, p, lw * 1.2)
        case .lock:
            let bodyR = CGRect(x: rect.minX + w * 0.14, y: rect.midY - h * 0.04, width: w * 0.72, height: h * 0.56)
            stroke(&ctx, Path(roundedRect: bodyR, cornerRadius: w * 0.1), lw)
            var shackle = Path()
            shackle.addArc(center: CGPoint(x: rect.midX, y: rect.midY - h * 0.04), radius: w * 0.22, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 0), clockwise: false)
            stroke(&ctx, shackle, lw)
            ctx.fill(Path(ellipseIn: CGRect(x: rect.midX - w * 0.05, y: rect.midY + h * 0.14, width: w * 0.1, height: w * 0.1)), with: .color(color))
        case .chevronRight:
            var p = Path()
            p.move(to: CGPoint(x: rect.minX + w * 0.3, y: rect.minY + h * 0.12))
            p.addLine(to: CGPoint(x: rect.maxX - w * 0.26, y: rect.midY))
            p.addLine(to: CGPoint(x: rect.minX + w * 0.3, y: rect.maxY - h * 0.12))
            stroke(&ctx, p, lw * 1.1)
        case .chevronDown:
            var p = Path()
            p.move(to: CGPoint(x: rect.minX + w * 0.12, y: rect.minY + h * 0.3))
            p.addLine(to: CGPoint(x: rect.midX, y: rect.maxY - h * 0.26))
            p.addLine(to: CGPoint(x: rect.maxX - w * 0.12, y: rect.minY + h * 0.3))
            stroke(&ctx, p, lw * 1.1)
        case .star:
            var star = Path()
            let c = CGPoint(x: rect.midX, y: rect.midY)
            for i in 0..<5 {
                let ang = CGFloat(i) * 2 * .pi / 5 - .pi / 2
                let pt = CGPoint(x: c.x + cos(ang) * w * 0.48, y: c.y + sin(ang) * w * 0.48)
                if i == 0 { star.move(to: pt) } else { star.addLine(to: pt) }
                let ang2 = ang + .pi / 5
                star.addLine(to: CGPoint(x: c.x + cos(ang2) * w * 0.20, y: c.y + sin(ang2) * w * 0.20))
            }
            star.closeSubpath()
            ctx.fill(star, with: .color(color))
        case .close:
            var p = Path()
            p.move(to: CGPoint(x: rect.minX + w * 0.14, y: rect.minY + h * 0.14))
            p.addLine(to: CGPoint(x: rect.maxX - w * 0.14, y: rect.maxY - h * 0.14))
            p.move(to: CGPoint(x: rect.maxX - w * 0.14, y: rect.minY + h * 0.14))
            p.addLine(to: CGPoint(x: rect.minX + w * 0.14, y: rect.maxY - h * 0.14))
            stroke(&ctx, p, lw * 1.1)
        case .plus:
            var p = Path()
            p.move(to: CGPoint(x: rect.midX, y: rect.minY + h * 0.1))
            p.addLine(to: CGPoint(x: rect.midX, y: rect.maxY - h * 0.1))
            p.move(to: CGPoint(x: rect.minX + w * 0.1, y: rect.midY))
            p.addLine(to: CGPoint(x: rect.maxX - w * 0.1, y: rect.midY))
            stroke(&ctx, p, lw * 1.1)
        case .flame:
            var p = Path()
            p.move(to: CGPoint(x: rect.midX, y: rect.minY))
            p.addQuadCurve(to: CGPoint(x: rect.maxX - w * 0.2, y: rect.maxY - h * 0.28), control: CGPoint(x: rect.maxX + w * 0.05, y: rect.midY - h * 0.1))
            p.addArc(center: CGPoint(x: rect.midX, y: rect.maxY - h * 0.28), radius: w * 0.3, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 180), clockwise: false)
            p.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.minY), control: CGPoint(x: rect.minX - w * 0.05, y: rect.midY - h * 0.1))
            stroke(&ctx, p, lw)
            var inner = Path()
            inner.addArc(center: CGPoint(x: rect.midX, y: rect.maxY - h * 0.3), radius: w * 0.13, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 360), clockwise: false)
            ctx.fill(inner, with: .color(color))
        case .wheatStalk:
            var stem = Path()
            stem.move(to: CGPoint(x: rect.midX, y: rect.maxY))
            stem.addLine(to: CGPoint(x: rect.midX, y: rect.minY + h * 0.14))
            stroke(&ctx, stem, lw * 0.9)
            for i in 0..<4 {
                let y = rect.minY + h * (0.2 + CGFloat(i) * 0.17)
                for side in [-1.0, 1.0] {
                    var grain = Path()
                    grain.addEllipse(in: CGRect(x: rect.midX + CGFloat(side) * w * 0.06 - (side < 0 ? w * 0.16 : 0), y: y, width: w * 0.16, height: h * 0.1))
                    stroke(&ctx, grain, lw * 0.7)
                }
            }
        case .whisk:
            var handle = Path()
            handle.move(to: CGPoint(x: rect.midX, y: rect.minY))
            handle.addLine(to: CGPoint(x: rect.midX, y: rect.minY + h * 0.3))
            stroke(&ctx, handle, lw * 1.2)
            for dx in [-0.18, 0.0, 0.18] {
                var loop = Path()
                loop.move(to: CGPoint(x: rect.midX, y: rect.minY + h * 0.3))
                loop.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.maxY), control: CGPoint(x: rect.midX + CGFloat(dx) * w * 2.4, y: rect.midY + h * 0.24))
                stroke(&ctx, loop, lw * 0.8)
            }
        case .timerGlass:
            var glass = Path()
            glass.move(to: CGPoint(x: rect.minX + w * 0.2, y: rect.minY))
            glass.addLine(to: CGPoint(x: rect.maxX - w * 0.2, y: rect.minY))
            glass.move(to: CGPoint(x: rect.minX + w * 0.2, y: rect.maxY))
            glass.addLine(to: CGPoint(x: rect.maxX - w * 0.2, y: rect.maxY))
            glass.move(to: CGPoint(x: rect.minX + w * 0.24, y: rect.minY))
            glass.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.midY), control: CGPoint(x: rect.minX + w * 0.24, y: rect.midY - h * 0.1))
            glass.addQuadCurve(to: CGPoint(x: rect.minX + w * 0.24, y: rect.maxY), control: CGPoint(x: rect.minX + w * 0.24, y: rect.midY + h * 0.1))
            glass.move(to: CGPoint(x: rect.maxX - w * 0.24, y: rect.minY))
            glass.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.midY), control: CGPoint(x: rect.maxX - w * 0.24, y: rect.midY - h * 0.1))
            glass.addQuadCurve(to: CGPoint(x: rect.maxX - w * 0.24, y: rect.maxY), control: CGPoint(x: rect.maxX - w * 0.24, y: rect.midY + h * 0.1))
            stroke(&ctx, glass, lw * 0.9)
            ctx.fill(Path(ellipseIn: CGRect(x: rect.midX - w * 0.07, y: rect.maxY - h * 0.24, width: w * 0.14, height: h * 0.14)), with: .color(color))
        case .ribbon:
            var band = Path()
            band.addRoundedRect(in: CGRect(x: rect.minX, y: rect.minY + h * 0.2, width: w, height: h * 0.32), cornerSize: CGSize(width: w * 0.06, height: w * 0.06))
            stroke(&ctx, band, lw)
            var tails = Path()
            tails.move(to: CGPoint(x: rect.midX - w * 0.16, y: rect.minY + h * 0.52))
            tails.addLine(to: CGPoint(x: rect.midX - w * 0.24, y: rect.maxY))
            tails.move(to: CGPoint(x: rect.midX + w * 0.16, y: rect.minY + h * 0.52))
            tails.addLine(to: CGPoint(x: rect.midX + w * 0.24, y: rect.maxY))
            stroke(&ctx, tails, lw)
        case .oven:
            let body = Path(roundedRect: rect, cornerRadius: w * 0.1)
            stroke(&ctx, body, lw)
            var door = Path()
            door.addRoundedRect(in: CGRect(x: rect.minX + w * 0.16, y: rect.minY + h * 0.3, width: w * 0.68, height: h * 0.5), cornerSize: CGSize(width: w * 0.06, height: w * 0.06))
            stroke(&ctx, door, lw * 0.9)
            var knobs = Path()
            for kx in [0.24, 0.44, 0.64] {
                knobs.addEllipse(in: CGRect(x: rect.minX + w * CGFloat(kx), y: rect.minY + h * 0.12, width: w * 0.09, height: w * 0.09))
            }
            ctx.fill(knobs, with: .color(color))
        case .knife:
            var blade = Path()
            blade.move(to: CGPoint(x: rect.minX, y: rect.maxY - h * 0.2))
            blade.addQuadCurve(to: CGPoint(x: rect.maxX - w * 0.3, y: rect.minY + h * 0.12), control: CGPoint(x: rect.minX + w * 0.3, y: rect.minY + h * 0.16))
            blade.addLine(to: CGPoint(x: rect.maxX - w * 0.22, y: rect.minY + h * 0.3))
            blade.addLine(to: CGPoint(x: rect.minX + w * 0.14, y: rect.maxY - h * 0.08))
            blade.closeSubpath()
            stroke(&ctx, blade, lw * 0.9)
            var handle = Path()
            handle.move(to: CGPoint(x: rect.maxX - w * 0.26, y: rect.minY + h * 0.2))
            handle.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + h * 0.4))
            stroke(&ctx, handle, lw * 1.5)
        case .drop:
            var p = Path()
            p.move(to: CGPoint(x: rect.midX, y: rect.minY))
            p.addQuadCurve(to: CGPoint(x: rect.maxX - w * 0.18, y: rect.maxY - h * 0.3), control: CGPoint(x: rect.maxX - w * 0.08, y: rect.midY))
            p.addArc(center: CGPoint(x: rect.midX, y: rect.maxY - h * 0.3), radius: w * 0.32, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 180), clockwise: false)
            p.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.minY), control: CGPoint(x: rect.minX + w * 0.08, y: rect.midY))
            stroke(&ctx, p, lw)
        case .sparkle:
            var p = Path()
            p.move(to: CGPoint(x: rect.midX, y: rect.minY))
            p.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.midY), control: CGPoint(x: rect.midX + w * 0.1, y: rect.midY - h * 0.1))
            p.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.maxY), control: CGPoint(x: rect.midX + w * 0.1, y: rect.midY + h * 0.1))
            p.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.midY), control: CGPoint(x: rect.midX - w * 0.1, y: rect.midY + h * 0.1))
            p.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.minY), control: CGPoint(x: rect.midX - w * 0.1, y: rect.midY - h * 0.1))
            ctx.fill(p, with: .color(color))
        }
    }
}
