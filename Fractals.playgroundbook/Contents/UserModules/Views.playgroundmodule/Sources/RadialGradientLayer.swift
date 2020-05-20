import UIKit

/// A CALayer that displays a radial gradient around its center.
internal class RadialGradientLayer: CALayer {
    /// The center and radius of the layer.
    var center: CGPoint { CGPoint(x: bounds.width / 2, y: bounds.height / 2) }
    var radius: CGFloat { max(bounds.width, bounds.height) / sqrt(2) }

    /// The colors that are drawn by this gradient, from the inside to the outside.
    var colors = [UIColor]() {
        didSet {
            setNeedsDisplay()
        }
    }

    /// Default initializer.
    override init() {
        super.init()
        needsDisplayOnBoundsChange = true
    }

    override init(layer: Any) {
        super.init(layer: layer)
        needsDisplayOnBoundsChange = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Draw the gradient.
    override func draw(in context: CGContext) {
        let locations: [CGFloat] = Array(0 ..< colors.count).map { i -> CGFloat in
            return CGFloat(i) / CGFloat(colors.count - 1)
        }

        guard let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: colors.map { $0.cgColor } as CFArray,
            locations: locations
        ) else { return }

        context.drawRadialGradient(gradient, startCenter: center, startRadius: 0, endCenter: center, endRadius: radius, options: CGGradientDrawingOptions(rawValue: 0))
    }
}
