import SwiftUI

enum DoughArtist {
    static func tintBase(_ tint: Int) -> (Color, Color) {
        switch tint {
        case 1: return (Color(red: 0.78, green: 0.68, blue: 0.55), Color(red: 0.62, green: 0.51, blue: 0.38))
        case 2: return (Color(red: 0.95, green: 0.88, blue: 0.72), Color(red: 0.86, green: 0.75, blue: 0.54))
        case 3: return (Color(red: 0.82, green: 0.72, blue: 0.60), Color(red: 0.48, green: 0.34, blue: 0.24))
        default: return (BakeTheme.doughPale, BakeTheme.doughShade)
        }
    }

    static func crustColor(_ crust: Double, tint: Int) -> Color {
        let stops: [(Double, (Double, Double, Double))] = [
            (0.0, (0.937, 0.894, 0.792)),
            (0.35, (0.902, 0.769, 0.541)),
            (0.55, (0.831, 0.612, 0.333)),
            (0.72, (0.671, 0.427, 0.188)),
            (0.85, (0.478, 0.278, 0.110)),
            (1.0, (0.247, 0.137, 0.063)),
        ]
        var lower = stops[0]
        var upper = stops[stops.count - 1]
        for i in 0..<(stops.count - 1) {
            if crust >= stops[i].0 && crust <= stops[i + 1].0 {
                lower = stops[i]
                upper = stops[i + 1]
                break
            }
        }
        let span = upper.0 - lower.0
        let t = span > 0 ? (crust - lower.0) / span : 0
        var r = lower.1.0 + (upper.1.0 - lower.1.0) * t
        var g = lower.1.1 + (upper.1.1 - lower.1.1) * t
        var b = lower.1.2 + (upper.1.2 - lower.1.2) * t
        if tint == 1 { r *= 0.82; g *= 0.78; b *= 0.8 }
        if tint == 3 { r *= 0.75; g *= 0.62; b *= 0.6 }
        return Color(red: r, green: g, blue: b)
    }

    static func blobPath(in rect: CGRect, roughness: CGFloat, seed: UInt64, lobes: Int = 10) -> Path {
        var rng = BakeSeededRandom(seed: seed)
        var pts: [CGPoint] = []
        let c = CGPoint(x: rect.midX, y: rect.midY)
        let rx = rect.width / 2
        let ry = rect.height / 2
        for i in 0..<lobes {
            let a = CGFloat(i) / CGFloat(lobes) * 2 * .pi
            let wobble = 1 - roughness * 0.5 + rng.next() * roughness
            pts.append(CGPoint(x: c.x + cos(a) * rx * wobble, y: c.y + sin(a) * ry * wobble))
        }
        var p = Path()
        guard pts.count > 2 else { return p }
        var mid = CGPoint(x: (pts[0].x + pts[pts.count - 1].x) / 2, y: (pts[0].y + pts[pts.count - 1].y) / 2)
        p.move(to: mid)
        for i in 0..<pts.count {
            let next = pts[(i + 1) % pts.count]
            mid = CGPoint(x: (pts[i].x + next.x) / 2, y: (pts[i].y + next.y) / 2)
            p.addQuadCurve(to: mid, control: pts[i])
        }
        p.closeSubpath()
        return p
    }

    static func drawDoughBall(_ ctx: inout GraphicsContext, rect: CGRect, tint: Int, smoothness: Double, phase: Double, seed: UInt64 = 11) {
        let (base, shade) = tintBase(tint)
        let rough = CGFloat((1 - smoothness).bakeClamped(0.02, 0.7)) * 0.34
        let squish = CGFloat(sin(phase * 2)) * 0.012
        let ballRect = rect.insetBy(dx: rect.width * 0.06, dy: rect.height * (0.10 - squish))
        ctx.fill(Path(ellipseIn: CGRect(x: rect.midX - rect.width * 0.36, y: rect.maxY - rect.height * 0.13, width: rect.width * 0.72, height: rect.height * 0.1)), with: .color(Color.black.opacity(0.12)))
        let blob = blobPath(in: ballRect, roughness: rough, seed: seed)
        ctx.fill(blob, with: .linearGradient(Gradient(colors: [base, shade]), startPoint: CGPoint(x: rect.midX, y: rect.minY), endPoint: CGPoint(x: rect.midX, y: rect.maxY)))
        ctx.stroke(blob, with: .color(BakeTheme.ink.opacity(0.35)), lineWidth: 1.6)
        if smoothness > 0.5 {
            let shine = Path(ellipseIn: CGRect(x: ballRect.minX + ballRect.width * 0.2, y: ballRect.minY + ballRect.height * 0.12, width: ballRect.width * 0.34, height: ballRect.height * 0.2))
            ctx.fill(shine, with: .color(Color.white.opacity(0.24 * (smoothness - 0.5) * 2)))
        }
        if smoothness < 0.45 {
            var rng = BakeSeededRandom(seed: seed &+ 5)
            for _ in 0..<7 {
                let fx = ballRect.minX + rng.next() * ballRect.width
                let fy = ballRect.minY + rng.next() * ballRect.height * 0.8
                var fleck = Path()
                fleck.move(to: CGPoint(x: fx, y: fy))
                fleck.addQuadCurve(to: CGPoint(x: fx + 8 + rng.next() * 8, y: fy + rng.next() * 6 - 3), control: CGPoint(x: fx + 6, y: fy - 4))
                ctx.stroke(fleck, with: .color(BakeTheme.ink.opacity(0.14)), lineWidth: 1.2)
            }
        }
    }

    static func drawProofBowl(_ ctx: inout GraphicsContext, rect: CGRect, ferment: Double, tint: Int, phase: Double) {
        let (base, shade) = tintBase(tint)
        let bowlRect = CGRect(x: rect.minX + rect.width * 0.08, y: rect.midY, width: rect.width * 0.84, height: rect.height * 0.42)
        let rise = CGFloat(ferment.bakeClamped(0, 1.15))
        let collapsed = ferment > 1.05
        let domeHeight = collapsed ? rect.height * 0.16 : rect.height * (0.06 + rise * 0.30)
        var dome = Path()
        dome.move(to: CGPoint(x: bowlRect.minX + 6, y: bowlRect.minY + 6))
        dome.addQuadCurve(to: CGPoint(x: bowlRect.maxX - 6, y: bowlRect.minY + 6), control: CGPoint(x: rect.midX, y: bowlRect.minY - domeHeight * 2))
        dome.closeSubpath()
        ctx.fill(dome, with: .linearGradient(Gradient(colors: [base, shade]), startPoint: CGPoint(x: rect.midX, y: bowlRect.minY - domeHeight * 2), endPoint: CGPoint(x: rect.midX, y: bowlRect.minY + 10)))
        ctx.stroke(dome, with: .color(BakeTheme.ink.opacity(0.3)), lineWidth: 1.4)
        if collapsed {
            var crack = Path()
            crack.move(to: CGPoint(x: rect.midX - bowlRect.width * 0.18, y: bowlRect.minY - domeHeight * 0.4))
            crack.addLine(to: CGPoint(x: rect.midX + bowlRect.width * 0.02, y: bowlRect.minY - domeHeight * 0.8))
            crack.addLine(to: CGPoint(x: rect.midX + bowlRect.width * 0.2, y: bowlRect.minY - domeHeight * 0.3))
            ctx.stroke(crack, with: .color(BakeTheme.ink.opacity(0.3)), lineWidth: 1.2)
        }
        if ferment > 0.5 && !collapsed {
            var rng = BakeSeededRandom(seed: 77)
            let count = Int((ferment - 0.4) * 12)
            for i in 0..<max(0, count) {
                let bx = bowlRect.minX + 14 + rng.next() * (bowlRect.width - 28)
                let wob = CGFloat(sin(phase * 2.4 + Double(i))) * 1.5
                let by = bowlRect.minY - domeHeight * (0.2 + rng.next() * 0.8) + wob
                let r = 1.6 + rng.next() * 2.6
                ctx.stroke(Path(ellipseIn: CGRect(x: bx - r, y: by - r, width: r * 2, height: r * 2)), with: .color(BakeTheme.ink.opacity(0.16)), lineWidth: 1)
            }
        }
        var bowl = Path()
        bowl.move(to: CGPoint(x: bowlRect.minX, y: bowlRect.minY))
        bowl.addCurve(to: CGPoint(x: bowlRect.maxX, y: bowlRect.minY), control1: CGPoint(x: bowlRect.minX + bowlRect.width * 0.1, y: bowlRect.maxY + bowlRect.height * 0.4), control2: CGPoint(x: bowlRect.maxX - bowlRect.width * 0.1, y: bowlRect.maxY + bowlRect.height * 0.4))
        bowl.closeSubpath()
        ctx.fill(bowl, with: .linearGradient(Gradient(colors: [BakeTheme.terracotta, BakeTheme.terraDeep]), startPoint: CGPoint(x: rect.midX, y: bowlRect.minY), endPoint: CGPoint(x: rect.midX, y: bowlRect.maxY + 20)))
        ctx.stroke(bowl, with: .color(BakeTheme.ink.opacity(0.4)), lineWidth: 1.6)
        var band = Path()
        band.move(to: CGPoint(x: bowlRect.minX + bowlRect.width * 0.06, y: bowlRect.minY + bowlRect.height * 0.34))
        band.addQuadCurve(to: CGPoint(x: bowlRect.maxX - bowlRect.width * 0.06, y: bowlRect.minY + bowlRect.height * 0.34), control: CGPoint(x: rect.midX, y: bowlRect.minY + bowlRect.height * 0.6))
        ctx.stroke(band, with: .color(BakeTheme.butter.opacity(0.7)), lineWidth: 3)
    }

    struct Slash {
        var from: CGPoint
        var to: CGPoint
    }

    static func loafOutline(shape: ShapeKind, in rect: CGRect, seed: UInt64) -> [Path] {
        var paths: [Path] = []
        switch shape {
        case .round:
            paths.append(blobPath(in: rect.insetBy(dx: rect.width * 0.12, dy: rect.height * 0.12), roughness: 0.05, seed: seed, lobes: 12))
        case .log:
            paths.append(Path(roundedRect: rect.insetBy(dx: rect.width * 0.14, dy: rect.height * 0.26), cornerRadius: rect.height * 0.22))
        case .sticks:
            for i in 0..<3 {
                let y = rect.minY + rect.height * (0.22 + CGFloat(i) * 0.24)
                paths.append(Path(roundedRect: CGRect(x: rect.minX + rect.width * 0.10, y: y, width: rect.width * 0.80, height: rect.height * 0.13), cornerRadius: rect.height * 0.07))
            }
        case .braid:
            let braidRect = rect.insetBy(dx: rect.width * 0.16, dy: rect.height * 0.26)
            let segments = 7
            for s in 0..<segments {
                let t = CGFloat(s) / CGFloat(segments - 1)
                let x = braidRect.minX + t * braidRect.width
                let offset = sin(t * .pi * 3) * braidRect.height * 0.24
                let r = braidRect.height * (0.34 - abs(t - 0.5) * 0.18)
                paths.append(Path(ellipseIn: CGRect(x: x - r, y: braidRect.midY + offset - r, width: r * 2, height: r * 2)))
            }
        case .twist:
            let twistRect = rect.insetBy(dx: rect.width * 0.16, dy: rect.height * 0.3)
            let segments = 8
            for s in 0..<segments {
                let t = CGFloat(s) / CGFloat(segments - 1)
                let x = twistRect.minX + t * twistRect.width
                let offA = sin(t * .pi * 2.5) * twistRect.height * 0.3
                let offB = -offA
                let r = twistRect.height * 0.28
                paths.append(Path(ellipseIn: CGRect(x: x - r, y: twistRect.midY + offA - r, width: r * 2, height: r * 2)))
                paths.append(Path(ellipseIn: CGRect(x: x - r, y: twistRect.midY + offB - r, width: r * 2, height: r * 2)))
            }
        case .dimple:
            paths.append(Path(roundedRect: rect.insetBy(dx: rect.width * 0.12, dy: rect.height * 0.16), cornerRadius: rect.width * 0.08))
        case .crescent:
            var p = Path()
            let c = CGPoint(x: rect.midX, y: rect.midY + rect.height * 0.1)
            p.addArc(center: c, radius: rect.width * 0.32, startAngle: Angle(degrees: 200), endAngle: Angle(degrees: -20), clockwise: false)
            p.addArc(center: CGPoint(x: c.x, y: c.y - rect.height * 0.14), radius: rect.width * 0.26, startAngle: Angle(degrees: -20), endAngle: Angle(degrees: 200), clockwise: true)
            p.closeSubpath()
            paths.append(p)
        case .star:
            var p = Path()
            let c = CGPoint(x: rect.midX, y: rect.midY)
            let rOut = min(rect.width, rect.height) * 0.42
            let rIn = rOut * 0.52
            for i in 0..<8 {
                let a = CGFloat(i) / 8 * 2 * .pi - .pi / 2
                let mid = a + .pi / 8
                if i == 0 { p.move(to: CGPoint(x: c.x + cos(a) * rOut, y: c.y + sin(a) * rOut)) } else { p.addLine(to: CGPoint(x: c.x + cos(a) * rOut, y: c.y + sin(a) * rOut)) }
                p.addQuadCurve(to: CGPoint(x: c.x + cos(a + .pi / 4) * rOut, y: c.y + sin(a + .pi / 4) * rOut), control: CGPoint(x: c.x + cos(mid) * rIn, y: c.y + sin(mid) * rIn))
            }
            p.closeSubpath()
            paths.append(p)
        }
        return paths
    }

    static func drawLoaf(_ ctx: inout GraphicsContext, rect: CGRect, shape: ShapeKind, tint: Int, crust: Double, slashes: [Slash], seed: UInt64 = 21, seeds topping: Bool = false) {
        let color = crustColor(crust, tint: tint)
        let dark = crustColor((crust + 0.18).bakeClamped(0, 1), tint: tint)
        let paths = loafOutline(shape: shape, in: rect, seed: seed)
        ctx.fill(Path(ellipseIn: CGRect(x: rect.midX - rect.width * 0.38, y: rect.maxY - rect.height * 0.12, width: rect.width * 0.76, height: rect.height * 0.09)), with: .color(Color.black.opacity(0.13)))
        for p in paths {
            ctx.fill(p, with: .linearGradient(Gradient(colors: [color, dark]), startPoint: CGPoint(x: rect.midX, y: rect.minY), endPoint: CGPoint(x: rect.midX, y: rect.maxY)))
            ctx.stroke(p, with: .color(BakeTheme.ink.opacity(0.4)), lineWidth: 1.4)
        }
        if shape == .dimple {
            var rng = BakeSeededRandom(seed: seed)
            let inner = rect.insetBy(dx: rect.width * 0.18, dy: rect.height * 0.24)
            for _ in 0..<12 {
                let dx = inner.minX + rng.next() * inner.width
                let dy = inner.minY + rng.next() * inner.height
                let r = rect.width * 0.028
                ctx.fill(Path(ellipseIn: CGRect(x: dx - r, y: dy - r, width: r * 2, height: r * 2)), with: .color(dark.opacity(0.8)))
                if rng.next() > 0.6 {
                    var sprig = Path()
                    sprig.move(to: CGPoint(x: dx + r, y: dy - r))
                    sprig.addLine(to: CGPoint(x: dx + r * 2.4, y: dy - r * 2.6))
                    ctx.stroke(sprig, with: .color(BakeTheme.sageDeep), lineWidth: 1.2)
                }
            }
        }
        for slash in slashes {
            var cut = Path()
            cut.move(to: slash.from)
            cut.addLine(to: slash.to)
            ctx.stroke(cut, with: .color(BakeTheme.doughPale), style: StrokeStyle(lineWidth: rect.width * 0.028, lineCap: .round))
            ctx.stroke(cut, with: .color(dark.opacity(0.7)), style: StrokeStyle(lineWidth: rect.width * 0.010, lineCap: .round))
        }
        if topping {
            var rng = BakeSeededRandom(seed: seed &+ 9)
            for p in paths {
                let box = p.boundingRect.insetBy(dx: 6, dy: 6)
                for _ in 0..<24 {
                    let sx = box.minX + rng.next() * box.width
                    let sy = box.minY + rng.next() * box.height
                    if p.contains(CGPoint(x: sx, y: sy)) {
                        ctx.fill(Path(ellipseIn: CGRect(x: sx, y: sy, width: 2.4, height: 1.6)), with: .color(rng.next() > 0.5 ? BakeTheme.flour : BakeTheme.ink.opacity(0.6)))
                    }
                }
            }
        }
        let shinePath = paths[0]
        let box = shinePath.boundingRect
        let shine = Path(ellipseIn: CGRect(x: box.minX + box.width * 0.2, y: box.minY + box.height * 0.1, width: box.width * 0.4, height: box.height * 0.16))
        ctx.fill(shine, with: .color(Color.white.opacity(0.18)))
    }

    static func drawCrumbSlice(_ ctx: inout GraphicsContext, rect: CGRect, spec: CrumbSpec, tint: Int, crust: Double, seed: UInt64 = 31) {
        let (base, shade) = tintBase(tint)
        let crustCol = crustColor(crust, tint: tint)
        var outer = Path()
        outer.addArc(center: CGPoint(x: rect.midX, y: rect.maxY - rect.height * 0.12), radius: rect.width * 0.42, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 0), clockwise: false)
        outer.closeSubpath()
        if spec.collapsed {
            outer = Path()
            outer.move(to: CGPoint(x: rect.midX - rect.width * 0.42, y: rect.maxY - rect.height * 0.12))
            outer.addQuadCurve(to: CGPoint(x: rect.midX + rect.width * 0.42, y: rect.maxY - rect.height * 0.12), control: CGPoint(x: rect.midX, y: rect.maxY - rect.height * 0.5))
            outer.closeSubpath()
        }
        ctx.fill(outer, with: .color(crustCol))
        ctx.stroke(outer, with: .color(BakeTheme.ink.opacity(0.4)), lineWidth: 1.6)
        var inner = outer
        inner = inner.applying(CGAffineTransform(translationX: rect.midX, y: rect.maxY - rect.height * 0.12).scaledBy(x: 0.9, y: 0.86).translatedBy(x: -rect.midX, y: -(rect.maxY - rect.height * 0.12)))
        ctx.fill(inner, with: .linearGradient(Gradient(colors: [base, shade.opacity(0.7)]), startPoint: CGPoint(x: rect.midX, y: rect.minY), endPoint: CGPoint(x: rect.midX, y: rect.maxY)))
        var rng = BakeSeededRandom(seed: seed)
        ctx.clip(to: inner)
        for _ in 0..<spec.bubbleCount {
            let a = rng.next() * 2 * .pi
            let rr = sqrt(rng.next())
            let bx = rect.midX + cos(a) * rr * rect.width * 0.36
            let by = (rect.maxY - rect.height * 0.12) - abs(sin(a)) * rr * rect.height * 0.3 - 4
            var r = (1.4 + rng.next() * 4.2) * spec.bubbleScale
            if rng.next() < spec.irregularity * 0.4 { r *= 1.9 }
            let bubble = Path(ellipseIn: CGRect(x: bx - r, y: by - r * (0.8 + rng.next() * 0.4), width: r * 2, height: r * (1.6 + rng.next() * 0.6)))
            ctx.fill(bubble, with: .color(shade.opacity(0.55 + Double(rng.next()) * 0.3)))
        }
        if tint == 3 {
            for _ in 0..<6 {
                let sx = rect.midX + (rng.next() - 0.5) * rect.width * 0.6
                let sy = rect.maxY - rect.height * (0.14 + rng.next() * 0.3)
                var swirl = Path()
                swirl.move(to: CGPoint(x: sx - 20, y: sy))
                swirl.addQuadCurve(to: CGPoint(x: sx + 20, y: sy - 6), control: CGPoint(x: sx, y: sy - 16))
                ctx.stroke(swirl, with: .color(Color(red: 0.28, green: 0.18, blue: 0.12).opacity(0.8)), lineWidth: 4)
            }
        }
    }
}
