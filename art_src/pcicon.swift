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
    var state: UInt64 = 971
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

let grad = CGGradient(colorsSpace: cs, colors: [rgb(0.97, 0.92, 0.82), rgb(0.93, 0.85, 0.70), rgb(0.83, 0.68, 0.48)] as CFArray, locations: [0, 0.55, 1])!
ctx.drawRadialGradient(grad, startCenter: CGPoint(x: S * 0.5, y: S * 0.62), startRadius: 0, endCenter: CGPoint(x: S * 0.5, y: S * 0.5), endRadius: S * 0.8, options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])

for _ in 0..<900 {
    let x = rand.next() * S
    let y = rand.next() * S
    let d = rand.range(1.5, 4)
    ctx.setFillColor(rgb(0.35, 0.24, 0.14, rand.range(0.02, 0.06)))
    ctx.fill(CGRect(x: x, y: y, width: d, height: d))
}

let boardY = S * 0.20
ctx.setFillColor(rgb(0.55, 0.38, 0.22))
ctx.fill(CGRect(x: 0, y: boardY - 60, width: S, height: 70))
ctx.setStrokeColor(rgb(0.35, 0.22, 0.11, 0.7))
ctx.setLineWidth(6)
ctx.move(to: CGPoint(x: 0, y: boardY + 10))
ctx.addLine(to: CGPoint(x: S, y: boardY + 10))
ctx.strokePath()
for _ in 0..<10 {
    let gy = boardY - 55 + rand.next() * 55
    ctx.setStrokeColor(rgb(0.35, 0.22, 0.11, rand.range(0.15, 0.3)))
    ctx.setLineWidth(3)
    ctx.move(to: CGPoint(x: 0, y: gy))
    ctx.addLine(to: CGPoint(x: S, y: gy + rand.range(-8, 8)))
    ctx.strokePath()
}

let c = CGPoint(x: S * 0.5, y: boardY + 8)
let wdt: CGFloat = 640
ctx.setFillColor(rgb(0, 0, 0, 0.20))
ctx.fillEllipse(in: CGRect(x: c.x - wdt * 0.52, y: c.y - 36, width: wdt * 1.04, height: 64))

let dome = CGMutablePath()
dome.move(to: CGPoint(x: c.x - wdt / 2, y: c.y))
dome.addCurve(to: CGPoint(x: c.x + wdt / 2, y: c.y),
              control1: CGPoint(x: c.x - wdt * 0.54, y: c.y + wdt * 0.78),
              control2: CGPoint(x: c.x + wdt * 0.54, y: c.y + wdt * 0.78))
dome.closeSubpath()
ctx.saveGState()
ctx.addPath(dome)
ctx.clip()
let crustGrad = CGGradient(colorsSpace: cs, colors: [rgb(0.87, 0.66, 0.38), rgb(0.72, 0.47, 0.22), rgb(0.55, 0.33, 0.14)] as CFArray, locations: [0, 0.6, 1])!
ctx.drawLinearGradient(crustGrad, start: CGPoint(x: c.x, y: c.y + wdt * 0.6), end: CGPoint(x: c.x, y: c.y - 20), options: [])
ctx.setFillColor(rgb(1, 0.96, 0.86, 0.25))
ctx.fillEllipse(in: CGRect(x: c.x - 200, y: c.y + 260, width: 300, height: 120))
for _ in 0..<40 {
    let x = c.x + rand.range(-300, 300)
    let y = c.y + rand.range(20, 380)
    ctx.setFillColor(rgb(0.45, 0.26, 0.10, rand.range(0.06, 0.16)))
    ctx.fillEllipse(in: CGRect(x: x, y: y, width: rand.range(6, 18), height: rand.range(4, 10)))
}
ctx.restoreGState()
ctx.addPath(dome)
ctx.setStrokeColor(rgb(0.25, 0.15, 0.07))
ctx.setLineWidth(12)
ctx.strokePath()

ctx.setStrokeColor(rgb(0.94, 0.88, 0.75))
ctx.setLineWidth(34)
ctx.setLineCap(.round)
ctx.move(to: CGPoint(x: c.x - 190, y: c.y + 180))
ctx.addQuadCurve(to: CGPoint(x: c.x + 190, y: c.y + 280), control: CGPoint(x: c.x + 20, y: c.y + 260))
ctx.strokePath()
ctx.setStrokeColor(rgb(0.55, 0.33, 0.14))
ctx.setLineWidth(12)
ctx.move(to: CGPoint(x: c.x - 180, y: c.y + 192))
ctx.addQuadCurve(to: CGPoint(x: c.x + 180, y: c.y + 290), control: CGPoint(x: c.x + 16, y: c.y + 272))
ctx.strokePath()

for _ in 0..<50 {
    let x = c.x + rand.range(-420, 420)
    let y = boardY + rand.range(6, 60)
    let d = rand.range(4, 10)
    ctx.setFillColor(rgb(0.99, 0.98, 0.94, rand.range(0.5, 0.95)))
    ctx.fillEllipse(in: CGRect(x: x, y: y, width: d, height: d * 0.8))
}

func wheat(_ x: CGFloat, _ y: CGFloat, _ angle: CGFloat) {
    ctx.saveGState()
    ctx.translateBy(x: x, y: y)
    ctx.rotate(by: angle)
    ctx.setStrokeColor(rgb(0.72, 0.52, 0.20))
    ctx.setLineWidth(10)
    ctx.move(to: .zero)
    ctx.addLine(to: CGPoint(x: 0, y: 260))
    ctx.strokePath()
    for i in 0..<6 {
        let gy = 110 + CGFloat(i) * 28
        for side in [-1.0, 1.0] {
            ctx.setFillColor(rgb(0.85, 0.64, 0.26))
            ctx.fillEllipse(in: CGRect(x: CGFloat(side) * 8 - (side < 0 ? 40 : 0), y: gy, width: 40, height: 22))
            ctx.setStrokeColor(rgb(0.45, 0.30, 0.12, 0.8))
            ctx.setLineWidth(3)
            ctx.strokeEllipse(in: CGRect(x: CGFloat(side) * 8 - (side < 0 ? 40 : 0), y: gy, width: 40, height: 22))
        }
    }
    ctx.restoreGState()
}
wheat(S * 0.13, boardY + 20, -0.18)
wheat(S * 0.87, boardY + 20, 0.18)

var steamX = c.x - 60
for k in 0..<3 {
    let curl = CGMutablePath()
    let sy = c.y + wdt * 0.62 + 40
    curl.move(to: CGPoint(x: steamX, y: sy))
    curl.addCurve(to: CGPoint(x: steamX + 26, y: sy + 150),
                  control1: CGPoint(x: steamX - 50, y: sy + 60),
                  control2: CGPoint(x: steamX + 70, y: sy + 100))
    ctx.addPath(curl)
    ctx.setStrokeColor(rgb(0.4, 0.3, 0.2, 0.4 - CGFloat(k) * 0.08))
    ctx.setLineWidth(16)
    ctx.setLineCap(.round)
    ctx.strokePath()
    steamX += 62
}

let vGrad = CGGradient(colorsSpace: cs, colors: [rgb(0, 0, 0, 0), rgb(0.25, 0.12, 0.04, 0.22)] as CFArray, locations: [0, 1])!
ctx.drawRadialGradient(vGrad, startCenter: CGPoint(x: S / 2, y: S / 2), startRadius: S * 0.4, endCenter: CGPoint(x: S / 2, y: S / 2), endRadius: S * 0.74, options: [.drawsAfterEndLocation])

let img = ctx.makeImage()!
let url = URL(fileURLWithPath: outPath) as CFURL
let dest = CGImageDestinationCreateWithURL(url, UTType.png.identifier as CFString, 1, nil)!
CGImageDestinationAddImage(dest, img, nil)
CGImageDestinationFinalize(dest)
print("icon written")
