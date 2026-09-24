import CoreImage.CIFilterBuiltins
import SwiftUI
import UIKit

enum QRModuleStyle: String, CaseIterable, Identifiable {
    case square
    case rounded
    case dot

    var id: String { rawValue }

    var title: String {
        switch self {
        case .square: return L10n.t("qr.module.square")
        case .rounded: return L10n.t("qr.module.rounded")
        case .dot: return L10n.t("qr.module.dot")
        }
    }

    var systemImage: String {
        switch self {
        case .square: return "square.fill"
        case .rounded: return "circle.fill"
        case .dot: return "circle.fill"
        }
    }
}

enum QRFrameStyle: String, CaseIterable, Identifiable {
    case none
    case thin
    case rounded
    case bold
    case double

    var id: String { rawValue }

    var title: String {
        switch self {
        case .none: return L10n.t("qr.frame.none")
        case .thin: return L10n.t("qr.frame.thin")
        case .rounded: return L10n.t("qr.frame.rounded")
        case .bold: return L10n.t("qr.frame.bold")
        case .double: return L10n.t("qr.frame.double")
        }
    }
}

enum QRCodeGenerator {
    private static let context = CIContext(options: [.useSoftwareRenderer: false])

    static func image(
        from string: String,
        pixelSize: CGFloat = 512,
        correctionLevel: String = "M",
        foreground: UIColor = .black,
        background: UIColor = .white,
        moduleStyle: QRModuleStyle = .square,
        frameStyle: QRFrameStyle = .none,
        frameColor: UIColor? = nil
    ) -> UIImage? {
        guard !string.isEmpty else { return nil }

        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        filter.correctionLevel = correctionLevel

        guard let output = filter.outputImage else { return nil }

        let extent = output.extent.integral
        let modules = Int(extent.width)
        guard modules > 0 else { return nil }

        var bits = [UInt8](repeating: 0, count: modules * modules)
        context.render(
            output,
            toBitmap: &bits,
            rowBytes: modules,
            bounds: extent,
            format: .L8,
            colorSpace: CGColorSpaceCreateDeviceGray()
        )

        let size = max(pixelSize, CGFloat(modules))
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size), format: format)
        return renderer.image { ctx in
            let cg = ctx.cgContext
            background.setFill()
            cg.fill(CGRect(origin: .zero, size: CGSize(width: size, height: size)))

            let moduleSize = size / CGFloat(modules)
            foreground.setFill()

            for y in 0..<modules {
                for x in 0..<modules {
                    // L8: 0 = black (module), 255 = white
                    let isDark = bits[y * modules + x] < 128
                    guard isDark else { continue }

                    let keepSquare = isFinderPattern(x: x, y: y, modules: modules)
                    let style = keepSquare ? QRModuleStyle.square : moduleStyle
                    let rect = CGRect(
                        x: CGFloat(x) * moduleSize,
                        y: CGFloat(y) * moduleSize,
                        width: moduleSize,
                        height: moduleSize
                    )
                    drawModule(in: rect, style: style, context: cg)
                }
            }

            drawFrame(
                style: frameStyle,
                color: frameColor ?? foreground,
                in: CGRect(origin: .zero, size: CGSize(width: size, height: size)),
                moduleSize: moduleSize,
                context: cg
            )
        }
    }

    /// Finder patterns (3 coins) restent carrés pour une meilleure lecture.
    private static func isFinderPattern(x: Int, y: Int, modules: Int) -> Bool {
        let inTL = x < 7 && y < 7
        let inTR = x >= modules - 7 && y < 7
        let inBL = x < 7 && y >= modules - 7
        return inTL || inTR || inBL
    }

    private static func drawModule(in rect: CGRect, style: QRModuleStyle, context: CGContext) {
        switch style {
        case .square:
            context.fill(rect)
        case .rounded:
            let inset = rect.width * 0.08
            let r = UIBezierPath(roundedRect: rect.insetBy(dx: inset, dy: inset), cornerRadius: rect.width * 0.35)
            context.addPath(r.cgPath)
            context.fillPath()
        case .dot:
            let inset = rect.width * 0.22
            let r = UIBezierPath(ovalIn: rect.insetBy(dx: inset, dy: inset))
            context.addPath(r.cgPath)
            context.fillPath()
        }
    }

    private static func drawFrame(
        style: QRFrameStyle,
        color: UIColor,
        in bounds: CGRect,
        moduleSize: CGFloat,
        context: CGContext
    ) {
        guard style != .none else { return }
        color.setStroke()
        context.setLineJoin(.miter)

        switch style {
        case .none:
            break
        case .thin:
            let inset = moduleSize * 0.35
            context.setLineWidth(max(moduleSize * 0.35, 1.5))
            context.stroke(bounds.insetBy(dx: inset, dy: inset))
        case .rounded:
            let inset = moduleSize * 0.4
            let path = UIBezierPath(
                roundedRect: bounds.insetBy(dx: inset, dy: inset),
                cornerRadius: moduleSize * 1.2
            )
            context.setLineWidth(max(moduleSize * 0.45, 2))
            context.addPath(path.cgPath)
            context.strokePath()
        case .bold:
            let inset = moduleSize * 0.25
            context.setLineWidth(max(moduleSize * 0.75, 3))
            context.stroke(bounds.insetBy(dx: inset, dy: inset))
        case .double:
            let outerInset = moduleSize * 0.2
            let innerInset = moduleSize * 1.1
            context.setLineWidth(max(moduleSize * 0.35, 1.5))
            context.stroke(bounds.insetBy(dx: outerInset, dy: outerInset))
            context.stroke(bounds.insetBy(dx: innerInset, dy: innerInset))
        }
    }
}

struct QRCodeImageView: View {
    let payload: String
    var size: CGFloat = 240
    var foreground: Color = AppTheme.ink
    var background: Color = .white
    var moduleStyle: QRModuleStyle = .square
    var frameStyle: QRFrameStyle = .none
    var frameColor: Color? = nil

    var body: some View {
        Group {
            if let uiImage = QRCodeGenerator.image(
                from: payload,
                pixelSize: max(size * UIScreen.main.scale, 256),
                foreground: UIColor(foreground),
                background: UIColor(background),
                moduleStyle: moduleStyle,
                frameStyle: frameStyle,
                frameColor: UIColor(frameColor ?? foreground)
            ) {
                Image(uiImage: uiImage)
                    .interpolation(.high)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .accessibilityLabel("QR Code")
            } else {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppTheme.field)
                    .frame(width: size, height: size)
                    .overlay {
                        VStack(spacing: 8) {
                            Image(systemName: "qrcode")
                                .font(.system(size: 40))
                                .foregroundStyle(AppTheme.inkSecondary)
                            Text(L10n.fillFields)
                                .font(.footnote)
                                .foregroundStyle(AppTheme.inkSecondary)
                        }
                    }
            }
        }
    }
}
