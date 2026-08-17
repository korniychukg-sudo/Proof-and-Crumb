import Foundation
import CoreGraphics
import CoreText
import ImageIO
import UniformTypeIdentifiers

let outDir = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "./out"
try? FileManager.default.createDirectory(atPath: outDir, withIntermediateDirectories: true)

struct RGB {
    var r: CGFloat
    var g: CGFloat
    var b: CGFloat
    func cg(_ a: CGFloat = 1) -> CGColor { CGColor(red: r, green: g, blue: b, alpha: a) }
    func mix(_ o: RGB, _ t: CGFloat) -> RGB { RGB(r: r + (o.r - r) * t, g: g + (o.g - g) * t, b: b + (o.b - b) * t) }
    func darker(_ t: CGFloat) -> RGB { mix(RGB(r: 0.08, g: 0.06, b: 0.05), t) }
    func lighter(_ t: CGFloat) -> RGB { mix(RGB(r: 0.99, g: 0.97, b: 0.93), t) }
}

let paperTone = RGB(r: 0.965, g: 0.930, b: 0.850)
let paperEdge = RGB(r: 0.90, g: 0.85, b: 0.76)
let inkTone = RGB(r: 0.20, g: 0.16, b: 0.12)
let brassTone = RGB(r: 0.78, g: 0.63, b: 0.30)
let pineTone = RGB(r: 0.48, g: 0.56, b: 0.42)
let redTone = RGB(r: 0.73, g: 0.42, b: 0.25)
let steelTone = RGB(r: 0.45, g: 0.43, b: 0.40)
let grassTone = RGB(r: 0.55, g: 0.64, b: 0.40)
let skyTone = RGB(r: 0.80, g: 0.85, b: 0.82)

final class Rand {
    var state: UInt64
    init(_ seed: UInt64) { state = seed &* 2862933555777941757 &+ 3037000493 }
    func next() -> CGFloat {
        state = state &* 2862933555777941757 &+ 3037000493
        return CGFloat((state >> 33) & 0xFFFFFF) / CGFloat(0xFFFFFF)
    }
    func range(_ lo: CGFloat, _ hi: CGFloat) -> CGFloat { lo + next() * (hi - lo) }
    func int(_ n: Int) -> Int { n <= 0 ? 0 : min(n - 1, Int(next() * CGFloat(n))) }
}

let renderScale: CGFloat = 1.7

func makeContext(_ w: Int, _ h: Int) -> CGContext {
    let cs = CGColorSpace(name: CGColorSpace.sRGB)!
    let pw = Int(CGFloat(w) * renderScale)
    let ph = Int(CGFloat(h) * renderScale)
    let ctx = CGContext(data: nil, width: pw, height: ph, bitsPerComponent: 8, bytesPerRow: 0, space: cs, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
    ctx.setAllowsAntialiasing(true)
    ctx.interpolationQuality = .high
    ctx.scaleBy(x: renderScale, y: renderScale)
    return ctx
}

func saveJPEG(_ ctx: CGContext, _ name: String, quality: CGFloat = 0.90) {
    let img = ctx.makeImage()!
    let url = URL(fileURLWithPath: "\(outDir)/\(name).jpg") as CFURL
    let dest = CGImageDestinationCreateWithURL(url, UTType.jpeg.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(dest, img, [kCGImageDestinationLossyCompressionQuality: quality] as CFDictionary)
    CGImageDestinationFinalize(dest)
    print("wrote \(name).jpg \(ctx.width)x\(ctx.height)")
}

func savePNG(_ ctx: CGContext, _ path: String) {
    let img = ctx.makeImage()!
    let url = URL(fileURLWithPath: path) as CFURL
    let dest = CGImageDestinationCreateWithURL(url, UTType.png.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(dest, img, nil)
    CGImageDestinationFinalize(dest)
    print("wrote \(path)")
}

func drawText(_ ctx: CGContext, _ text: String, font: String, size: CGFloat, at p: CGPoint, color: CGColor, centered: Bool = true, tracking: CGFloat = 0) {
    let ctFont = CTFontCreateWithName(font as CFString, size, nil)
    let attrs: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key(kCTFontAttributeName as String): ctFont,
        NSAttributedString.Key(kCTForegroundColorAttributeName as String): color,
        NSAttributedString.Key(kCTKernAttributeName as String): tracking,
    ]
    let str = NSAttributedString(string: text, attributes: attrs)
    let line = CTLineCreateWithAttributedString(str)
    let bounds = CTLineGetBoundsWithOptions(line, .useOpticalBounds)
    ctx.saveGState()
    ctx.textPosition = CGPoint(x: centered ? p.x - bounds.width / 2 : p.x, y: p.y)
    CTLineDraw(line, ctx)
    ctx.restoreGState()
}

func paperBase(_ ctx: CGContext, _ w: CGFloat, _ h: CGFloat, seed: UInt64, tone: RGB = paperTone) {
    let rand = Rand(seed)
    ctx.setFillColor(tone.cg())
    ctx.fill(CGRect(x: 0, y: 0, width: w, height: h))
    let grad = CGGradient(colorsSpace: nil, colors: [tone.lighter(0.05).cg(), tone.cg(), paperEdge.cg()] as CFArray, locations: [0, 0.55, 1])!
    ctx.saveGState()
    ctx.drawRadialGradient(grad, startCenter: CGPoint(x: w * 0.5, y: h * 0.6), startRadius: 0, endCenter: CGPoint(x: w * 0.5, y: h * 0.5), endRadius: max(w, h) * 0.75, options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
    ctx.restoreGState()
    for _ in 0..<2200 {
        let x = rand.next() * w
        let y = rand.next() * h
        let len = rand.range(2, 9)
        let ang = rand.next() * .pi
        ctx.setStrokeColor(inkTone.cg(rand.range(0.015, 0.05)))
        ctx.setLineWidth(rand.range(0.5, 1.1))
        ctx.move(to: CGPoint(x: x, y: y))
        ctx.addLine(to: CGPoint(x: x + cos(ang) * len, y: y + sin(ang) * len))
        ctx.strokePath()
    }
    for _ in 0..<44 {
        let x = rand.next() * w
        let y = rand.next() * h
        let r = rand.range(6, 42)
        ctx.setFillColor(RGB(r: 0.72, g: 0.62, b: 0.45).cg(rand.range(0.02, 0.06)))
        ctx.fillEllipse(in: CGRect(x: x - r, y: y - r * 0.7, width: r * 2, height: r * 1.4))
    }
    for _ in 0..<Int(w * h / 70) {
        let x = rand.next() * w
        let y = rand.next() * h
        let d = rand.range(0.5, 1.3)
        ctx.setFillColor(inkTone.cg(rand.range(0.015, 0.045)))
        ctx.fill(CGRect(x: x, y: y, width: d, height: d))
    }
}

func plateFrame(_ ctx: CGContext, _ w: CGFloat, _ h: CGFloat, inset: CGFloat) {
    let outer = CGRect(x: inset, y: inset, width: w - inset * 2, height: h - inset * 2)
    ctx.setStrokeColor(inkTone.cg(0.75))
    ctx.setLineWidth(3)
    ctx.stroke(outer)
    ctx.setLineWidth(1.2)
    ctx.stroke(outer.insetBy(dx: 9, dy: 9))
    let corners = [
        CGPoint(x: outer.minX, y: outer.minY), CGPoint(x: outer.maxX, y: outer.minY),
        CGPoint(x: outer.minX, y: outer.maxY), CGPoint(x: outer.maxX, y: outer.maxY),
    ]
    for c in corners {
        ctx.setFillColor(inkTone.cg(0.8))
        let d: CGFloat = 7
        ctx.saveGState()
        ctx.translateBy(x: c.x, y: c.y)
        ctx.rotate(by: .pi / 4)
        ctx.fill(CGRect(x: -d / 2, y: -d / 2, width: d, height: d))
        ctx.restoreGState()
    }
}

func wobblyLine(_ ctx: CGContext, from a: CGPoint, to b: CGPoint, rand: Rand, width: CGFloat, color: CGColor, wobble: CGFloat = 1.4) {
    let steps = max(3, Int(hypot(b.x - a.x, b.y - a.y) / 26))
    ctx.setStrokeColor(color)
    ctx.setLineWidth(width)
    ctx.setLineCap(.round)
    ctx.move(to: a)
    for i in 1...steps {
        let t = CGFloat(i) / CGFloat(steps)
        let px = a.x + (b.x - a.x) * t + rand.range(-wobble, wobble)
        let py = a.y + (b.y - a.y) * t + rand.range(-wobble, wobble)
        ctx.addLine(to: CGPoint(x: px, y: py))
    }
    ctx.strokePath()
}

func inkRect(_ ctx: CGContext, _ rect: CGRect, rand: Rand, width: CGFloat = 2.4, color: CGColor = inkTone.cg(0.85)) {
    wobblyLine(ctx, from: CGPoint(x: rect.minX, y: rect.minY), to: CGPoint(x: rect.maxX, y: rect.minY), rand: rand, width: width, color: color)
    wobblyLine(ctx, from: CGPoint(x: rect.maxX, y: rect.minY), to: CGPoint(x: rect.maxX, y: rect.maxY), rand: rand, width: width, color: color)
    wobblyLine(ctx, from: CGPoint(x: rect.maxX, y: rect.maxY), to: CGPoint(x: rect.minX, y: rect.maxY), rand: rand, width: width, color: color)
    wobblyLine(ctx, from: CGPoint(x: rect.minX, y: rect.maxY), to: CGPoint(x: rect.minX, y: rect.minY), rand: rand, width: width, color: color)
}

func hatchRect(_ ctx: CGContext, _ rect: CGRect, rand: Rand, angle: CGFloat = -0.7, gap: CGFloat = 7, alpha: CGFloat = 0.28, width: CGFloat = 1.1) {
    ctx.saveGState()
    ctx.clip(to: rect)
    let diag = hypot(rect.width, rect.height)
    let n = Int(diag / gap) + 2
    let cx = rect.midX
    let cy = rect.midY
    let dirX = cos(angle)
    let dirY = sin(angle)
    let perpX = -dirY
    let perpY = dirX
    for i in -n...n {
        let off = CGFloat(i) * gap + rand.range(-1, 1)
        let baseX = cx + perpX * off
        let baseY = cy + perpY * off
        ctx.setStrokeColor(inkTone.cg(alpha * rand.range(0.7, 1.0)))
        ctx.setLineWidth(width)
        ctx.move(to: CGPoint(x: baseX - dirX * diag, y: baseY - dirY * diag))
        ctx.addLine(to: CGPoint(x: baseX + dirX * diag, y: baseY + dirY * diag))
        ctx.strokePath()
    }
    ctx.restoreGState()
}

func hatchPath(_ ctx: CGContext, _ path: CGPath, rand: Rand, angle: CGFloat = -0.7, gap: CGFloat = 7, alpha: CGFloat = 0.28, width: CGFloat = 1.1) {
    ctx.saveGState()
    ctx.addPath(path)
    ctx.clip()
    let rect = path.boundingBox
    let diag = hypot(rect.width, rect.height)
    let n = Int(diag / gap) + 2
    let dirX = cos(angle)
    let dirY = sin(angle)
    let perpX = -dirY
    let perpY = dirX
    for i in -n...n {
        let off = CGFloat(i) * gap + rand.range(-1, 1)
        let baseX = rect.midX + perpX * off
        let baseY = rect.midY + perpY * off
        ctx.setStrokeColor(inkTone.cg(alpha * rand.range(0.7, 1.0)))
        ctx.setLineWidth(width)
        ctx.move(to: CGPoint(x: baseX - dirX * diag, y: baseY - dirY * diag))
        ctx.addLine(to: CGPoint(x: baseX + dirX * diag, y: baseY + dirY * diag))
        ctx.strokePath()
    }
    ctx.restoreGState()
}

func groundShadow(_ ctx: CGContext, cx: CGFloat, y: CGFloat, w: CGFloat, rand: Rand) {
    let rect = CGRect(x: cx - w / 2, y: y - 14, width: w, height: 24)
    hatchRect(ctx, rect, rand: rand, angle: 0.05, gap: 5, alpha: 0.20, width: 1.0)
}

struct Livery {
    var body: RGB
    var roof: RGB
    var accent: RGB
}

func washFill(_ ctx: CGContext, _ path: CGPath, _ color: RGB, rand: Rand, alpha: CGFloat = 0.85) {
    ctx.saveGState()
    ctx.addPath(path)
    ctx.clip()
    let box = path.boundingBox
    ctx.setFillColor(color.cg(alpha))
    ctx.fill(box)
    let grad = CGGradient(colorsSpace: nil, colors: [color.lighter(0.25).cg(0.55), color.cg(0.0), color.darker(0.3).cg(0.45)] as CFArray, locations: [0, 0.5, 1])!
    ctx.drawLinearGradient(grad, start: CGPoint(x: box.minX, y: box.maxY), end: CGPoint(x: box.minX, y: box.minY), options: [])
    for _ in 0..<Int(box.width * box.height / 2400) {
        let x = box.minX + rand.next() * box.width
        let y = box.minY + rand.next() * box.height
        ctx.setFillColor(color.darker(0.35).cg(rand.range(0.03, 0.10)))
        ctx.fillEllipse(in: CGRect(x: x, y: y, width: rand.range(2, 7), height: rand.range(2, 5)))
    }
    ctx.restoreGState()
}

func rrect(_ r: CGRect, _ rad: CGFloat) -> CGPath {
    CGPath(roundedRect: r, cornerWidth: min(rad, r.width / 2), cornerHeight: min(rad, r.height / 2), transform: nil)
}

let doughPale = RGB(r: 0.937, g: 0.894, b: 0.792)
let doughShade = RGB(r: 0.851, g: 0.784, b: 0.647)
let butterTone = RGB(r: 0.949, g: 0.867, b: 0.639)
let wheatTone = RGB(r: 0.851, g: 0.643, b: 0.255)
let crustGold = RGB(r: 0.831, g: 0.612, b: 0.333)
let crustDeep = RGB(r: 0.671, g: 0.427, b: 0.188)
let crustBold = RGB(r: 0.478, g: 0.278, b: 0.110)
let sageTone = RGB(r: 0.478, g: 0.557, b: 0.416)
let terraTone = RGB(r: 0.725, g: 0.420, b: 0.247)
let chocTone = RGB(r: 0.28, g: 0.18, b: 0.12)

func titleBlock(_ ctx: CGContext, w: CGFloat, name: String, sub: String, y: CGFloat = 92) {
    drawText(ctx, name.uppercased(), font: "Georgia-Bold", size: 54, at: CGPoint(x: w / 2, y: y + 34), color: inkTone.cg(0.92), tracking: 5)
    drawText(ctx, sub, font: "Georgia-Italic", size: 30, at: CGPoint(x: w / 2, y: y - 14), color: inkTone.cg(0.62))
    let rand = Rand(9)
    wobblyLine(ctx, from: CGPoint(x: w / 2 - 260, y: y + 12), to: CGPoint(x: w / 2 - 190, y: y + 12), rand: rand, width: 1.6, color: inkTone.cg(0.5))
    wobblyLine(ctx, from: CGPoint(x: w / 2 + 190, y: y + 12), to: CGPoint(x: w / 2 + 260, y: y + 12), rand: rand, width: 1.6, color: inkTone.cg(0.5))
    ctx.setFillColor(wheatTone.cg(0.9))
    ctx.fillEllipse(in: CGRect(x: w / 2 - 174, y: y + 8, width: 9, height: 9))
    ctx.fillEllipse(in: CGRect(x: w / 2 + 165, y: y + 8, width: 9, height: 9))
}

func flourDust(_ ctx: CGContext, around rect: CGRect, rand: Rand, count: Int = 40) {
    for _ in 0..<count {
        let x = rect.minX - 40 + rand.next() * (rect.width + 80)
        let y = rect.minY - 30 + rand.next() * 60
        let r = rand.range(1.5, 4.5)
        ctx.setFillColor(RGB(r: 0.99, g: 0.98, b: 0.95).cg(rand.range(0.4, 0.85)))
        ctx.fillEllipse(in: CGRect(x: x, y: y, width: r, height: r * 0.8))
    }
}

func boardLine(_ ctx: CGContext, y: CGFloat, w: CGFloat, rand: Rand) {
    let board = CGRect(x: 130, y: y - 26, width: w - 260, height: 30)
    washFill(ctx, rrect(board, 8), RGB(r: 0.62, g: 0.46, b: 0.30), rand: rand)
    inkRect(ctx, board, rand: rand, width: 2.6)
    for _ in 0..<5 {
        let gy = board.minY + rand.range(6, 22)
        wobblyLine(ctx, from: CGPoint(x: board.minX + 12, y: gy), to: CGPoint(x: board.maxX - 12, y: gy), rand: rand, width: 1, color: inkTone.cg(0.16), wobble: 0.8)
    }
}

func wheatSprig(_ ctx: CGContext, at p: CGPoint, angle: CGFloat, len: CGFloat, rand: Rand) {
    ctx.saveGState()
    ctx.translateBy(x: p.x, y: p.y)
    ctx.rotate(by: angle)
    ctx.setStrokeColor(wheatTone.darker(0.15).cg(0.9))
    ctx.setLineWidth(3)
    ctx.move(to: .zero)
    ctx.addLine(to: CGPoint(x: 0, y: len))
    ctx.strokePath()
    for i in 0..<6 {
        let gy = len * (0.4 + CGFloat(i) * 0.1)
        for side in [-1.0, 1.0] {
            let grain = CGMutablePath()
            grain.addEllipse(in: CGRect(x: CGFloat(side) * 4 - (side < 0 ? 16 : 0), y: gy, width: 16, height: 9))
            ctx.addPath(grain)
            ctx.setFillColor(wheatTone.cg(0.85))
            ctx.fillPath()
            ctx.addPath(grain)
            ctx.setStrokeColor(inkTone.cg(0.5))
            ctx.setLineWidth(1.2)
            ctx.strokePath()
        }
    }
    ctx.restoreGState()
}

func slashMark(_ ctx: CGContext, from a: CGPoint, to b: CGPoint, rand: Rand, width: CGFloat = 7) {
    wobblyLine(ctx, from: a, to: b, rand: rand, width: width, color: doughPale.cg(0.95), wobble: 0.8)
    wobblyLine(ctx, from: a, to: b, rand: rand, width: width * 0.4, color: crustDeep.cg(0.7), wobble: 0.8)
}

func steamCurl(_ ctx: CGContext, from p: CGPoint, rand: Rand, count: Int = 3) {
    for i in 0..<count {
        let x0 = p.x + CGFloat(i - 1) * 36 + rand.range(-8, 8)
        let curl = CGMutablePath()
        curl.move(to: CGPoint(x: x0, y: p.y))
        curl.addCurve(to: CGPoint(x: x0 + 14, y: p.y + 90 + rand.range(0, 30)),
                      control1: CGPoint(x: x0 - 26, y: p.y + 34),
                      control2: CGPoint(x: x0 + 40, y: p.y + 60))
        ctx.addPath(curl)
        ctx.setStrokeColor(inkTone.cg(rand.range(0.22, 0.36)))
        ctx.setLineWidth(2.6)
        ctx.setLineCap(.round)
        ctx.strokePath()
    }
}

func drawBoule(_ ctx: CGContext, cx: CGFloat, baseY: CGFloat, wdt: CGFloat, crust: RGB, rand: Rand, slashes: Int = 1, ear: Bool = false) {
    groundShadow(ctx, cx: cx, y: baseY - 6, w: wdt * 1.1, rand: rand)
    let dome = CGMutablePath()
    dome.move(to: CGPoint(x: cx - wdt / 2, y: baseY))
    dome.addCurve(to: CGPoint(x: cx + wdt / 2, y: baseY),
                  control1: CGPoint(x: cx - wdt * 0.52, y: baseY + wdt * 0.72),
                  control2: CGPoint(x: cx + wdt * 0.52, y: baseY + wdt * 0.72))
    dome.closeSubpath()
    washFill(ctx, dome, crust, rand: rand)
    ctx.addPath(dome)
    ctx.setStrokeColor(inkTone.cg(0.9))
    ctx.setLineWidth(3.4)
    ctx.strokePath()
    hatchPath(ctx, dome, rand: rand, angle: -0.6, gap: 9, alpha: 0.14)
    let shine = CGMutablePath()
    shine.addEllipse(in: CGRect(x: cx - wdt * 0.26, y: baseY + wdt * 0.34, width: wdt * 0.34, height: wdt * 0.14))
    ctx.addPath(shine)
    ctx.setFillColor(RGB(r: 1, g: 0.95, b: 0.85).cg(0.25))
    ctx.fillPath()
    if slashes == 1 {
        slashMark(ctx, from: CGPoint(x: cx - wdt * 0.26, y: baseY + wdt * 0.30), to: CGPoint(x: cx + wdt * 0.26, y: baseY + wdt * 0.44), rand: rand, width: 9)
        if ear {
            let earP = CGMutablePath()
            earP.move(to: CGPoint(x: cx - wdt * 0.24, y: baseY + wdt * 0.33))
            earP.addQuadCurve(to: CGPoint(x: cx + wdt * 0.24, y: baseY + wdt * 0.47), control: CGPoint(x: cx, y: baseY + wdt * 0.56))
            ctx.addPath(earP)
            ctx.setStrokeColor(crustBold.cg(0.9))
            ctx.setLineWidth(5)
            ctx.strokePath()
        }
    } else if slashes > 1 {
        for i in 0..<slashes {
            let t = CGFloat(i) / CGFloat(max(1, slashes - 1)) - 0.5
            slashMark(ctx, from: CGPoint(x: cx + t * wdt * 0.5 - wdt * 0.08, y: baseY + wdt * 0.24), to: CGPoint(x: cx + t * wdt * 0.5 + wdt * 0.08, y: baseY + wdt * 0.44), rand: rand, width: 6)
        }
    }
    flourDust(ctx, around: CGRect(x: cx - wdt / 2, y: baseY - 20, width: wdt, height: 30), rand: rand, count: 26)
}

func drawTinLoaf(_ ctx: CGContext, cx: CGFloat, baseY: CGFloat, wdt: CGFloat, crust: RGB, rand: Rand) {
    groundShadow(ctx, cx: cx, y: baseY - 6, w: wdt * 1.15, rand: rand)
    let tin = CGRect(x: cx - wdt / 2, y: baseY, width: wdt, height: wdt * 0.34)
    washFill(ctx, rrect(tin, 8), steelTone.lighter(0.2), rand: rand)
    inkRect(ctx, tin, rand: rand, width: 2.8)
    let top = CGMutablePath()
    top.move(to: CGPoint(x: tin.minX + 4, y: tin.maxY))
    top.addCurve(to: CGPoint(x: cx, y: tin.maxY + wdt * 0.30), control1: CGPoint(x: tin.minX - 10, y: tin.maxY + wdt * 0.26), control2: CGPoint(x: cx - wdt * 0.2, y: tin.maxY + wdt * 0.30))
    top.addCurve(to: CGPoint(x: tin.maxX - 4, y: tin.maxY), control1: CGPoint(x: cx + wdt * 0.2, y: tin.maxY + wdt * 0.30), control2: CGPoint(x: tin.maxX + 10, y: tin.maxY + wdt * 0.26))
    top.closeSubpath()
    washFill(ctx, top, crust, rand: rand)
    ctx.addPath(top)
    ctx.setStrokeColor(inkTone.cg(0.9))
    ctx.setLineWidth(3.2)
    ctx.strokePath()
    hatchPath(ctx, top, rand: rand, angle: -0.6, gap: 9, alpha: 0.13)
}

struct BakePlateSpec {
    var id: String
    var name: String
    var sub: String
    var seed: UInt64
}

func drawBakePlate(_ spec: BakePlateSpec) {
    let W = 1400, H = 1000
    let w = CGFloat(W), h = CGFloat(H)
    let ctx = makeContext(W, H)
    let rand = Rand(spec.seed)
    paperBase(ctx, w, h, seed: spec.seed)
    plateFrame(ctx, w, h, inset: 44)
    let baseY: CGFloat = 300
    boardLine(ctx, y: baseY - 18, w: w, rand: rand)
    let cx = w / 2

    switch spec.id {
    case "tinloaf":
        drawTinLoaf(ctx, cx: cx, baseY: baseY, wdt: 520, crust: crustGold, rand: rand)
        steamCurl(ctx, from: CGPoint(x: cx, y: baseY + 340), rand: rand)
    case "boule":
        drawBoule(ctx, cx: cx, baseY: baseY, wdt: 480, crust: crustDeep, rand: rand, slashes: 1, ear: true)
        steamCurl(ctx, from: CGPoint(x: cx, y: baseY + 380), rand: rand)
        wheatSprig(ctx, at: CGPoint(x: cx - 360, y: baseY + 10), angle: -0.3, len: 150, rand: rand)
    case "baguette":
        groundShadow(ctx, cx: cx, y: baseY - 6, w: 760, rand: rand)
        for i in 0..<3 {
            let off = CGFloat(i - 1) * 120
            ctx.saveGState()
            ctx.translateBy(x: cx + off, y: baseY + 60)
            ctx.rotate(by: 0.5)
            let stick = rrect(CGRect(x: -360, y: -52, width: 720, height: 104), 52)
            washFill(ctx, stick, i == 1 ? crustDeep : crustGold, rand: rand)
            ctx.addPath(stick)
            ctx.setStrokeColor(inkTone.cg(0.9))
            ctx.setLineWidth(3)
            ctx.strokePath()
            for k in 0..<4 {
                let sx = -260 + CGFloat(k) * 170
                slashMark(ctx, from: CGPoint(x: sx, y: -18), to: CGPoint(x: sx + 120, y: 20), rand: rand, width: 6)
            }
            ctx.restoreGState()
        }
    case "rolls":
        groundShadow(ctx, cx: cx, y: baseY - 6, w: 620, rand: rand)
        let tray = CGRect(x: cx - 320, y: baseY - 6, width: 640, height: 26)
        washFill(ctx, rrect(tray, 6), steelTone.lighter(0.15), rand: rand)
        inkRect(ctx, tray, rand: rand, width: 2.4)
        for row in 0..<2 {
            for col in 0..<3 {
                let rx = cx - 190 + CGFloat(col) * 190
                let ry = baseY + 30 + CGFloat(row) * 140
                let dome = CGMutablePath()
                dome.addArc(center: CGPoint(x: rx, y: ry), radius: 96, startAngle: .pi, endAngle: 0, clockwise: true)
                dome.closeSubpath()
                washFill(ctx, dome, row == 0 ? crustGold : crustGold.lighter(0.12), rand: rand)
                ctx.addPath(dome)
                ctx.setStrokeColor(inkTone.cg(0.85))
                ctx.setLineWidth(2.8)
                ctx.strokePath()
                ctx.setFillColor(RGB(r: 1, g: 0.96, b: 0.86).cg(0.3))
                ctx.fillEllipse(in: CGRect(x: rx - 40, y: ry + 40, width: 52, height: 22))
            }
        }
    case "rye":
        groundShadow(ctx, cx: cx, y: baseY - 6, w: 600, rand: rand)
        let loaf = CGMutablePath()
        loaf.move(to: CGPoint(x: cx - 290, y: baseY))
        loaf.addCurve(to: CGPoint(x: cx + 290, y: baseY), control1: CGPoint(x: cx - 310, y: baseY + 240), control2: CGPoint(x: cx + 310, y: baseY + 240))
        loaf.closeSubpath()
        washFill(ctx, loaf, crustBold, rand: rand)
        ctx.addPath(loaf)
        ctx.setStrokeColor(inkTone.cg(0.9))
        ctx.setLineWidth(3.4)
        ctx.strokePath()
        for i in 0..<3 {
            let sx = cx - 130 + CGFloat(i) * 130
            slashMark(ctx, from: CGPoint(x: sx - 40, y: baseY + 110), to: CGPoint(x: sx + 40, y: baseY + 150), rand: rand, width: 7)
        }
        flourDust(ctx, around: CGRect(x: cx - 280, y: baseY + 140, width: 560, height: 60), rand: rand, count: 50)
    case "brioche":
        groundShadow(ctx, cx: cx, y: baseY - 6, w: 400, rand: rand)
        let base = CGMutablePath()
        base.move(to: CGPoint(x: cx - 190, y: baseY))
        base.addCurve(to: CGPoint(x: cx - 150, y: baseY + 190), control1: CGPoint(x: cx - 230, y: baseY + 90), control2: CGPoint(x: cx - 210, y: baseY + 170))
        base.addCurve(to: CGPoint(x: cx + 150, y: baseY + 190), control1: CGPoint(x: cx - 60, y: baseY + 230), control2: CGPoint(x: cx + 60, y: baseY + 230))
        base.addCurve(to: CGPoint(x: cx + 190, y: baseY), control1: CGPoint(x: cx + 210, y: baseY + 170), control2: CGPoint(x: cx + 230, y: baseY + 90))
        base.closeSubpath()
        washFill(ctx, base, crustGold, rand: rand)
        ctx.addPath(base)
        ctx.setStrokeColor(inkTone.cg(0.9))
        ctx.setLineWidth(3.2)
        ctx.strokePath()
        for i in 0..<5 {
            let fx = cx - 150 + CGFloat(i) * 75
            wobblyLine(ctx, from: CGPoint(x: fx, y: baseY + 16), to: CGPoint(x: fx + 18, y: baseY + 130), rand: rand, width: 2.2, color: inkTone.cg(0.35))
        }
        let knot = CGMutablePath()
        knot.addEllipse(in: CGRect(x: cx - 95, y: baseY + 160, width: 190, height: 150))
        washFill(ctx, knot, crustGold.lighter(0.12), rand: rand)
        ctx.addPath(knot)
        ctx.setStrokeColor(inkTone.cg(0.9))
        ctx.setLineWidth(3)
        ctx.strokePath()
        ctx.setFillColor(RGB(r: 1, g: 0.96, b: 0.86).cg(0.3))
        ctx.fillEllipse(in: CGRect(x: cx - 60, y: baseY + 240, width: 70, height: 30))
    case "challah":
        groundShadow(ctx, cx: cx, y: baseY - 6, w: 700, rand: rand)
        var t: CGFloat = 0
        while t <= 1 {
            let x = cx - 330 + t * 660
            let bump = sin(t * .pi)
            let r = 62 + bump * 40
            let yOff = sin(t * .pi * 5) * 26
            let strand = CGMutablePath()
            strand.addEllipse(in: CGRect(x: x - r, y: baseY + 40 + yOff - r * 0.8, width: r * 2, height: r * 1.6))
            washFill(ctx, strand, (Int(t * 10) % 2 == 0) ? crustGold : crustGold.lighter(0.1), rand: rand)
            ctx.addPath(strand)
            ctx.setStrokeColor(inkTone.cg(0.85))
            ctx.setLineWidth(2.8)
            ctx.strokePath()
            t += 0.09
        }
        ctx.setFillColor(RGB(r: 1, g: 0.96, b: 0.86).cg(0.22))
        ctx.fillEllipse(in: CGRect(x: cx - 220, y: baseY + 90, width: 300, height: 40))
    case "cinnamon":
        groundShadow(ctx, cx: cx, y: baseY - 6, w: 560, rand: rand)
        let slice = CGMutablePath()
        slice.addRoundedRect(in: CGRect(x: cx + 60, y: baseY + 6, width: 240, height: 260), cornerWidth: 40, cornerHeight: 40)
        washFill(ctx, slice, doughPale, rand: rand)
        ctx.addPath(slice)
        ctx.setStrokeColor(inkTone.cg(0.9))
        ctx.setLineWidth(3)
        ctx.strokePath()
        var swirlR: CGFloat = 12
        let swirlC = CGPoint(x: cx + 180, y: baseY + 136)
        ctx.setStrokeColor(RGB(r: 0.55, g: 0.32, b: 0.16).cg(0.9))
        ctx.setLineWidth(9)
        var a: CGFloat = 0
        ctx.move(to: swirlC)
        while swirlR < 100 {
            a += 0.3
            swirlR += 2.4
            ctx.addLine(to: CGPoint(x: swirlC.x + cos(a) * swirlR, y: swirlC.y + sin(a) * swirlR * 0.9))
        }
        ctx.strokePath()
        let loafP = CGMutablePath()
        loafP.move(to: CGPoint(x: cx - 340, y: baseY))
        loafP.addCurve(to: CGPoint(x: cx - 20, y: baseY), control1: CGPoint(x: cx - 360, y: baseY + 250), control2: CGPoint(x: cx, y: baseY + 250))
        loafP.closeSubpath()
        washFill(ctx, loafP, crustGold, rand: rand)
        ctx.addPath(loafP)
        ctx.setStrokeColor(inkTone.cg(0.9))
        ctx.setLineWidth(3.2)
        ctx.strokePath()
        hatchPath(ctx, loafP, rand: rand, angle: -0.6, gap: 10, alpha: 0.12)
    case "milkbread":
        drawTinLoaf(ctx, cx: cx - 60, baseY: baseY, wdt: 460, crust: crustGold.lighter(0.15), rand: rand)
        let dome2 = CGMutablePath()
        dome2.addArc(center: CGPoint(x: cx + 120, y: baseY + 156), radius: 90, startAngle: .pi, endAngle: 0, clockwise: true)
        dome2.closeSubpath()
        washFill(ctx, dome2, crustGold.lighter(0.2), rand: rand)
        ctx.addPath(dome2)
        ctx.setStrokeColor(inkTone.cg(0.85))
        ctx.setLineWidth(2.8)
        ctx.strokePath()
        steamCurl(ctx, from: CGPoint(x: cx, y: baseY + 330), rand: rand, count: 2)
    case "pita":
        groundShadow(ctx, cx: cx, y: baseY - 6, w: 640, rand: rand)
        for i in 0..<2 {
            let off = CGFloat(i) * 60
            let flat = CGMutablePath()
            flat.addEllipse(in: CGRect(x: cx - 300 + off, y: baseY + 6 + off * 0.7, width: 380, height: 90))
            washFill(ctx, flat, crustGold.lighter(0.18), rand: rand)
            ctx.addPath(flat)
            ctx.setStrokeColor(inkTone.cg(0.85))
            ctx.setLineWidth(2.8)
            ctx.strokePath()
        }
        let puffed = CGMutablePath()
        puffed.addEllipse(in: CGRect(x: cx + 60, y: baseY + 30, width: 320, height: 210))
        washFill(ctx, puffed, crustGold.lighter(0.1), rand: rand)
        ctx.addPath(puffed)
        ctx.setStrokeColor(inkTone.cg(0.9))
        ctx.setLineWidth(3)
        ctx.strokePath()
        for _ in 0..<8 {
            let bx = cx + 100 + rand.next() * 240
            let by = baseY + 60 + rand.next() * 140
            ctx.setFillColor(crustDeep.cg(0.5))
            ctx.fillEllipse(in: CGRect(x: bx, y: by, width: rand.range(8, 22), height: rand.range(6, 14)))
        }
        steamCurl(ctx, from: CGPoint(x: cx + 220, y: baseY + 250), rand: rand, count: 2)
    case "focaccia":
        groundShadow(ctx, cx: cx, y: baseY - 6, w: 680, rand: rand)
        let pan = rrect(CGRect(x: cx - 330, y: baseY, width: 660, height: 250), 26)
        washFill(ctx, pan, crustGold, rand: rand)
        ctx.addPath(pan)
        ctx.setStrokeColor(inkTone.cg(0.9))
        ctx.setLineWidth(3.4)
        ctx.strokePath()
        for _ in 0..<14 {
            let dx = cx - 290 + rand.next() * 580
            let dy = baseY + 34 + rand.next() * 180
            ctx.setFillColor(crustDeep.cg(0.75))
            ctx.fillEllipse(in: CGRect(x: dx, y: dy, width: 26, height: 20))
            ctx.setStrokeColor(inkTone.cg(0.4))
            ctx.setLineWidth(1.4)
            ctx.strokeEllipse(in: CGRect(x: dx, y: dy, width: 26, height: 20))
        }
        for _ in 0..<7 {
            let sx = cx - 270 + rand.next() * 540
            let sy = baseY + 40 + rand.next() * 170
            ctx.setStrokeColor(sageTone.darker(0.1).cg(0.95))
            ctx.setLineWidth(2.6)
            ctx.move(to: CGPoint(x: sx, y: sy))
            ctx.addLine(to: CGPoint(x: sx + 26, y: sy + 16))
            for k in 0..<5 {
                let t = CGFloat(k) / 4
                ctx.move(to: CGPoint(x: sx + t * 26, y: sy + t * 16))
                ctx.addLine(to: CGPoint(x: sx + t * 26 - 8, y: sy + t * 16 + 8))
            }
            ctx.strokePath()
        }
    case "crackers":
        groundShadow(ctx, cx: cx, y: baseY - 6, w: 620, rand: rand)
        for i in 0..<5 {
            let ox = cx - 240 + CGFloat(i % 3) * 200 + rand.range(-20, 20)
            let oy = baseY + 20 + CGFloat(i / 3) * 150 + rand.range(-10, 10)
            ctx.saveGState()
            ctx.translateBy(x: ox, y: oy)
            ctx.rotate(by: rand.range(-0.3, 0.3))
            let cracker = rrect(CGRect(x: -90, y: -60, width: 180, height: 120), 10)
            washFill(ctx, cracker, doughPale.darker(0.06), rand: rand)
            ctx.addPath(cracker)
            ctx.setStrokeColor(inkTone.cg(0.85))
            ctx.setLineWidth(2.4)
            ctx.strokePath()
            for _ in 0..<9 {
                ctx.setFillColor(inkTone.cg(0.6))
                ctx.fillEllipse(in: CGRect(x: rand.range(-70, 60), y: rand.range(-45, 40), width: 5, height: 5))
            }
            ctx.restoreGState()
        }
    case "grissini":
        let jar = CGRect(x: cx - 110, y: baseY - 4, width: 220, height: 230)
        for i in 0..<7 {
            let gx = cx - 80 + CGFloat(i) * 28
            ctx.saveGState()
            ctx.translateBy(x: gx, y: jar.maxY - 20)
            ctx.rotate(by: rand.range(-0.16, 0.16))
            let stick = rrect(CGRect(x: -9, y: 0, width: 18, height: 300 + rand.range(-30, 40)), 9)
            washFill(ctx, stick, i % 2 == 0 ? crustGold : crustDeep, rand: rand)
            ctx.addPath(stick)
            ctx.setStrokeColor(inkTone.cg(0.8))
            ctx.setLineWidth(2)
            ctx.strokePath()
            ctx.restoreGState()
        }
        washFill(ctx, rrect(jar, 16), RGB(r: 0.85, g: 0.88, b: 0.86), rand: rand, alpha: 0.55)
        inkRect(ctx, jar, rand: rand, width: 3)
        groundShadow(ctx, cx: cx, y: baseY - 8, w: 300, rand: rand)
    default:
        drawBakePlateSecond(ctx, spec: spec, w: w, h: h, cx: cx, baseY: baseY, rand: rand)
    }
    titleBlock(ctx, w: w, name: spec.name, sub: spec.sub)
    saveJPEG(ctx, "bake_\(spec.id)")
}

func drawBakePlateSecond(_ ctx: CGContext, spec: BakePlateSpec, w: CGFloat, h: CGFloat, cx: CGFloat, baseY: CGFloat, rand: Rand) {
    switch spec.id {
    case "croissant":
        groundShadow(ctx, cx: cx, y: baseY - 6, w: 640, rand: rand)
        for i in [0, 4, 1, 3, 2] {
            let f = CGFloat(i) - 2
            let segW: CGFloat = 150 - abs(f) * 26
            let segH: CGFloat = 250 - abs(f) * 62
            let sx = cx + f * 118
            ctx.saveGState()
            ctx.translateBy(x: sx, y: baseY + 2)
            ctx.rotate(by: f * 0.26)
            let seg = CGMutablePath()
            seg.addEllipse(in: CGRect(x: -segW / 2, y: -6, width: segW, height: segH))
            washFill(ctx, seg, abs(f) > 1.5 ? crustDeep : crustGold, rand: rand)
            ctx.addPath(seg)
            ctx.setStrokeColor(inkTone.cg(0.9))
            ctx.setLineWidth(3)
            ctx.strokePath()
            hatchPath(ctx, seg, rand: rand, angle: -0.5, gap: 12, alpha: 0.10)
            ctx.restoreGState()
        }
        ctx.setFillColor(RGB(r: 1, g: 0.96, b: 0.86).cg(0.28))
        ctx.fillEllipse(in: CGRect(x: cx - 90, y: baseY + 170, width: 180, height: 46))
        let butterB = rrect(CGRect(x: cx + 330, y: baseY + 4, width: 150, height: 84), 8)
        washFill(ctx, butterB, butterTone, rand: rand)
        ctx.addPath(butterB)
        ctx.setStrokeColor(inkTone.cg(0.8))
        ctx.setLineWidth(2.6)
        ctx.strokePath()
        wheatSprig(ctx, at: CGPoint(x: cx - 420, y: baseY + 10), angle: -0.25, len: 150, rand: rand)
        flourDust(ctx, around: CGRect(x: cx - 300, y: baseY - 12, width: 600, height: 40), rand: rand, count: 40)
    case "painauchoc":
        groundShadow(ctx, cx: cx, y: baseY - 6, w: 520, rand: rand)
        let body = rrect(CGRect(x: cx - 250, y: baseY + 6, width: 500, height: 230), 24)
        washFill(ctx, body, crustGold, rand: rand)
        ctx.addPath(body)
        ctx.setStrokeColor(inkTone.cg(0.9))
        ctx.setLineWidth(3.2)
        ctx.strokePath()
        for i in 0..<6 {
            let ly = baseY + 34 + CGFloat(i) * 34
            wobblyLine(ctx, from: CGPoint(x: cx - 230, y: ly), to: CGPoint(x: cx + 230, y: ly), rand: rand, width: 2, color: crustDeep.cg(0.5))
        }
        for off in [-110.0, 90.0] {
            let bar = rrect(CGRect(x: cx + CGFloat(off) - 14, y: baseY + 20, width: 40, height: 200), 8)
            washFill(ctx, bar, chocTone, rand: rand)
            ctx.addPath(bar)
            ctx.setStrokeColor(inkTone.cg(0.7))
            ctx.setLineWidth(2)
            ctx.strokePath()
        }
    case "palmier":
        groundShadow(ctx, cx: cx, y: baseY - 6, w: 500, rand: rand)
        for side in [-1.0, 1.0] {
            var r: CGFloat = 26
            var a: CGFloat = side > 0 ? .pi : 0
            let sc = CGPoint(x: cx + CGFloat(side) * 105, y: baseY + 130)
            ctx.setStrokeColor(crustDeep.cg(0.95))
            ctx.setLineWidth(30)
            ctx.setLineCap(.round)
            ctx.move(to: CGPoint(x: sc.x + cos(a) * r, y: sc.y + sin(a) * r))
            for _ in 0..<40 {
                a += CGFloat(side) * 0.24
                r += 3.4
                ctx.addLine(to: CGPoint(x: sc.x + cos(a) * r, y: sc.y + sin(a) * r * 0.92))
            }
            ctx.strokePath()
        }
        for _ in 0..<50 {
            let sx = cx - 220 + rand.next() * 440
            let sy = baseY + rand.next() * 260
            ctx.setFillColor(wheatTone.cg(rand.range(0.4, 0.9)))
            ctx.fillEllipse(in: CGRect(x: sx, y: sy, width: 3.4, height: 3.4))
        }
    case "danish":
        groundShadow(ctx, cx: cx, y: baseY - 6, w: 480, rand: rand)
        let sq: CGFloat = 340
        ctx.saveGState()
        ctx.translateBy(x: cx, y: baseY + 140)
        for k in 0..<4 {
            ctx.saveGState()
            ctx.rotate(by: CGFloat(k) * .pi / 2)
            let sail = CGMutablePath()
            sail.move(to: .zero)
            sail.addLine(to: CGPoint(x: sq * 0.5, y: 0))
            sail.addLine(to: CGPoint(x: sq * 0.5, y: sq * 0.22))
            sail.addQuadCurve(to: .zero, control: CGPoint(x: sq * 0.16, y: sq * 0.1))
            sail.closeSubpath()
            washFill(ctx, sail, k % 2 == 0 ? crustGold : crustGold.lighter(0.12), rand: rand)
            ctx.addPath(sail)
            ctx.setStrokeColor(inkTone.cg(0.85))
            ctx.setLineWidth(2.8)
            ctx.strokePath()
            ctx.restoreGState()
        }
        ctx.restoreGState()
        let jam = CGMutablePath()
        jam.addEllipse(in: CGRect(x: cx - 52, y: baseY + 88, width: 104, height: 104))
        washFill(ctx, jam, RGB(r: 0.62, g: 0.22, b: 0.2), rand: rand)
        ctx.addPath(jam)
        ctx.setStrokeColor(inkTone.cg(0.7))
        ctx.setLineWidth(2.4)
        ctx.strokePath()
        ctx.setFillColor(RGB(r: 1, g: 1, b: 1).cg(0.3))
        ctx.fillEllipse(in: CGRect(x: cx - 30, y: baseY + 140, width: 34, height: 20))
    case "sourdough":
        drawBoule(ctx, cx: cx, baseY: baseY, wdt: 500, crust: crustBold, rand: rand, slashes: 1, ear: true)
        for i in 0..<5 {
            let a = CGFloat(i) / 5 * .pi
            wobblyLine(ctx, from: CGPoint(x: cx - cos(a) * 210, y: baseY + 40 + sin(a) * 150), to: CGPoint(x: cx - cos(a) * 250, y: baseY + 40 + sin(a) * 190), rand: rand, width: 2, color: doughPale.cg(0.8))
        }
        flourDust(ctx, around: CGRect(x: cx - 260, y: baseY + 240, width: 520, height: 100), rand: rand, count: 60)
        steamCurl(ctx, from: CGPoint(x: cx, y: baseY + 390), rand: rand)
    case "pretzel":
        groundShadow(ctx, cx: cx, y: baseY - 6, w: 520, rand: rand)
        let pc = CGPoint(x: cx, y: baseY + 150)
        let lobeR: CGFloat = 120
        ctx.setStrokeColor(crustBold.cg(0.97))
        ctx.setLineWidth(52)
        ctx.setLineCap(.round)
        let path = CGMutablePath()
        path.move(to: CGPoint(x: pc.x - 190, y: pc.y - 110))
        path.addCurve(to: CGPoint(x: pc.x + 190, y: pc.y - 110), control1: CGPoint(x: pc.x - 230, y: pc.y + 170), control2: CGPoint(x: pc.x + 230, y: pc.y + 170))
        path.move(to: CGPoint(x: pc.x - 185, y: pc.y - 105))
        path.addCurve(to: CGPoint(x: pc.x + 60, y: pc.y + 88), control1: CGPoint(x: pc.x - 60, y: pc.y - 180), control2: CGPoint(x: pc.x + 40, y: pc.y - 30))
        path.move(to: CGPoint(x: pc.x + 185, y: pc.y - 105))
        path.addCurve(to: CGPoint(x: pc.x - 60, y: pc.y + 88), control1: CGPoint(x: pc.x + 60, y: pc.y - 180), control2: CGPoint(x: pc.x - 40, y: pc.y - 30))
        ctx.addPath(path)
        ctx.strokePath()
        ctx.setStrokeColor(inkTone.cg(0.55))
        ctx.setLineWidth(2.6)
        ctx.addPath(path.copy(strokingWithWidth: 52, lineCap: .round, lineJoin: .round, miterLimit: 10))
        ctx.strokePath()
        for _ in 0..<26 {
            let sx = pc.x - 200 + rand.next() * 400
            let sy = pc.y - 140 + rand.next() * 240
            if path.copy(strokingWithWidth: 52, lineCap: .round, lineJoin: .round, miterLimit: 10).contains(CGPoint(x: sx, y: sy)) {
                ctx.setFillColor(RGB(r: 0.99, g: 0.98, b: 0.95).cg(0.95))
                ctx.fill(CGRect(x: sx, y: sy, width: 7, height: 3.4))
            }
        }
        _ = lobeR
    case "babka":
        groundShadow(ctx, cx: cx, y: baseY - 6, w: 560, rand: rand)
        let tin = CGRect(x: cx - 260, y: baseY, width: 520, height: 60)
        washFill(ctx, rrect(tin, 10), steelTone.lighter(0.2), rand: rand)
        inkRect(ctx, tin, rand: rand, width: 2.6)
        for i in 0..<2 {
            let off = CGFloat(i) * 130 - 65
            var t: CGFloat = 0
            while t <= 1 {
                let x = cx - 240 + t * 480
                let yOff = sin(t * .pi * 3 + CGFloat(i) * .pi) * 40
                let r: CGFloat = 66
                let strand = CGMutablePath()
                strand.addEllipse(in: CGRect(x: x - r, y: tin.maxY + 60 + yOff - r * 0.7 + off * 0, width: r * 2, height: r * 1.4))
                washFill(ctx, strand, i == 0 ? crustGold : chocTone.lighter(0.15), rand: rand)
                ctx.addPath(strand)
                ctx.setStrokeColor(inkTone.cg(0.8))
                ctx.setLineWidth(2.6)
                ctx.strokePath()
                t += 0.12
            }
        }
    case "starbread":
        groundShadow(ctx, cx: cx, y: baseY - 6, w: 560, rand: rand)
        let sc = CGPoint(x: cx, y: baseY + 160)
        for k in 0..<8 {
            let a = CGFloat(k) / 8 * 2 * .pi - .pi / 2
            ctx.saveGState()
            ctx.translateBy(x: sc.x, y: sc.y)
            ctx.rotate(by: a)
            let ray = CGMutablePath()
            ray.move(to: CGPoint(x: 0, y: 20))
            ray.addQuadCurve(to: CGPoint(x: 200, y: 0), control: CGPoint(x: 110, y: 66))
            ray.addQuadCurve(to: CGPoint(x: 0, y: -20), control: CGPoint(x: 110, y: -66))
            ray.closeSubpath()
            washFill(ctx, ray, k % 2 == 0 ? crustGold : crustGold.lighter(0.12), rand: rand)
            ctx.addPath(ray)
            ctx.setStrokeColor(inkTone.cg(0.85))
            ctx.setLineWidth(2.6)
            ctx.strokePath()
            ctx.restoreGState()
        }
        let hub = CGMutablePath()
        hub.addEllipse(in: CGRect(x: sc.x - 56, y: sc.y - 56, width: 112, height: 112))
        washFill(ctx, hub, crustDeep, rand: rand)
        ctx.addPath(hub)
        ctx.setStrokeColor(inkTone.cg(0.85))
        ctx.setLineWidth(2.8)
        ctx.strokePath()
    case "crown":
        groundShadow(ctx, cx: cx, y: baseY - 6, w: 560, rand: rand)
        let ring = CGMutablePath()
        ring.addEllipse(in: CGRect(x: cx - 250, y: baseY + 10, width: 500, height: 300))
        ring.addEllipse(in: CGRect(x: cx - 110, y: baseY + 96, width: 220, height: 130))
        ctx.addPath(ring)
        ctx.setFillColor(crustDeep.cg())
        ctx.fillPath(using: .evenOdd)
        ctx.addPath(ring)
        ctx.setStrokeColor(inkTone.cg(0.9))
        ctx.setLineWidth(3)
        ctx.strokePath()
        for _ in 0..<160 {
            let a = rand.next() * 2 * .pi
            let rr = 150 + rand.next() * 90
            let sx = cx + cos(a) * rr
            let sy = baseY + 160 + sin(a) * rr * 0.58
            ctx.setFillColor([RGB(r: 0.95, g: 0.93, b: 0.85), RGB(r: 0.25, g: 0.2, b: 0.16), wheatTone][rand.int(3)].cg(0.9))
            ctx.fillEllipse(in: CGRect(x: sx, y: sy, width: rand.range(4, 8), height: rand.range(3, 5)))
        }
    case "sheaf":
        groundShadow(ctx, cx: cx, y: baseY - 6, w: 460, rand: rand)
        for i in 0..<9 {
            let f = CGFloat(i) - 4
            let bx = cx + f * 34
            wobblyLine(ctx, from: CGPoint(x: bx, y: baseY + 6), to: CGPoint(x: cx + f * 62, y: baseY + 320), rand: rand, width: 12, color: crustGold.cg(0.95), wobble: 1)
            wheatSprig(ctx, at: CGPoint(x: cx + f * 62, y: baseY + 300), angle: f * 0.06, len: 90, rand: rand)
        }
        let band = rrect(CGRect(x: cx - 130, y: baseY + 120, width: 260, height: 54), 27)
        washFill(ctx, band, crustDeep, rand: rand)
        ctx.addPath(band)
        ctx.setStrokeColor(inkTone.cg(0.85))
        ctx.setLineWidth(2.8)
        ctx.strokePath()
    case "sourfruit":
        drawBoule(ctx, cx: cx, baseY: baseY, wdt: 480, crust: crustBold, rand: rand, slashes: 2)
        for _ in 0..<7 {
            let fx = cx - 170 + rand.next() * 340
            let fy = baseY + 60 + rand.next() * 130
            let fig = CGMutablePath()
            fig.addEllipse(in: CGRect(x: fx, y: fy, width: 34, height: 26))
            washFill(ctx, fig, RGB(r: 0.45, g: 0.24, b: 0.3), rand: rand)
            ctx.addPath(fig)
            ctx.setStrokeColor(inkTone.cg(0.6))
            ctx.setLineWidth(1.8)
            ctx.strokePath()
        }
        for _ in 0..<5 {
            let wx = cx - 150 + rand.next() * 300
            let wy = baseY + 80 + rand.next() * 110
            ctx.setFillColor(RGB(r: 0.78, g: 0.66, b: 0.5).cg())
            ctx.fillEllipse(in: CGRect(x: wx, y: wy, width: 22, height: 16))
            ctx.setStrokeColor(inkTone.cg(0.5))
            ctx.setLineWidth(1.4)
            ctx.strokeEllipse(in: CGRect(x: wx, y: wy, width: 22, height: 16))
        }
    default:
        drawBoule(ctx, cx: cx, baseY: baseY, wdt: 460, crust: crustGold, rand: rand)
    }
}

let bakeSpecs: [BakePlateSpec] = [
    BakePlateSpec(id: "tinloaf", name: "White Tin Loaf", sub: "Everyday Loaves · Plate I", seed: 301),
    BakePlateSpec(id: "boule", name: "Farmhouse Boule", sub: "Everyday Loaves · Plate II", seed: 302),
    BakePlateSpec(id: "baguette", name: "Baguettes", sub: "Everyday Loaves · Plate III", seed: 303),
    BakePlateSpec(id: "rolls", name: "Soft Morning Rolls", sub: "Everyday Loaves · Plate IV", seed: 304),
    BakePlateSpec(id: "rye", name: "Dark Rye Loaf", sub: "Everyday Loaves · Plate V", seed: 305),
    BakePlateSpec(id: "brioche", name: "Brioche Buns", sub: "The Enriched Shelf · Plate VI", seed: 306),
    BakePlateSpec(id: "challah", name: "Challah Braid", sub: "The Enriched Shelf · Plate VII", seed: 307),
    BakePlateSpec(id: "cinnamon", name: "Cinnamon Swirl", sub: "The Enriched Shelf · Plate VIII", seed: 308),
    BakePlateSpec(id: "milkbread", name: "Milk Bread", sub: "The Enriched Shelf · Plate IX", seed: 309),
    BakePlateSpec(id: "pita", name: "Pita Pockets", sub: "Flat and Crisp · Plate X", seed: 310),
    BakePlateSpec(id: "focaccia", name: "Rosemary Focaccia", sub: "Flat and Crisp · Plate XI", seed: 311),
    BakePlateSpec(id: "crackers", name: "Seeded Crackers", sub: "Flat and Crisp · Plate XII", seed: 312),
    BakePlateSpec(id: "grissini", name: "Hand-Rolled Grissini", sub: "Flat and Crisp · Plate XIII", seed: 313),
    BakePlateSpec(id: "croissant", name: "Croissants", sub: "The Laminated Arts · Plate XIV", seed: 314),
    BakePlateSpec(id: "painauchoc", name: "Pain au Chocolat", sub: "The Laminated Arts · Plate XV", seed: 315),
    BakePlateSpec(id: "palmier", name: "Palmiers", sub: "The Laminated Arts · Plate XVI", seed: 316),
    BakePlateSpec(id: "danish", name: "Danish Windmills", sub: "The Laminated Arts · Plate XVII", seed: 317),
    BakePlateSpec(id: "sourdough", name: "Sourdough Country Loaf", sub: "Celebration Bakes · Plate XVIII", seed: 318),
    BakePlateSpec(id: "pretzel", name: "Pretzel Twists", sub: "Celebration Bakes · Plate XIX", seed: 319),
    BakePlateSpec(id: "babka", name: "Chocolate Babka", sub: "Celebration Bakes · Plate XX", seed: 320),
    BakePlateSpec(id: "starbread", name: "Star Bread", sub: "Celebration Bakes · Plate XXI", seed: 321),
    BakePlateSpec(id: "crown", name: "Seeded Harvest Crown", sub: "Celebration Bakes · Plate XXII", seed: 322),
    BakePlateSpec(id: "sheaf", name: "Wheat Sheaf", sub: "Celebration Bakes · Plate XXIII", seed: 323),
    BakePlateSpec(id: "sourfruit", name: "Fig and Walnut Sourdough", sub: "Celebration Bakes · Plate XXIV", seed: 324),
]

for spec in bakeSpecs {
    drawBakePlate(spec)
}
print("BAKE PLATES DONE")

func drawGuidePlate(_ id: String, _ title: String, _ sub: String, draw: (CGContext, CGFloat, CGFloat, Rand) -> Void) {
    let W = 1400, H = 1000
    let w = CGFloat(W), h = CGFloat(H)
    let ctx = makeContext(W, H)
    let rand = Rand(UInt64(abs(id.hashValue % 100000)) &+ 17)
    paperBase(ctx, w, h, seed: UInt64(abs(id.hashValue % 100000)) &+ 3)
    plateFrame(ctx, w, h, inset: 44)
    draw(ctx, w, h, rand)
    titleBlock(ctx, w: w, name: title, sub: sub)
    saveJPEG(ctx, id)
}

drawGuidePlate("guide_gluten", "The Windowpane", "Fig. I — what kneading builds") { ctx, w, h, rand in
    let cx = w / 2
    let cy = h * 0.5
    let sheet = CGMutablePath()
    sheet.move(to: CGPoint(x: cx - 260, y: cy - 120))
    sheet.addQuadCurve(to: CGPoint(x: cx + 260, y: cy - 120), control: CGPoint(x: cx, y: cy - 60))
    sheet.addQuadCurve(to: CGPoint(x: cx + 200, y: cy + 160), control: CGPoint(x: cx + 290, y: cy + 60))
    sheet.addQuadCurve(to: CGPoint(x: cx - 200, y: cy + 160), control: CGPoint(x: cx, y: cy + 230))
    sheet.addQuadCurve(to: CGPoint(x: cx - 260, y: cy - 120), control: CGPoint(x: cx - 290, y: cy + 60))
    sheet.closeSubpath()
    washFill(ctx, sheet, doughPale, rand: rand, alpha: 0.6)
    ctx.addPath(sheet)
    ctx.setStrokeColor(inkTone.cg(0.85))
    ctx.setLineWidth(3)
    ctx.strokePath()
    let light = CGMutablePath()
    light.addEllipse(in: CGRect(x: cx - 110, y: cy - 40, width: 220, height: 150))
    ctx.addPath(light)
    ctx.setFillColor(RGB(r: 1, g: 0.98, b: 0.9).cg(0.75))
    ctx.fillPath()
    drawText(ctx, "thin enough to read through", font: "Georgia-Italic", size: 28, at: CGPoint(x: cx, y: cy + 26), color: inkTone.cg(0.6))
    for corner in [CGPoint(x: cx - 240, y: cy - 110), CGPoint(x: cx + 240, y: cy - 110), CGPoint(x: cx - 190, y: cy + 150), CGPoint(x: cx + 190, y: cy + 150)] {
        let thumb = CGMutablePath()
        thumb.addEllipse(in: CGRect(x: corner.x - 30, y: corner.y - 22, width: 60, height: 44))
        washFill(ctx, thumb, RGB(r: 0.92, g: 0.80, b: 0.68), rand: rand)
        ctx.addPath(thumb)
        ctx.setStrokeColor(inkTone.cg(0.7))
        ctx.setLineWidth(2.2)
        ctx.strokePath()
    }
    let net = CGRect(x: cx - 500, y: cy - 60, width: 180, height: 180)
    ctx.setStrokeColor(inkTone.cg(0.5))
    ctx.setLineWidth(1.8)
    for i in 0..<6 {
        let t = CGFloat(i) / 5
        let sx = net.minX + t * net.width
        ctx.move(to: CGPoint(x: sx, y: net.minY))
        for k in 1...5 {
            ctx.addLine(to: CGPoint(x: sx + rand.range(-8, 8), y: net.minY + CGFloat(k) / 5 * net.height))
        }
        let sy = net.minY + t * net.height
        ctx.move(to: CGPoint(x: net.minX, y: sy))
        for k in 1...5 {
            ctx.addLine(to: CGPoint(x: net.minX + CGFloat(k) / 5 * net.width, y: sy + rand.range(-8, 8)))
        }
    }
    ctx.strokePath()
    drawText(ctx, "the gluten net", font: "Georgia-Italic", size: 26, at: CGPoint(x: net.midX, y: net.minY - 34), color: inkTone.cg(0.6))
}

drawGuidePlate("guide_yeast", "The Living Ingredient", "Fig. II — yeast at its feast") { ctx, w, h, rand in
    let cx = w / 2
    let lens = CGPoint(x: cx + 150, y: h * 0.5)
    let lensR: CGFloat = 210
    let bowlRect = CGRect(x: cx - 470, y: h * 0.32, width: 320, height: 180)
    let dome = CGMutablePath()
    dome.move(to: CGPoint(x: bowlRect.minX, y: bowlRect.maxY))
    dome.addQuadCurve(to: CGPoint(x: bowlRect.maxX, y: bowlRect.maxY), control: CGPoint(x: bowlRect.midX, y: bowlRect.maxY + 130))
    dome.closeSubpath()
    washFill(ctx, dome, doughPale, rand: rand)
    ctx.addPath(dome)
    ctx.setStrokeColor(inkTone.cg(0.85))
    ctx.setLineWidth(3)
    ctx.strokePath()
    let bowl = CGMutablePath()
    bowl.move(to: CGPoint(x: bowlRect.minX - 10, y: bowlRect.maxY))
    bowl.addCurve(to: CGPoint(x: bowlRect.maxX + 10, y: bowlRect.maxY), control1: CGPoint(x: bowlRect.minX + 30, y: bowlRect.minY), control2: CGPoint(x: bowlRect.maxX - 30, y: bowlRect.minY))
    bowl.closeSubpath()
    washFill(ctx, bowl, terraTone, rand: rand)
    ctx.addPath(bowl)
    ctx.setStrokeColor(inkTone.cg(0.85))
    ctx.setLineWidth(3)
    ctx.strokePath()
    ctx.setFillColor(RGB(r: 0.97, g: 0.96, b: 0.92).cg(0.94))
    ctx.fillEllipse(in: CGRect(x: lens.x - lensR, y: lens.y - lensR, width: lensR * 2, height: lensR * 2))
    ctx.setStrokeColor(inkTone.cg(0.9))
    ctx.setLineWidth(5)
    ctx.strokeEllipse(in: CGRect(x: lens.x - lensR, y: lens.y - lensR, width: lensR * 2, height: lensR * 2))
    ctx.setLineWidth(10)
    ctx.move(to: CGPoint(x: lens.x - lensR * 0.72, y: lens.y - lensR * 0.72))
    ctx.addLine(to: CGPoint(x: lens.x - lensR * 1.3, y: lens.y - lensR * 1.3))
    ctx.strokePath()
    for _ in 0..<12 {
        let a = rand.next() * 2 * .pi
        let rr = sqrt(rand.next()) * lensR * 0.8
        let bx = lens.x + cos(a) * rr
        let by = lens.y + sin(a) * rr
        let cellR = rand.range(16, 34)
        let cell = CGMutablePath()
        cell.addEllipse(in: CGRect(x: bx - cellR, y: by - cellR * 0.8, width: cellR * 2, height: cellR * 1.6))
        washFill(ctx, cell, butterTone, rand: rand)
        ctx.addPath(cell)
        ctx.setStrokeColor(inkTone.cg(0.7))
        ctx.setLineWidth(2)
        ctx.strokePath()
        if rand.next() > 0.4 {
            let bud = CGMutablePath()
            bud.addEllipse(in: CGRect(x: bx + cellR * 0.7, y: by - cellR * 0.5, width: cellR * 0.9, height: cellR * 0.7))
            washFill(ctx, bud, butterTone.lighter(0.1), rand: rand)
            ctx.addPath(bud)
            ctx.setStrokeColor(inkTone.cg(0.6))
            ctx.setLineWidth(1.6)
            ctx.strokePath()
        }
    }
    drawText(ctx, "budding, breathing, raising", font: "Georgia-Italic", size: 28, at: CGPoint(x: lens.x, y: lens.y - lensR - 44), color: inkTone.cg(0.6))
}

drawGuidePlate("guide_hydration", "The Water Question", "Fig. III — wet dough, open crumb") { ctx, w, h, rand in
    let cy = h * 0.5
    for (i, hyd) in [0.55, 0.7, 0.85].enumerated() {
        let cx = w * 0.25 + CGFloat(i) * w * 0.25
        let slice = CGMutablePath()
        slice.addArc(center: CGPoint(x: cx, y: cy - 60), radius: 130, startAngle: .pi, endAngle: 0, clockwise: true)
        slice.closeSubpath()
        washFill(ctx, slice, crustGold, rand: rand)
        ctx.addPath(slice)
        ctx.setStrokeColor(inkTone.cg(0.9))
        ctx.setLineWidth(3)
        ctx.strokePath()
        ctx.saveGState()
        let inner = CGMutablePath()
        inner.addArc(center: CGPoint(x: cx, y: cy - 66), radius: 112, startAngle: .pi, endAngle: 0, clockwise: true)
        inner.closeSubpath()
        ctx.addPath(inner)
        ctx.clip()
        ctx.setFillColor(doughPale.cg())
        ctx.fill(CGRect(x: cx - 130, y: cy - 200, width: 260, height: 150))
        let holeCount = 40 - i * 12
        let holeScale = 1.0 + CGFloat(i) * 1.3
        for _ in 0..<holeCount {
            let a = rand.next() * .pi
            let rr = sqrt(rand.next()) * 100
            let hx = cx + cos(a + .pi) * rr
            let hy = cy - 70 - abs(sin(a)) * rr * 0.8
            let hr = rand.range(3, 8) * holeScale
            ctx.setFillColor(doughShade.cg(0.8))
            ctx.fillEllipse(in: CGRect(x: hx - hr, y: hy - hr * 0.8, width: hr * 2, height: hr * 1.6))
        }
        ctx.restoreGState()
        drawText(ctx, "\(Int(hyd * 100))%", font: "Georgia-Bold", size: 40, at: CGPoint(x: cx, y: cy - 250), color: inkTone.cg(0.85), tracking: 2)
        let dropCount = i + 1
        for d in 0..<dropCount {
            let dx = cx - CGFloat(dropCount - 1) * 16 + CGFloat(d) * 32
            let drop = CGMutablePath()
            drop.move(to: CGPoint(x: dx, y: cy + 120))
            drop.addQuadCurve(to: CGPoint(x: dx + 12, y: cy + 76), control: CGPoint(x: dx + 16, y: cy + 108))
            drop.addQuadCurve(to: CGPoint(x: dx - 12, y: cy + 76), control: CGPoint(x: dx, y: cy + 54))
            drop.addQuadCurve(to: CGPoint(x: dx, y: cy + 120), control: CGPoint(x: dx - 16, y: cy + 108))
            washFill(ctx, drop, RGB(r: 0.55, g: 0.68, b: 0.75), rand: rand)
            ctx.addPath(drop)
            ctx.setStrokeColor(inkTone.cg(0.6))
            ctx.setLineWidth(2)
            ctx.strokePath()
        }
    }
    drawText(ctx, "same flour — different water", font: "Georgia-Italic", size: 30, at: CGPoint(x: w / 2, y: h * 0.78), color: inkTone.cg(0.6))
}

drawGuidePlate("guide_proofing", "The Patient Hour", "Fig. IV — the poke test") { ctx, w, h, rand in
    let cy = h * 0.44
    let labels = ["too soon", "ready", "gone over"]
    for i in 0..<3 {
        let cx = w * 0.25 + CGFloat(i) * w * 0.25
        let domeH: CGFloat = i == 0 ? 90 : (i == 1 ? 150 : 96)
        let dome = CGMutablePath()
        dome.move(to: CGPoint(x: cx - 140, y: cy))
        dome.addQuadCurve(to: CGPoint(x: cx + 140, y: cy), control: CGPoint(x: cx, y: cy + domeH * 2))
        dome.closeSubpath()
        washFill(ctx, dome, doughPale, rand: rand)
        ctx.addPath(dome)
        ctx.setStrokeColor(inkTone.cg(0.85))
        ctx.setLineWidth(3)
        ctx.strokePath()
        let dimple = CGMutablePath()
        let dimpleDepth: CGFloat = i == 0 ? 6 : (i == 1 ? 16 : 34)
        dimple.addEllipse(in: CGRect(x: cx - 24, y: cy + domeH - dimpleDepth, width: 48, height: 22))
        ctx.addPath(dimple)
        ctx.setFillColor(doughShade.cg(0.9))
        ctx.fillPath()
        ctx.addPath(dimple)
        ctx.setStrokeColor(inkTone.cg(0.6))
        ctx.setLineWidth(1.8)
        ctx.strokePath()
        if i == 2 {
            let crack = CGMutablePath()
            crack.move(to: CGPoint(x: cx - 70, y: cy + domeH * 0.7))
            crack.addLine(to: CGPoint(x: cx - 30, y: cy + domeH * 0.95))
            crack.addLine(to: CGPoint(x: cx + 20, y: cy + domeH * 0.7))
            ctx.addPath(crack)
            ctx.setStrokeColor(inkTone.cg(0.5))
            ctx.setLineWidth(2)
            ctx.strokePath()
        }
        drawText(ctx, labels[i], font: "Georgia-Italic", size: 28, at: CGPoint(x: cx, y: cy - 60), color: inkTone.cg(0.65))
        let finger = CGMutablePath()
        finger.addRoundedRect(in: CGRect(x: cx - 14, y: cy + domeH + 30, width: 28, height: 90), cornerWidth: 14, cornerHeight: 14)
        washFill(ctx, finger, RGB(r: 0.92, g: 0.80, b: 0.68), rand: rand)
        ctx.addPath(finger)
        ctx.setStrokeColor(inkTone.cg(0.7))
        ctx.setLineWidth(2.2)
        ctx.strokePath()
    }
    let clockC = CGPoint(x: w / 2, y: h * 0.76)
    ctx.setFillColor(RGB(r: 0.95, g: 0.93, b: 0.87).cg())
    ctx.fillEllipse(in: CGRect(x: clockC.x - 54, y: clockC.y - 54, width: 108, height: 108))
    ctx.setStrokeColor(inkTone.cg(0.85))
    ctx.setLineWidth(3.4)
    ctx.strokeEllipse(in: CGRect(x: clockC.x - 54, y: clockC.y - 54, width: 108, height: 108))
    ctx.setLineWidth(3.4)
    ctx.move(to: clockC)
    ctx.addLine(to: CGPoint(x: clockC.x + 26, y: clockC.y + 20))
    ctx.move(to: clockC)
    ctx.addLine(to: CGPoint(x: clockC.x - 6, y: clockC.y + 38))
    ctx.strokePath()
}

drawGuidePlate("guide_oven", "Steam and Spring", "Fig. V — the first five minutes") { ctx, w, h, rand in
    let cx = w / 2
    let ovenRect = CGRect(x: cx - 300, y: h * 0.24, width: 600, height: 430)
    washFill(ctx, rrect(ovenRect, 20), RGB(r: 0.32, g: 0.28, b: 0.26), rand: rand)
    inkRect(ctx, ovenRect, rand: rand, width: 3.4)
    let door = ovenRect.insetBy(dx: 50, dy: 60)
    ctx.setFillColor(RGB(r: 0.16, g: 0.10, b: 0.07).cg())
    ctx.fill(door)
    let glow = CGGradient(colorsSpace: nil, colors: [RGB(r: 1, g: 0.62, b: 0.28).cg(0.55), RGB(r: 1, g: 0.62, b: 0.28).cg(0)] as CFArray, locations: [0, 1])!
    ctx.saveGState()
    ctx.clip(to: door)
    ctx.drawRadialGradient(glow, startCenter: CGPoint(x: door.midX, y: door.minY + 60), startRadius: 0, endCenter: CGPoint(x: door.midX, y: door.minY + 60), endRadius: 320, options: [])
    drawBoule(ctx, cx: door.midX, baseY: door.minY + 40, wdt: 300, crust: crustGold, rand: rand, slashes: 1, ear: true)
    for i in 0..<4 {
        steamCurl(ctx, from: CGPoint(x: door.minX + 60 + CGFloat(i) * 120, y: door.maxY - 120), rand: rand, count: 1)
    }
    ctx.restoreGState()
    inkRect(ctx, door, rand: rand, width: 2.6)
    let kettle = CGPoint(x: cx - 430, y: h * 0.36)
    let body = CGMutablePath()
    body.addEllipse(in: CGRect(x: kettle.x - 70, y: kettle.y - 50, width: 140, height: 100))
    washFill(ctx, body, steelTone, rand: rand)
    ctx.addPath(body)
    ctx.setStrokeColor(inkTone.cg(0.85))
    ctx.setLineWidth(3)
    ctx.strokePath()
    ctx.setStrokeColor(steelTone.darker(0.1).cg())
    ctx.setLineWidth(8)
    ctx.move(to: CGPoint(x: kettle.x + 60, y: kettle.y + 10))
    ctx.addLine(to: CGPoint(x: kettle.x + 110, y: kettle.y + 40))
    ctx.strokePath()
    steamCurl(ctx, from: CGPoint(x: kettle.x + 116, y: kettle.y + 40), rand: rand, count: 2)
    drawText(ctx, "steam first, crust later", font: "Georgia-Italic", size: 30, at: CGPoint(x: cx, y: h * 0.79), color: inkTone.cg(0.65))
}

drawGuidePlate("guide_crust", "Reading the Crust", "Fig. VI — the browning scale") { ctx, w, h, rand in
    let cy = h * 0.52
    let shades: [(RGB, String)] = [
        (doughPale, "pale"),
        (RGB(r: 0.902, g: 0.769, b: 0.541), "first gold"),
        (crustGold, "golden"),
        (crustDeep, "deep gold"),
        (crustBold, "bold"),
        (RGB(r: 0.247, g: 0.137, b: 0.063), "too far"),
    ]
    let sw = (w - 340) / CGFloat(shades.count)
    for (i, shade) in shades.enumerated() {
        let x = 170 + CGFloat(i) * sw
        let tile = rrect(CGRect(x: x + 8, y: cy - 60, width: sw - 16, height: 130), 14)
        washFill(ctx, tile, shade.0, rand: rand)
        ctx.addPath(tile)
        ctx.setStrokeColor(inkTone.cg(0.8))
        ctx.setLineWidth(2.6)
        ctx.strokePath()
        drawText(ctx, shade.1, font: "Georgia-Italic", size: 24, at: CGPoint(x: x + sw / 2, y: cy - 100), color: inkTone.cg(0.65))
    }
    let arrowY = cy + 120
    wobblyLine(ctx, from: CGPoint(x: 190, y: arrowY), to: CGPoint(x: w - 210, y: arrowY), rand: rand, width: 3, color: inkTone.cg(0.6))
    ctx.setStrokeColor(inkTone.cg(0.6))
    ctx.setLineWidth(3)
    ctx.move(to: CGPoint(x: w - 230, y: arrowY - 12))
    ctx.addLine(to: CGPoint(x: w - 208, y: arrowY))
    ctx.addLine(to: CGPoint(x: w - 230, y: arrowY + 12))
    ctx.strokePath()
    drawText(ctx, "flavour deepens this way — until it doesn't", font: "Georgia-Italic", size: 28, at: CGPoint(x: w / 2, y: arrowY + 40), color: inkTone.cg(0.6))
    drawBoule(ctx, cx: w / 2, baseY: cy + 190, wdt: 260, crust: crustDeep, rand: rand, slashes: 1)
}

drawGuidePlate("guide_lamination", "The Butter Fold", "Fig. VII — three folds, twenty-seven leaves") { ctx, w, h, rand in
    let cy = h * 0.5
    let counts = [3, 9, 27]
    for i in 0..<3 {
        let cx = w * 0.25 + CGFloat(i) * w * 0.25
        let stack = CGRect(x: cx - 130, y: cy - 70, width: 260, height: 150)
        washFill(ctx, rrect(stack, 12), doughPale, rand: rand)
        inkRect(ctx, stack, rand: rand, width: 2.8)
        let lines = counts[i]
        for k in 1..<min(lines, 18) {
            let y = stack.minY + stack.height * CGFloat(k) / CGFloat(min(lines, 18))
            wobblyLine(ctx, from: CGPoint(x: stack.minX + 8, y: y), to: CGPoint(x: stack.maxX - 8, y: y), rand: rand, width: lines > 9 ? 1.6 : 3, color: butterTone.darker(0.05).cg(0.95), wobble: 0.6)
        }
        drawText(ctx, "\(counts[i]) layers", font: "Georgia-Bold", size: 30, at: CGPoint(x: cx, y: cy - 120), color: inkTone.cg(0.8), tracking: 1)
        if i < 2 {
            let ax = cx + w * 0.125
            ctx.setStrokeColor(inkTone.cg(0.6))
            ctx.setLineWidth(3)
            ctx.move(to: CGPoint(x: ax - 26, y: cy))
            ctx.addLine(to: CGPoint(x: ax + 20, y: cy))
            ctx.move(to: CGPoint(x: ax + 6, y: cy + 12))
            ctx.addLine(to: CGPoint(x: ax + 20, y: cy))
            ctx.addLine(to: CGPoint(x: ax + 6, y: cy - 12))
            ctx.strokePath()
            drawText(ctx, "fold", font: "Georgia-Italic", size: 22, at: CGPoint(x: ax, y: cy + 26), color: inkTone.cg(0.55))
        }
    }
    let butter = rrect(CGRect(x: w * 0.5 - 90, y: h * 0.72, width: 180, height: 90), 8)
    washFill(ctx, butter, butterTone, rand: rand)
    ctx.addPath(butter)
    ctx.setStrokeColor(inkTone.cg(0.8))
    ctx.setLineWidth(2.8)
    ctx.strokePath()
    drawText(ctx, "keep it cold", font: "Georgia-Italic", size: 26, at: CGPoint(x: w * 0.5, y: h * 0.72 - 34), color: inkTone.cg(0.6))
}

drawGuidePlate("guide_flat", "The Oldest Breads", "Fig. VIII — ten thousand years of supper") { ctx, w, h, rand in
    let cy = h * 0.5
    let stone = CGMutablePath()
    stone.addEllipse(in: CGRect(x: w * 0.14, y: cy - 40, width: 320, height: 130))
    washFill(ctx, stone, steelTone.darker(0.1), rand: rand)
    ctx.addPath(stone)
    ctx.setStrokeColor(inkTone.cg(0.85))
    ctx.setLineWidth(3)
    ctx.strokePath()
    let flat = CGMutablePath()
    flat.addEllipse(in: CGRect(x: w * 0.19, y: cy + 6, width: 200, height: 60))
    washFill(ctx, flat, crustGold, rand: rand)
    ctx.addPath(flat)
    ctx.setStrokeColor(inkTone.cg(0.8))
    ctx.setLineWidth(2.6)
    ctx.strokePath()
    for i in 0..<3 {
        let fx = w * 0.16 + CGFloat(i) * 60
        let flame = CGMutablePath()
        flame.move(to: CGPoint(x: fx + 100, y: cy - 60))
        flame.addQuadCurve(to: CGPoint(x: fx + 118, y: cy - 130), control: CGPoint(x: fx + 140, y: cy - 90))
        flame.addQuadCurve(to: CGPoint(x: fx + 100, y: cy - 60), control: CGPoint(x: fx + 92, y: cy - 100))
        washFill(ctx, flame, RGB(r: 0.85, g: 0.5, b: 0.2), rand: rand)
        ctx.addPath(flame)
        ctx.setStrokeColor(redTone.cg(0.8))
        ctx.setLineWidth(2)
        ctx.strokePath()
    }
    let puffC = CGPoint(x: w * 0.7, y: cy - 60)
    let puffed = CGMutablePath()
    puffed.addEllipse(in: CGRect(x: puffC.x - 160, y: puffC.y - 60, width: 320, height: 140))
    washFill(ctx, puffed, crustGold.lighter(0.1), rand: rand)
    ctx.addPath(puffed)
    ctx.setStrokeColor(inkTone.cg(0.9))
    ctx.setLineWidth(3)
    ctx.strokePath()
    drawText(ctx, "the pita's one glorious breath", font: "Georgia-Italic", size: 26, at: CGPoint(x: puffC.x, y: puffC.y - 100), color: inkTone.cg(0.6))
    let pin = CGPoint(x: w * 0.7, y: cy + 130)
    ctx.setStrokeColor(RGB(r: 0.62, g: 0.46, b: 0.30).cg())
    ctx.setLineWidth(26)
    ctx.setLineCap(.round)
    ctx.move(to: CGPoint(x: pin.x - 170, y: pin.y))
    ctx.addLine(to: CGPoint(x: pin.x + 170, y: pin.y))
    ctx.strokePath()
    ctx.setLineWidth(12)
    ctx.move(to: CGPoint(x: pin.x - 230, y: pin.y))
    ctx.addLine(to: CGPoint(x: pin.x - 174, y: pin.y))
    ctx.move(to: CGPoint(x: pin.x + 174, y: pin.y))
    ctx.addLine(to: CGPoint(x: pin.x + 230, y: pin.y))
    ctx.strokePath()
    ctx.setStrokeColor(inkTone.cg(0.6))
    ctx.setLineWidth(2.4)
    ctx.strokeEllipse(in: CGRect(x: pin.x - 170, y: pin.y - 13, width: 340, height: 26))
}

drawGuidePlate("guide_starter", "The Jar on the Sill", "Fig. IX — a very slow pet") { ctx, w, h, rand in
    let cx = w / 2
    let sill = CGRect(x: cx - 340, y: h * 0.30, width: 680, height: 34)
    washFill(ctx, rrect(sill, 6), RGB(r: 0.62, g: 0.46, b: 0.30), rand: rand)
    inkRect(ctx, sill, rand: rand, width: 2.8)
    let window = CGRect(x: cx - 300, y: sill.maxY, width: 600, height: 380)
    washFill(ctx, rrect(window, 10), skyTone, rand: rand, alpha: 0.5)
    inkRect(ctx, window, rand: rand, width: 3)
    wobblyLine(ctx, from: CGPoint(x: cx, y: window.minY), to: CGPoint(x: cx, y: window.maxY), rand: rand, width: 6, color: inkTone.cg(0.6))
    wobblyLine(ctx, from: CGPoint(x: window.minX, y: window.midY), to: CGPoint(x: window.maxX, y: window.midY), rand: rand, width: 6, color: inkTone.cg(0.6))
    let jarRect = CGRect(x: cx - 95, y: sill.maxY + 10, width: 190, height: 250)
    let starterLevel = jarRect.minY + 120
    let starterP = CGMutablePath()
    starterP.move(to: CGPoint(x: jarRect.minX + 8, y: jarRect.minY + 8))
    starterP.addLine(to: CGPoint(x: jarRect.minX + 8, y: starterLevel))
    starterP.addQuadCurve(to: CGPoint(x: jarRect.maxX - 8, y: starterLevel), control: CGPoint(x: cx, y: starterLevel + 22))
    starterP.addLine(to: CGPoint(x: jarRect.maxX - 8, y: jarRect.minY + 8))
    starterP.closeSubpath()
    washFill(ctx, starterP, doughPale, rand: rand)
    for _ in 0..<16 {
        let bx = jarRect.minX + 20 + rand.next() * (jarRect.width - 40)
        let by = jarRect.minY + 16 + rand.next() * 100
        let r = rand.range(3, 9)
        ctx.setStrokeColor(inkTone.cg(0.35))
        ctx.setLineWidth(1.6)
        ctx.strokeEllipse(in: CGRect(x: bx - r, y: by - r, width: r * 2, height: r * 2))
    }
    ctx.setStrokeColor(inkTone.cg(0.75))
    ctx.setLineWidth(3)
    ctx.stroke(jarRect)
    let lid = rrect(CGRect(x: jarRect.minX - 8, y: jarRect.maxY, width: jarRect.width + 16, height: 30), 6)
    washFill(ctx, lid, terraTone, rand: rand)
    ctx.addPath(lid)
    ctx.setStrokeColor(inkTone.cg(0.8))
    ctx.setLineWidth(2.6)
    ctx.strokePath()
    wobblyLine(ctx, from: CGPoint(x: jarRect.maxX + 14, y: starterLevel), to: CGPoint(x: jarRect.maxX + 44, y: starterLevel), rand: rand, width: 3, color: redTone.cg(0.8))
    drawText(ctx, "yesterday's mark", font: "Georgia-Italic", size: 22, at: CGPoint(x: jarRect.maxX + 120, y: starterLevel - 8), color: inkTone.cg(0.55))
    let spoon = CGPoint(x: cx - 250, y: sill.maxY + 60)
    ctx.setStrokeColor(steelTone.cg())
    ctx.setLineWidth(8)
    ctx.move(to: CGPoint(x: spoon.x, y: spoon.y))
    ctx.addLine(to: CGPoint(x: spoon.x - 60, y: spoon.y + 120))
    ctx.strokePath()
    ctx.setFillColor(steelTone.cg())
    ctx.fillEllipse(in: CGRect(x: spoon.x - 18, y: spoon.y - 34, width: 40, height: 52))
    flourDust(ctx, around: CGRect(x: cx - 200, y: sill.minY - 12, width: 400, height: 30), rand: rand, count: 30)
}

drawGuidePlate("guide_bakery", "The Village Bakery", "Fig. X — the warmest room in the village") { ctx, w, h, rand in
    let cx = w / 2
    let shopRect = CGRect(x: cx - 330, y: h * 0.22, width: 660, height: 380)
    washFill(ctx, rrect(shopRect, 8), RGB(r: 0.88, g: 0.82, b: 0.70), rand: rand)
    inkRect(ctx, shopRect, rand: rand, width: 3)
    let awningY = shopRect.maxY
    for i in 0..<6 {
        let ax = shopRect.minX + CGFloat(i) * shopRect.width / 6
        let scallop = CGMutablePath()
        scallop.move(to: CGPoint(x: ax, y: awningY))
        scallop.addArc(center: CGPoint(x: ax + shopRect.width / 12, y: awningY), radius: shopRect.width / 12, startAngle: .pi, endAngle: 0, clockwise: true)
        scallop.closeSubpath()
        washFill(ctx, scallop, i % 2 == 0 ? terraTone : RGB(r: 0.95, g: 0.92, b: 0.85), rand: rand)
        ctx.addPath(scallop)
        ctx.setStrokeColor(inkTone.cg(0.8))
        ctx.setLineWidth(2.4)
        ctx.strokePath()
    }
    let windowRect = CGRect(x: shopRect.minX + 40, y: shopRect.minY + 60, width: 360, height: 220)
    washFill(ctx, rrect(windowRect, 8), skyTone, rand: rand, alpha: 0.4)
    inkRect(ctx, windowRect, rand: rand, width: 2.8)
    for shelf in 0..<2 {
        let sy = windowRect.minY + 60 + CGFloat(shelf) * 100
        wobblyLine(ctx, from: CGPoint(x: windowRect.minX + 10, y: sy), to: CGPoint(x: windowRect.maxX - 10, y: sy), rand: rand, width: 5, color: RGB(r: 0.5, g: 0.36, b: 0.22).cg())
        for i in 0..<3 {
            let bx = windowRect.minX + 60 + CGFloat(i) * 120
            let mini = CGMutablePath()
            mini.addArc(center: CGPoint(x: bx, y: sy + 4), radius: 34, startAngle: .pi, endAngle: 0, clockwise: true)
            mini.closeSubpath()
            washFill(ctx, mini, shelf == 0 ? crustGold : crustDeep, rand: rand)
            ctx.addPath(mini)
            ctx.setStrokeColor(inkTone.cg(0.75))
            ctx.setLineWidth(2)
            ctx.strokePath()
        }
    }
    let door = CGRect(x: shopRect.maxX - 180, y: shopRect.minY, width: 120, height: 250)
    washFill(ctx, rrect(door, 8), RGB(r: 0.45, g: 0.30, b: 0.18), rand: rand)
    inkRect(ctx, door, rand: rand, width: 2.8)
    ctx.setFillColor(brassTone.cg())
    ctx.fillEllipse(in: CGRect(x: door.minX + 18, y: door.midY - 8, width: 16, height: 16))
    steamCurl(ctx, from: CGPoint(x: shopRect.minX + 100, y: shopRect.maxY + 40), rand: rand, count: 2)
    drawText(ctx, "BAKERY", font: "Georgia-Bold", size: 40, at: CGPoint(x: cx - 90, y: shopRect.maxY - 46), color: crustBold.cg(0.9), tracking: 8)
}
print("GUIDES DONE")

func drawBanner(_ id: String, _ index: Int) {
    let W = 1400, H = 520
    let w = CGFloat(W), h = CGFloat(H)
    let ctx = makeContext(W, H)
    let rand = Rand(UInt64(950 + index))
    paperBase(ctx, w, h, seed: UInt64(87 + index))
    plateFrame(ctx, w, h, inset: 26)
    let baseY = h * 0.28
    switch index {
    case 0:
        boardLine(ctx, y: baseY, w: w, rand: rand)
        drawBoule(ctx, cx: w * 0.3, baseY: baseY, wdt: 240, crust: crustDeep, rand: rand, slashes: 1)
        drawTinLoaf(ctx, cx: w * 0.56, baseY: baseY, wdt: 220, crust: crustGold, rand: rand)
        ctx.saveGState()
        ctx.translateBy(x: w * 0.78, y: baseY + 40)
        ctx.rotate(by: 0.45)
        let stick = rrect(CGRect(x: -190, y: -32, width: 380, height: 64), 32)
        washFill(ctx, stick, crustGold, rand: rand)
        ctx.addPath(stick)
        ctx.setStrokeColor(inkTone.cg(0.85))
        ctx.setLineWidth(2.6)
        ctx.strokePath()
        ctx.restoreGState()
        drawText(ctx, "CH. I", font: "Georgia-Bold", size: 44, at: CGPoint(x: w * 0.1, y: h * 0.62), color: inkTone.cg(0.85), tracking: 4)
    case 1:
        boardLine(ctx, y: baseY, w: w, rand: rand)
        let butter = rrect(CGRect(x: w * 0.24, y: baseY + 10, width: 190, height: 100), 10)
        washFill(ctx, butter, butterTone, rand: rand)
        ctx.addPath(butter)
        ctx.setStrokeColor(inkTone.cg(0.8))
        ctx.setLineWidth(2.6)
        ctx.strokePath()
        for i in 0..<3 {
            let egg = CGMutablePath()
            egg.addEllipse(in: CGRect(x: w * 0.48 + CGFloat(i) * 70, y: baseY + 14 + CGFloat(i % 2) * 30, width: 62, height: 78))
            washFill(ctx, egg, RGB(r: 0.93, g: 0.87, b: 0.74), rand: rand)
            ctx.addPath(egg)
            ctx.setStrokeColor(inkTone.cg(0.75))
            ctx.setLineWidth(2.2)
            ctx.strokePath()
        }
        var t: CGFloat = 0
        while t <= 1 {
            let x = w * 0.72 + t * 220
            let r = 30 + sin(t * .pi) * 18
            let strand = CGMutablePath()
            strand.addEllipse(in: CGRect(x: x - r, y: baseY + 60 + sin(t * .pi * 4) * 14 - r * 0.8, width: r * 2, height: r * 1.6))
            washFill(ctx, strand, crustGold, rand: rand)
            ctx.addPath(strand)
            ctx.setStrokeColor(inkTone.cg(0.8))
            ctx.setLineWidth(2.2)
            ctx.strokePath()
            t += 0.14
        }
        drawText(ctx, "CH. II", font: "Georgia-Bold", size: 44, at: CGPoint(x: w * 0.1, y: h * 0.62), color: inkTone.cg(0.85), tracking: 4)
    case 2:
        boardLine(ctx, y: baseY, w: w, rand: rand)
        let pin = CGPoint(x: w * 0.32, y: baseY + 60)
        ctx.setStrokeColor(RGB(r: 0.62, g: 0.46, b: 0.30).cg())
        ctx.setLineWidth(22)
        ctx.setLineCap(.round)
        ctx.move(to: CGPoint(x: pin.x - 150, y: pin.y))
        ctx.addLine(to: CGPoint(x: pin.x + 150, y: pin.y))
        ctx.strokePath()
        ctx.setLineWidth(10)
        ctx.move(to: CGPoint(x: pin.x - 200, y: pin.y))
        ctx.addLine(to: CGPoint(x: pin.x - 154, y: pin.y))
        ctx.move(to: CGPoint(x: pin.x + 154, y: pin.y))
        ctx.addLine(to: CGPoint(x: pin.x + 200, y: pin.y))
        ctx.strokePath()
        let flat = CGMutablePath()
        flat.addEllipse(in: CGRect(x: w * 0.55, y: baseY + 10, width: 280, height: 90))
        washFill(ctx, flat, crustGold, rand: rand)
        ctx.addPath(flat)
        ctx.setStrokeColor(inkTone.cg(0.85))
        ctx.setLineWidth(2.8)
        ctx.strokePath()
        for _ in 0..<8 {
            ctx.setFillColor(crustDeep.cg(0.7))
            ctx.fillEllipse(in: CGRect(x: w * 0.58 + rand.next() * 220, y: baseY + 26 + rand.next() * 50, width: 16, height: 12))
        }
        drawText(ctx, "CH. III", font: "Georgia-Bold", size: 44, at: CGPoint(x: w * 0.1, y: h * 0.62), color: inkTone.cg(0.85), tracking: 4)
    case 3:
        boardLine(ctx, y: baseY, w: w, rand: rand)
        for i in 0..<5 {
            let f = CGFloat(i) - 2
            let sx = w * 0.36 + f * 60
            ctx.saveGState()
            ctx.translateBy(x: sx, y: baseY + 20 + abs(f) * 16)
            ctx.rotate(by: f * 0.3)
            let seg = CGMutablePath()
            seg.addEllipse(in: CGRect(x: -40, y: 0, width: 80 - abs(f) * 12, height: 120 - abs(f) * 26))
            washFill(ctx, seg, abs(f) > 1.5 ? crustDeep : crustGold, rand: rand)
            ctx.addPath(seg)
            ctx.setStrokeColor(inkTone.cg(0.85))
            ctx.setLineWidth(2.4)
            ctx.strokePath()
            ctx.restoreGState()
        }
        let butter2 = rrect(CGRect(x: w * 0.66, y: baseY + 16, width: 150, height: 84), 8)
        washFill(ctx, butter2, butterTone, rand: rand)
        ctx.addPath(butter2)
        ctx.setStrokeColor(inkTone.cg(0.8))
        ctx.setLineWidth(2.4)
        ctx.strokePath()
        for k in 1..<4 {
            wobblyLine(ctx, from: CGPoint(x: w * 0.66 + 8, y: baseY + 16 + CGFloat(k) * 21), to: CGPoint(x: w * 0.66 + 142, y: baseY + 16 + CGFloat(k) * 21), rand: rand, width: 1.6, color: inkTone.cg(0.3))
        }
        drawText(ctx, "CH. IV", font: "Georgia-Bold", size: 44, at: CGPoint(x: w * 0.1, y: h * 0.62), color: inkTone.cg(0.85), tracking: 4)
    default:
        boardLine(ctx, y: baseY, w: w, rand: rand)
        let pc = CGPoint(x: w * 0.32, y: baseY + 70)
        ctx.setStrokeColor(crustBold.cg(0.97))
        ctx.setLineWidth(26)
        ctx.setLineCap(.round)
        let path = CGMutablePath()
        path.move(to: CGPoint(x: pc.x - 95, y: pc.y - 55))
        path.addCurve(to: CGPoint(x: pc.x + 95, y: pc.y - 55), control1: CGPoint(x: pc.x - 115, y: pc.y + 85), control2: CGPoint(x: pc.x + 115, y: pc.y + 85))
        path.move(to: CGPoint(x: pc.x - 92, y: pc.y - 52))
        path.addCurve(to: CGPoint(x: pc.x + 30, y: pc.y + 44), control1: CGPoint(x: pc.x - 30, y: pc.y - 90), control2: CGPoint(x: pc.x + 20, y: pc.y - 15))
        path.move(to: CGPoint(x: pc.x + 92, y: pc.y - 52))
        path.addCurve(to: CGPoint(x: pc.x - 30, y: pc.y + 44), control1: CGPoint(x: pc.x + 30, y: pc.y - 90), control2: CGPoint(x: pc.x - 20, y: pc.y - 15))
        ctx.addPath(path)
        ctx.strokePath()
        let sc = CGPoint(x: w * 0.68, y: baseY + 66)
        for k in 0..<8 {
            let a = CGFloat(k) / 8 * 2 * .pi
            ctx.saveGState()
            ctx.translateBy(x: sc.x, y: sc.y)
            ctx.rotate(by: a)
            let ray = CGMutablePath()
            ray.move(to: CGPoint(x: 0, y: 8))
            ray.addQuadCurve(to: CGPoint(x: 95, y: 0), control: CGPoint(x: 52, y: 30))
            ray.addQuadCurve(to: CGPoint(x: 0, y: -8), control: CGPoint(x: 52, y: -30))
            ray.closeSubpath()
            washFill(ctx, ray, k % 2 == 0 ? crustGold : crustGold.lighter(0.12), rand: rand)
            ctx.addPath(ray)
            ctx.setStrokeColor(inkTone.cg(0.8))
            ctx.setLineWidth(2)
            ctx.strokePath()
            ctx.restoreGState()
        }
        drawText(ctx, "CH. V", font: "Georgia-Bold", size: 44, at: CGPoint(x: w * 0.1, y: h * 0.62), color: inkTone.cg(0.85), tracking: 4)
    }
    saveJPEG(ctx, id)
}

for i in 0..<5 {
    drawBanner("banner_ch\(i + 1)", i)
}

func drawOnboarding(_ id: String, _ index: Int) {
    let W = 1200, H = 1600
    let w = CGFloat(W), h = CGFloat(H)
    let ctx = makeContext(W, H)
    let rand = Rand(UInt64(720 + index))
    paperBase(ctx, w, h, seed: UInt64(51 + index))
    plateFrame(ctx, w, h, inset: 40)
    switch index {
    case 0:
        let counterY = h * 0.34
        boardLine(ctx, y: counterY, w: w, rand: rand)
        let bowlRect = CGRect(x: w * 0.2, y: counterY + 10, width: 300, height: 170)
        let dome = CGMutablePath()
        dome.move(to: CGPoint(x: bowlRect.minX + 20, y: bowlRect.maxY - 40))
        dome.addQuadCurve(to: CGPoint(x: bowlRect.maxX - 20, y: bowlRect.maxY - 40), control: CGPoint(x: bowlRect.midX, y: bowlRect.maxY + 70))
        dome.closeSubpath()
        washFill(ctx, dome, doughPale, rand: rand)
        ctx.addPath(dome)
        ctx.setStrokeColor(inkTone.cg(0.85))
        ctx.setLineWidth(3)
        ctx.strokePath()
        let bowl = CGMutablePath()
        bowl.move(to: CGPoint(x: bowlRect.minX, y: bowlRect.maxY - 40))
        bowl.addCurve(to: CGPoint(x: bowlRect.maxX, y: bowlRect.maxY - 40), control1: CGPoint(x: bowlRect.minX + 40, y: bowlRect.minY - 40), control2: CGPoint(x: bowlRect.maxX - 40, y: bowlRect.minY - 40))
        bowl.closeSubpath()
        washFill(ctx, bowl, terraTone, rand: rand)
        ctx.addPath(bowl)
        ctx.setStrokeColor(inkTone.cg(0.9))
        ctx.setLineWidth(3.2)
        ctx.strokePath()
        let sack = CGMutablePath()
        sack.move(to: CGPoint(x: w * 0.62, y: counterY + 4))
        sack.addQuadCurve(to: CGPoint(x: w * 0.66, y: counterY + 250), control: CGPoint(x: w * 0.56, y: counterY + 160))
        sack.addQuadCurve(to: CGPoint(x: w * 0.84, y: counterY + 250), control: CGPoint(x: w * 0.75, y: counterY + 290))
        sack.addQuadCurve(to: CGPoint(x: w * 0.88, y: counterY + 4), control: CGPoint(x: w * 0.94, y: counterY + 160))
        sack.closeSubpath()
        washFill(ctx, sack, RGB(r: 0.85, g: 0.78, b: 0.64), rand: rand)
        ctx.addPath(sack)
        ctx.setStrokeColor(inkTone.cg(0.85))
        ctx.setLineWidth(3)
        ctx.strokePath()
        drawText(ctx, "FLOUR", font: "Georgia-Bold", size: 34, at: CGPoint(x: w * 0.75, y: counterY + 120), color: inkTone.cg(0.6), tracking: 4)
        flourDust(ctx, around: CGRect(x: w * 0.2, y: counterY - 16, width: w * 0.6, height: 40), rand: rand, count: 60)
        wheatSprig(ctx, at: CGPoint(x: w * 0.15, y: counterY + 240), angle: -0.2, len: 170, rand: rand)
        drawText(ctx, "PLATE THE FIRST", font: "Georgia-Bold", size: 34, at: CGPoint(x: w / 2, y: h * 0.14), color: inkTone.cg(0.8), tracking: 6)
        drawText(ctx, "a bowl, a sack, a beginning", font: "Georgia-Italic", size: 30, at: CGPoint(x: w / 2, y: h * 0.10), color: inkTone.cg(0.6))
    case 1:
        let ovenRect = CGRect(x: w * 0.16, y: h * 0.28, width: w * 0.68, height: h * 0.42)
        washFill(ctx, rrect(ovenRect, 24), RGB(r: 0.32, g: 0.28, b: 0.26), rand: rand)
        inkRect(ctx, ovenRect, rand: rand, width: 3.4)
        let door = ovenRect.insetBy(dx: 60, dy: 80)
        ctx.setFillColor(RGB(r: 0.16, g: 0.10, b: 0.07).cg())
        ctx.fill(door)
        let glow = CGGradient(colorsSpace: nil, colors: [RGB(r: 1, g: 0.62, b: 0.28).cg(0.6), RGB(r: 1, g: 0.62, b: 0.28).cg(0)] as CFArray, locations: [0, 1])!
        ctx.saveGState()
        ctx.clip(to: door)
        ctx.drawRadialGradient(glow, startCenter: CGPoint(x: door.midX, y: door.minY + 70), startRadius: 0, endCenter: CGPoint(x: door.midX, y: door.minY + 70), endRadius: 340, options: [])
        drawBoule(ctx, cx: door.midX, baseY: door.minY + 40, wdt: 320, crust: crustGold, rand: rand, slashes: 1, ear: true)
        ctx.restoreGState()
        inkRect(ctx, door, rand: rand, width: 2.8)
        steamCurl(ctx, from: CGPoint(x: door.midX, y: ovenRect.maxY + 20), rand: rand)
        for kx in [0.3, 0.5, 0.7] {
            ctx.setFillColor(brassTone.cg())
            ctx.fillEllipse(in: CGRect(x: w * CGFloat(kx) - 14, y: ovenRect.maxY + 46, width: 28, height: 28))
            ctx.setStrokeColor(inkTone.cg(0.7))
            ctx.setLineWidth(2)
            ctx.strokeEllipse(in: CGRect(x: w * CGFloat(kx) - 14, y: ovenRect.maxY + 46, width: 28, height: 28))
        }
        drawText(ctx, "PLATE THE SECOND", font: "Georgia-Bold", size: 34, at: CGPoint(x: w / 2, y: h * 0.14), color: inkTone.cg(0.8), tracking: 6)
        drawText(ctx, "watch the colour, not the clock", font: "Georgia-Italic", size: 30, at: CGPoint(x: w / 2, y: h * 0.10), color: inkTone.cg(0.6))
    default:
        let shelfY = [h * 0.30, h * 0.48, h * 0.66]
        for sy in shelfY {
            let shelf = CGRect(x: w * 0.14, y: sy, width: w * 0.72, height: 20)
            washFill(ctx, rrect(shelf, 6), RGB(r: 0.55, g: 0.40, b: 0.25), rand: rand)
            inkRect(ctx, shelf, rand: rand, width: 2.6)
        }
        drawBoule(ctx, cx: w * 0.28, baseY: shelfY[2] + 20, wdt: 170, crust: crustDeep, rand: rand, slashes: 1)
        drawTinLoaf(ctx, cx: w * 0.55, baseY: shelfY[2] + 20, wdt: 170, crust: crustGold, rand: rand)
        ctx.saveGState()
        ctx.translateBy(x: w * 0.78, y: shelfY[2] + 60)
        ctx.rotate(by: 0.4)
        let stick2 = rrect(CGRect(x: -120, y: -22, width: 240, height: 44), 22)
        washFill(ctx, stick2, crustGold, rand: rand)
        ctx.addPath(stick2)
        ctx.setStrokeColor(inkTone.cg(0.8))
        ctx.setLineWidth(2.2)
        ctx.strokePath()
        ctx.restoreGState()
        for i in 0..<3 {
            let dome = CGMutablePath()
            let bx = w * (0.26 + CGFloat(i) * 0.16)
            dome.addArc(center: CGPoint(x: bx, y: shelfY[1] + 24), radius: 52, startAngle: .pi, endAngle: 0, clockwise: true)
            dome.closeSubpath()
            washFill(ctx, dome, i == 1 ? crustDeep : crustGold, rand: rand)
            ctx.addPath(dome)
            ctx.setStrokeColor(inkTone.cg(0.8))
            ctx.setLineWidth(2.4)
            ctx.strokePath()
        }
        let jarRect = CGRect(x: w * 0.68, y: shelfY[1] + 22, width: 110, height: 140)
        ctx.setFillColor(doughPale.cg(0.9))
        ctx.fill(CGRect(x: jarRect.minX + 6, y: jarRect.minY + 6, width: jarRect.width - 12, height: 70))
        ctx.setStrokeColor(inkTone.cg(0.75))
        ctx.setLineWidth(2.6)
        ctx.stroke(jarRect)
        let lid2 = rrect(CGRect(x: jarRect.minX - 5, y: jarRect.maxY, width: jarRect.width + 10, height: 20), 5)
        washFill(ctx, lid2, terraTone, rand: rand)
        ctx.addPath(lid2)
        ctx.setStrokeColor(inkTone.cg(0.7))
        ctx.setLineWidth(2)
        ctx.strokePath()
        let sc = CGPoint(x: w * 0.5, y: shelfY[0] + 80)
        for k in 0..<8 {
            let a = CGFloat(k) / 8 * 2 * .pi
            ctx.saveGState()
            ctx.translateBy(x: sc.x, y: sc.y)
            ctx.rotate(by: a)
            let ray = CGMutablePath()
            ray.move(to: CGPoint(x: 0, y: 7))
            ray.addQuadCurve(to: CGPoint(x: 85, y: 0), control: CGPoint(x: 46, y: 27))
            ray.addQuadCurve(to: CGPoint(x: 0, y: -7), control: CGPoint(x: 46, y: -27))
            ray.closeSubpath()
            washFill(ctx, ray, k % 2 == 0 ? crustGold : crustGold.lighter(0.12), rand: rand)
            ctx.addPath(ray)
            ctx.setStrokeColor(inkTone.cg(0.75))
            ctx.setLineWidth(1.8)
            ctx.strokePath()
            ctx.restoreGState()
        }
        drawText(ctx, "PLATE THE THIRD", font: "Georgia-Bold", size: 34, at: CGPoint(x: w / 2, y: h * 0.14), color: inkTone.cg(0.8), tracking: 6)
        drawText(ctx, "the window fills with your work", font: "Georgia-Italic", size: 30, at: CGPoint(x: w / 2, y: h * 0.10), color: inkTone.cg(0.6))
    }
    saveJPEG(ctx, id)
}

drawOnboarding("onboard_1", 0)
drawOnboarding("onboard_2", 1)
drawOnboarding("onboard_3", 2)
print("ALL ART DONE")
