import SwiftUI

struct BakeArtImage: View {
    let name: String
    var contentMode: ContentMode = .fill

    var body: some View {
        if let ui = BakeArtImage.load(name) {
            Image(uiImage: ui)
                .resizable()
                .aspectRatio(contentMode: contentMode)
        } else {
            ZStack {
                LinearGradient(colors: [BakeTheme.butter, BakeTheme.wheat], startPoint: .top, endPoint: .bottom)
                BIcon(kind: .wheatStalk, size: 42, color: BakeTheme.crust.opacity(0.6))
            }
        }
    }

    static var cache = NSCache<NSString, UIImage>()

    static func load(_ name: String) -> UIImage? {
        if let hit = cache.object(forKey: name as NSString) { return hit }
        for ext in ["jpg", "png"] {
            if let url = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: "Art"),
               let img = UIImage(contentsOfFile: url.path) {
                cache.setObject(img, forKey: name as NSString)
                return img
            }
        }
        return nil
    }
}

struct BakeCard: ViewModifier {
    var padding: CGFloat = 16
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(BakeTheme.paper)
                    .shadow(color: BakeTheme.cardShadow, radius: 7, x: 0, y: 3)
            )
    }
}

extension View {
    func bakeCard(padding: CGFloat = 16) -> some View {
        modifier(BakeCard(padding: padding))
    }
}

struct BakeSectionHeader: View {
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(BakeTheme.title(21))
                .foregroundColor(BakeTheme.ink)
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(BakeTheme.body(13))
                    .foregroundColor(BakeTheme.inkFaint)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct BakeStatChip: View {
    let icon: BIconKind
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 5) {
            BIcon(kind: icon, size: 20, color: BakeTheme.terraDeep)
            Text(value)
                .font(BakeTheme.title(16))
                .foregroundColor(BakeTheme.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(label)
                .font(BakeTheme.body(10))
                .foregroundColor(BakeTheme.inkFaint)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 13, style: .continuous).fill(BakeTheme.cream))
    }
}

struct BakeProgressRing: View {
    let progress: Double
    var size: CGFloat = 60
    var lineWidth: CGFloat = 7
    var color: Color = BakeTheme.wheat

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: CGFloat(progress.bakeClamped(0, 1)))
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .frame(width: size, height: size)
    }
}

struct BakeProgressBar: View {
    let progress: Double
    var color: Color = BakeTheme.wheat
    var height: CGFloat = 8

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(color.opacity(0.18))
                Capsule().fill(color)
                    .frame(width: max(height, geo.size.width * CGFloat(progress.bakeClamped(0, 1))))
            }
        }
        .frame(height: height)
    }
}

struct BakePrimaryButton: ButtonStyle {
    var color: Color = BakeTheme.terracotta

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(BakeTheme.heading(16))
            .foregroundColor(BakeTheme.flour)
            .padding(.vertical, 13)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(color)
                    .shadow(color: BakeTheme.cardShadow, radius: 4, x: 0, y: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct BakeSoftButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(BakeTheme.heading(15))
            .foregroundColor(BakeTheme.terraDeep)
            .padding(.vertical, 11)
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 13, style: .continuous).fill(BakeTheme.terracotta.opacity(0.13)))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct BakeConfettiPiece: Identifiable {
    let id = UUID()
    var x: CGFloat
    var delay: Double
    var color: Color
    var spin: Double
    var size: CGFloat
}

struct BakeConfetti: View {
    @State private var fall = false
    let pieces: [BakeConfettiPiece]

    init(seed: UInt64 = 7) {
        var rng = BakeSeededRandom(seed: seed)
        var result: [BakeConfettiPiece] = []
        let colors = [BakeTheme.wheat, BakeTheme.terracotta, BakeTheme.sage, BakeTheme.butter, BakeTheme.berry]
        for i in 0..<36 {
            result.append(BakeConfettiPiece(
                x: rng.next(),
                delay: Double(rng.next()) * 0.5,
                color: colors[i % colors.count],
                spin: Double(rng.next()) * 720 - 360,
                size: 5 + rng.next() * 6))
        }
        pieces = result
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(pieces) { piece in
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(piece.color)
                        .frame(width: piece.size, height: piece.size * 0.62)
                        .rotationEffect(.degrees(fall ? piece.spin : 0))
                        .position(x: piece.x * geo.size.width, y: fall ? geo.size.height + 30 : -40)
                        .animation(.easeIn(duration: 1.6).delay(piece.delay), value: fall)
                }
            }
        }
        .allowsHitTesting(false)
        .onAppear { fall = true }
    }
}

struct BakeCelebrationBanner: View {
    let text: String
    let dismiss: () -> Void

    var body: some View {
        VStack {
            HStack(spacing: 10) {
                BIcon(kind: .star, size: 20, color: BakeTheme.butter)
                Text(text)
                    .font(BakeTheme.heading(14))
                    .foregroundColor(BakeTheme.flour)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(BakeTheme.terraDeep)
                    .shadow(color: Color.black.opacity(0.25), radius: 8, x: 0, y: 4)
            )
            .padding(.horizontal, 20)
            .padding(.top, 8)
            Spacer()
        }
        .transition(.move(edge: .top).combined(with: .opacity))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) { dismiss() }
        }
        .onTapGesture { dismiss() }
    }
}

struct BakeLockBadge: View {
    let rankName: String

    var body: some View {
        HStack(spacing: 5) {
            BIcon(kind: .lock, size: 12, color: BakeTheme.inkFaint)
            Text(rankName)
                .font(BakeTheme.body(10))
                .foregroundColor(BakeTheme.inkFaint)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Capsule().fill(BakeTheme.ink.opacity(0.08)))
    }
}

struct StarRow: View {
    let stars: Int
    var size: CGFloat = 16

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<3, id: \.self) { i in
                BIcon(kind: .star, size: size, color: i < stars ? BakeTheme.wheat : BakeTheme.ink.opacity(0.14))
            }
        }
    }
}

struct BakeAwardEmblem: View {
    let index: Int
    let earned: Bool
    var size: CGFloat = 56

    var body: some View {
        Canvas { ctx, canvasSize in
            let c = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
            let r = min(canvasSize.width, canvasSize.height) * 0.42
            let base = earned ? BakeTheme.wheat : Color(red: 0.74, green: 0.71, blue: 0.66)
            let dark = earned ? BakeTheme.wheatDeep : Color(red: 0.57, green: 0.54, blue: 0.50)
            let light = earned ? BakeTheme.butter : Color(red: 0.83, green: 0.81, blue: 0.77)
            var rim = Path()
            rim.addEllipse(in: CGRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2))
            ctx.fill(rim, with: .radialGradient(Gradient(colors: [light, base, dark]), center: CGPoint(x: c.x - r * 0.3, y: c.y - r * 0.3), startRadius: 0, endRadius: r * 1.6))
            ctx.stroke(rim, with: .color(dark), lineWidth: 1.6)
            for i in 0..<16 {
                let a = CGFloat(i) / 16 * 2 * .pi
                var notch = Path()
                notch.move(to: CGPoint(x: c.x + cos(a) * r * 0.86, y: c.y + sin(a) * r * 0.86))
                notch.addLine(to: CGPoint(x: c.x + cos(a) * r * 0.95, y: c.y + sin(a) * r * 0.95))
                ctx.stroke(notch, with: .color(dark.opacity(0.5)), lineWidth: 1)
            }
            var emblem = Path()
            switch index % 5 {
            case 0:
                emblem.addArc(center: CGPoint(x: c.x, y: c.y + r * 0.1), radius: r * 0.42, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 0), clockwise: false)
                emblem.closeSubpath()
                emblem.move(to: CGPoint(x: c.x - r * 0.22, y: c.y - r * 0.06))
                emblem.addLine(to: CGPoint(x: c.x - r * 0.1, y: c.y - r * 0.28))
                emblem.move(to: CGPoint(x: c.x + 0, y: c.y - r * 0.06))
                emblem.addLine(to: CGPoint(x: c.x + r * 0.12, y: c.y - r * 0.28))
            case 1:
                emblem.move(to: CGPoint(x: c.x, y: c.y + r * 0.5))
                emblem.addLine(to: CGPoint(x: c.x, y: c.y - r * 0.5))
                for i in 0..<3 {
                    let y = c.y - r * 0.34 + CGFloat(i) * r * 0.24
                    emblem.addEllipse(in: CGRect(x: c.x - r * 0.3, y: y, width: r * 0.24, height: r * 0.16))
                    emblem.addEllipse(in: CGRect(x: c.x + r * 0.06, y: y, width: r * 0.24, height: r * 0.16))
                }
            case 2:
                emblem.addEllipse(in: CGRect(x: c.x - r * 0.36, y: c.y - r * 0.5, width: r * 0.72, height: r * 1.0))
                emblem.move(to: CGPoint(x: c.x - r * 0.2, y: c.y - r * 0.24))
                emblem.addLine(to: CGPoint(x: c.x + r * 0.2, y: c.y - r * 0.1))
                emblem.move(to: CGPoint(x: c.x - r * 0.2, y: c.y + 0))
                emblem.addLine(to: CGPoint(x: c.x + r * 0.2, y: c.y + r * 0.14))
            case 3:
                emblem.addRoundedRect(in: CGRect(x: c.x - r * 0.42, y: c.y - r * 0.34, width: r * 0.84, height: r * 0.68), cornerSize: CGSize(width: r * 0.12, height: r * 0.12))
                emblem.addEllipse(in: CGRect(x: c.x - r * 0.18, y: c.y - r * 0.1, width: r * 0.36, height: r * 0.2))
            default:
                for i in 0..<5 {
                    let ang = CGFloat(i) * 2 * .pi / 5 - .pi / 2
                    let pt = CGPoint(x: c.x + cos(ang) * r * 0.5, y: c.y + sin(ang) * r * 0.5)
                    if i == 0 { emblem.move(to: pt) } else { emblem.addLine(to: pt) }
                    let ang2 = ang + .pi / 5
                    emblem.addLine(to: CGPoint(x: c.x + cos(ang2) * r * 0.22, y: c.y + sin(ang2) * r * 0.22))
                }
                emblem.closeSubpath()
            }
            ctx.stroke(emblem, with: .color(dark), lineWidth: 1.8)
            if !earned {
                var veil = Path()
                veil.addEllipse(in: CGRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2))
                ctx.fill(veil, with: .color(BakeTheme.cream.opacity(0.45)))
            }
        }
        .frame(width: size, height: size)
    }
}

struct BakeDivider: View {
    var body: some View {
        HStack(spacing: 10) {
            Rectangle().fill(BakeTheme.ink.opacity(0.12)).frame(height: 1)
            BIcon(kind: .wheatStalk, size: 13, color: BakeTheme.wheat)
            Rectangle().fill(BakeTheme.ink.opacity(0.12)).frame(height: 1)
        }
    }
}
