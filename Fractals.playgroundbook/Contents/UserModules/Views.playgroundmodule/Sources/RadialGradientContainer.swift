import UIKit

/// A RadialGradientContainer contains a RadialGradientLayer.
/// Its purpose is to animate the size of the underlying gradient layer, while keeping a valid mask.
/// Therefore, the mask can be set on this view (which does not animate its size) and the gradient can do whatever it wants to.
internal class RadialGradientContainer: UIView {
    let gradient = RadialGradientLayer()

    /// Default initializer.
    init() {
        super.init(frame: .zero)
        layer.addSublayer(gradient)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// The colors of the underlying gradient layer.
    var colors: [UIColor] {
        get { gradient.colors }
        set {
            gradient.colors = newValue
            Timing.perform(after: 1) {
                self.backgroundColor = self.gradient.colors.last! // Backup for when things outside the actual gradient are occasionally drawn
            }
        }
    }

    /// Set the frame of the underlying gradient without changing `self`s frame.
    func setGradientFrame(_ frame: CGRect) {
        gradient.frame = frame
    }

    /// Animate the frame of the underlying gradient without changing `self`s frame.
    func animateGradientFrame(to frame: CGRect, duration: Double) {
        let oldFrame = gradient.frame
        gradient.frame = frame

        let position = CABasicAnimation(keyPath: "position")
        position.duration = duration
        position.fromValue = CGPoint(x: oldFrame.midX, y: oldFrame.midY)
        gradient.add(position, forKey: nil)

        let bounds = CABasicAnimation(keyPath: "bounds")
        bounds.duration = duration
        bounds.fromValue = oldFrame.offsetBy(dx: -oldFrame.minX, dy: -oldFrame.minY)
        gradient.add(bounds, forKey: nil)
    }
}
