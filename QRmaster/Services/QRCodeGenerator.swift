import CoreImage.CIFilterBuiltins
import SwiftUI
import UIKit

enum QRCodeGenerator {
    private static let context = CIContext()

    static func image(
        from string: String,
        scale: CGFloat = 12,
        correctionLevel: String = "M",
        foreground: UIColor = .black,
        background: UIColor = .white
    ) -> UIImage? {
        guard !string.isEmpty else { return nil }

        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        filter.correctionLevel = correctionLevel

        guard let output = filter.outputImage else { return nil }

        let transformed = output.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        let colored = transformed.applying(foreground: foreground, background: background)
        guard let cgImage = context.createCGImage(colored, from: colored.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}

private extension CIImage {
    func applying(foreground: UIColor, background: UIColor) -> CIImage {
        let colorFilter = CIFilter.falseColor()
        colorFilter.inputImage = self
        colorFilter.color0 = CIColor(color: foreground)
        colorFilter.color1 = CIColor(color: background)
        return colorFilter.outputImage ?? self
    }
}

struct QRCodeImageView: View {
    let payload: String
    var size: CGFloat = 240
    var foreground: Color = AppTheme.ink
    var background: Color = .white

    var body: some View {
        Group {
            if let uiImage = QRCodeGenerator.image(
                from: payload,
                foreground: UIColor(foreground),
                background: UIColor(background)
            ) {
                Image(uiImage: uiImage)
                    .interpolation(.none)
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
