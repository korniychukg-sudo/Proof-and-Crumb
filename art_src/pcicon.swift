import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

let outPath = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "AppIcon-1024.png"
let S: CGFloat = 1024
let cs = CGColorSpace(name: CGColorSpace.sRGB)!
let ctx = CGContext(data: nil, width: 1024, height: 1024, bitsPerComponent: 8, bytesPerRow: 0, space: cs, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
ctx.setAllowsAntialiasing(true)

final class R {
    var state: UInt64 = 733
    func next() -> CGFloat {
        state = state &* 2862933555777941757 &+ 3037000493
        return CGFloat((state >> 33) & 0xFFFFFF) / CGFloat(0xFFFFFF)
    }
    func range(_ lo: CGFloat, _ hi: CGFloat) -> CGFloat { lo + next() * (hi - lo) }
}
let rand = R()

func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> CGColor {
    CGColor(red: r, green: g, blue: b, alpha: a)
}

func grad(_ stops: [(CGFloat, CGColor)]) -> CGGradient {
    CGGradient(colorsSpace: cs, colors: stops.map { $0.1 } as CFArray, locations: stops.map { $0.0 })!
}

let bg = grad([
    (0.0, rgb(0.11, 0.06, 0.04)),
    (0.55, rgb(0.19, 0.11, 0.06)),
    (1.0, rgb(0.28, 0.17, 0.10)),
])
ctx.drawLinearGradient(bg, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: S), options: [])
let warmGlow = grad([(0.0, rgb(1.0, 0.74, 0.38, 0.32)), (0.6, rgb(1.0, 0.62, 0.3, 0.08)), (1.0, rgb(1.0, 0.62, 0.3, 0.0))])
ctx.drawRadialGradient(warmGlow, startCenter: CGPoint(x: S * 0.42, y: S * 0.60), startRadius: 0, endCenter: CGPoint(x: S * 0.45, y: S * 0.56), endRadius: S * 0.72, options: [])

for _ in 0..<24 {
    let gy = rand.next() * S
    ctx.setStrokeColor(rgb(0.08, 0.04, 0.02, rand.range(0.08, 0.2)))
    ctx.setLineWidth(rand.range(1.5, 3.5))
    ctx.move(to: CGPoint(x: 0, y: gy))
    var x: CGFloat = 0
    var yy = gy
    while x < S {
        x += rand.range(90, 200)
        yy += rand.range(-4, 4)
        ctx.addLine(to: CGPoint(x: x, y: yy))
    }
    ctx.strokePath()
}

let c = CGPoint(x: S * 0.5, y: S * 0.52)
let br: CGFloat = S * 0.375

ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -26), blur: 70, color: rgb(0, 0, 0, 0.7))
ctx.setFillColor(rgb(0.2, 0.1, 0.05))
ctx.fillEllipse(in: CGRect(x: c.x - br, y: c.y - br, width: br * 2, height: br * 2))
ctx.restoreGState()

let loaf = CGPath(ellipseIn: CGRect(x: c.x - br, y: c.y - br, width: br * 2, height: br * 2), transform: nil)
ctx.saveGState()
ctx.addPath(loaf)
ctx.clip()

let lightC = CGPoint(x: c.x - br * 0.22, y: c.y + br * 0.26)
let crust = grad([
    (0.0, rgb(0.97, 0.80, 0.47)),
    (0.34, rgb(0.92, 0.66, 0.30)),
    (0.62, rgb(0.80, 0.48, 0.17)),
    (0.84, rgb(0.60, 0.31, 0.10)),
    (1.0, rgb(0.42, 0.19, 0.06)),
])
ctx.drawRadialGradient(crust, startCenter: lightC, startRadius: 0, endCenter: c, endRadius: br * 1.06, options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])

for _ in 0..<420 {
    let a = rand.next() * 2 * .pi
    let rr = rand.next()
    let px = c.x + cos(a) * br * rr
    let py = c.y + sin(a) * br * rr
    let d = rand.range(2, 6)
    let dark = rand.next() > 0.5
    ctx.setFillColor(dark ? rgb(0.40, 0.19, 0.06, rand.range(0.05, 0.16)) : rgb(1.0, 0.85, 0.55, rand.range(0.04, 0.12)))
    ctx.fillEllipse(in: CGRect(x: px, y: py, width: d, height: d * 0.8))
}

for _ in 0..<26 {
    let a = rand.next() * 2 * .pi
    let r0 = rand.range(0.72, 0.97)
    var px = c.x + cos(a) * br * r0
    var py = c.y + sin(a) * br * r0
    let crack = CGMutablePath()
    crack.move(to: CGPoint(x: px, y: py))
    let steps = 3
    let ang0 = a + .pi / 2 + rand.range(-0.5, 0.5)
    for _ in 0..<steps {
        px += cos(ang0 + rand.range(-0.5, 0.5)) * rand.range(12, 30)
        py += sin(ang0 + rand.range(-0.5, 0.5)) * rand.range(12, 30)
        crack.addLine(to: CGPoint(x: px, y: py))
    }
    ctx.addPath(crack)
    ctx.setStrokeColor(rgb(0.34, 0.15, 0.05, rand.range(0.45, 0.75)))
    ctx.setLineWidth(rand.range(2.5, 4.5))
    ctx.setLineCap(.round)
    ctx.strokePath()
}

func scoreCut(_ from: CGPoint, _ to: CGPoint, bulge: CGFloat, width: CGFloat) {
    let mid = CGPoint(x: (from.x + to.x) / 2, y: (from.y + to.y) / 2)
    let dx = to.x - from.x
    let dy = to.y - from.y
    let len = max(1, hypot(dx, dy))
    let nx = -dy / len
    let ny = dx / len
    let ctrl = CGPoint(x: mid.x + nx * bulge, y: mid.y + ny * bulge)
    let cut = CGMutablePath()
    cut.move(to: from)
    cut.addQuadCurve(to: to, control: ctrl)
    let band = cut.copy(strokingWithWidth: width, lineCap: .round, lineJoin: .round, miterLimit: 10)

    ctx.saveGState()
    ctx.addPath(band)
    ctx.clip()
    let crumb = grad([
        (0.0, rgb(0.66, 0.42, 0.18)),
        (0.4, rgb(0.94, 0.80, 0.55)),
        (0.75, rgb(0.99, 0.91, 0.70)),
        (1.0, rgb(0.93, 0.80, 0.56)),
    ])
    ctx.drawLinearGradient(crumb, start: CGPoint(x: from.x + nx * width * 0.5, y: from.y + ny * width * 0.5), end: CGPoint(x: from.x - nx * width * 0.6, y: from.y - ny * width * 0.6), options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
    for _ in 0..<26 {
        let t = rand.next()
        let bx = from.x + dx * t + nx * rand.range(-width * 0.3, width * 0.3)
        let by = from.y + dy * t + ny * rand.range(-width * 0.3, width * 0.3)
        let d = rand.range(2, 5)
        ctx.setFillColor(rgb(0.6, 0.42, 0.22, rand.range(0.25, 0.5)))
        ctx.fillEllipse(in: CGRect(x: bx, y: by, width: d, height: d * 0.8))
    }
    ctx.restoreGState()

    ctx.addPath(band)
    ctx.setStrokeColor(rgb(0.30, 0.12, 0.04, 0.55))
    ctx.setLineWidth(5)
    ctx.strokePath()

    let lip = CGMutablePath()
    lip.move(to: CGPoint(x: from.x + nx * width * 0.52, y: from.y + ny * width * 0.52))
    lip.addQuadCurve(to: CGPoint(x: to.x + nx * width * 0.52, y: to.y + ny * width * 0.52),
                     control: CGPoint(x: ctrl.x + nx * width * 0.55, y: ctrl.y + ny * width * 0.55))
    ctx.addPath(lip)
    ctx.setStrokeColor(rgb(1.0, 0.90, 0.62, 0.8))
    ctx.setLineWidth(6)
    ctx.setLineCap(.round)
    ctx.strokePath()
}

let sq: CGFloat = br * 0.52
scoreCut(CGPoint(x: c.x - sq, y: c.y + sq * 0.9), CGPoint(x: c.x + sq * 0.9, y: c.y + sq), bulge: -br * 0.12, width: 46)
scoreCut(CGPoint(x: c.x + sq, y: c.y + sq * 0.85), CGPoint(x: c.x + sq * 0.9, y: c.y - sq), bulge: -br * 0.12, width: 44)
scoreCut(CGPoint(x: c.x + sq * 0.85, y: c.y - sq), CGPoint(x: c.x - sq, y: c.y - sq * 0.9), bulge: -br * 0.12, width: 46)
scoreCut(CGPoint(x: c.x - sq * 0.95, y: c.y - sq * 0.9), CGPoint(x: c.x - sq * 0.9, y: c.y + sq * 0.9), bulge: -br * 0.12, width: 44)

for _ in 0..<30 {
    let a = rand.next() * 2 * .pi
    let r0 = rand.range(0.0, 0.62)
    let px = c.x + cos(a) * br * r0
    let py = c.y + sin(a) * br * r0
    let cluster = Int(rand.range(5, 16))
    for _ in 0..<cluster {
        let d = rand.range(2, 5.5)
        ctx.setFillColor(rgb(0.99, 0.97, 0.92, rand.range(0.3, 0.85)))
        ctx.fillEllipse(in: CGRect(x: px + rand.range(-30, 30), y: py + rand.range(-22, 22), width: d, height: d * 0.8))
    }
}
let flourPatch = grad([(0.0, rgb(0.99, 0.97, 0.92, 0.4)), (1.0, rgb(0.99, 0.97, 0.92, 0.0))])
ctx.drawRadialGradient(flourPatch, startCenter: CGPoint(x: c.x - br * 0.1, y: c.y + br * 0.1), startRadius: 0, endCenter: CGPoint(x: c.x - br * 0.1, y: c.y + br * 0.1), endRadius: br * 0.4, options: [])

let edgeShade = grad([(0.0, rgb(0.3, 0.12, 0.03, 0.0)), (0.82, rgb(0.3, 0.12, 0.03, 0.0)), (1.0, rgb(0.25, 0.09, 0.02, 0.55))])
ctx.drawRadialGradient(edgeShade, startCenter: c, startRadius: 0, endCenter: c, endRadius: br, options: [])

let rimArc = CGMutablePath()
rimArc.addArc(center: c, radius: br - 9, startAngle: .pi * 0.42, endAngle: .pi * 1.02, clockwise: false)
ctx.saveGState()
ctx.setShadow(offset: .zero, blur: 14, color: rgb(1.0, 0.9, 0.6, 0.55))
ctx.addPath(rimArc)
ctx.setStrokeColor(rgb(1.0, 0.93, 0.68, 0.65))
ctx.setLineWidth(9)
ctx.setLineCap(.round)
ctx.strokePath()
ctx.restoreGState()
ctx.restoreGState()

for _ in 0..<6 {
    let a = rand.range(CGFloat.pi * 1.05, CGFloat.pi * 1.95)
    let d = rand.range(10, 18)
    let px = c.x + cos(a) * br * rand.range(1.06, 1.22)
    let py = c.y + sin(a) * br * rand.range(1.06, 1.22)
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -3), blur: 7, color: rgb(0, 0, 0, 0.5))
    ctx.setFillColor(rgb(0.78, 0.5, 0.22))
    ctx.fillEllipse(in: CGRect(x: px, y: py, width: d, height: d * 0.7))
    ctx.restoreGState()
}
for _ in 0..<50 {
    let a = rand.next() * 2 * .pi
    let px = c.x + cos(a) * br * rand.range(1.02, 1.35)
    let py = c.y + sin(a) * br * rand.range(1.02, 1.35)
    let d = rand.range(1.5, 4)
    ctx.setFillColor(rgb(0.98, 0.95, 0.88, rand.range(0.2, 0.6)))
    ctx.fillEllipse(in: CGRect(x: px, y: py, width: d, height: d * 0.8))
}

var steamX = c.x - 60
for k in 0..<3 {
    let sy = c.y + br + 26
    let curl = CGMutablePath()
    curl.move(to: CGPoint(x: steamX, y: sy))
    curl.addCurve(to: CGPoint(x: steamX + 34, y: sy + 130 + CGFloat(k) * 18),
                  control1: CGPoint(x: steamX - 50, y: sy + 52),
                  control2: CGPoint(x: steamX + 74, y: sy + 88))
    ctx.saveGState()
    ctx.setShadow(offset: .zero, blur: 20, color: rgb(1, 0.95, 0.85, 0.45))
    ctx.addPath(curl)
    ctx.setStrokeColor(rgb(1.0, 0.96, 0.88, 0.42 - CGFloat(k) * 0.08))
    ctx.setLineWidth(12 - CGFloat(k) * 2)
    ctx.setLineCap(.round)
    ctx.strokePath()
    ctx.restoreGState()
    steamX += 62
}

let vin = grad([(0.0, rgb(0, 0, 0, 0)), (1.0, rgb(0.03, 0.01, 0.0, 0.45))])
ctx.drawRadialGradient(vin, startCenter: CGPoint(x: S / 2, y: S / 2), startRadius: S * 0.44, endCenter: CGPoint(x: S / 2, y: S / 2), endRadius: S * 0.76, options: [.drawsAfterEndLocation])

let img = ctx.makeImage()!
let url = URL(fileURLWithPath: outPath) as CFURL
let dest = CGImageDestinationCreateWithURL(url, UTType.png.identifier as CFString, 1, nil)!
CGImageDestinationAddImage(dest, img, nil)
CGImageDestinationFinalize(dest)
print("icon written")
