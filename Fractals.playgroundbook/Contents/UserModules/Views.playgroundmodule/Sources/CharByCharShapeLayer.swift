import LSystem
import UIKit

/// `CharByCharShapeLayer` is part of a `CharByCharDrawingView` and animates the drawing of an L-System path.
/// This includes animating an arrow always showing the current position and direction.
internal class CharByCharShapeLayer: UIView {
    var lpath: LSystemPath! {
        didSet {
            pathWasUpdated()
        }
    }

    var animationIndex = 0
    var isAnimating = false

    /// The layer drawing the full path. It acts as a mask for a gradient layer.
    private let shapeLayer = CAShapeLayer()
    private let gradient = RadialGradientContainer()

    /// The layer containing an arrow showing the current position and direction.
    private let arrow = CAShapeLayer()

    /// Default initializer.
    init(gradient gradientColors: GradientColors) {
        super.init(frame: .zero)

        // Gradient layer
        addSubview(gradient)
        gradient.colors = gradientColors.colors

        // Shape layer
        gradient.layer.mask = shapeLayer
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.fillColor = .none
        shapeLayer.lineCap = .round
        shapeLayer.lineWidth = 3
        shapeLayer.strokeEnd = 0

        // Arrow layer
        layer.addSublayer(arrow)
        arrow.anchorPoint = .zero
        arrow.strokeColor = UIColor.gray.cgColor
        arrow.path = arrowPath
        arrow.fillColor = .none
        arrow.lineCap = .round
        arrow.lineWidth = 3
        arrow.lineDashPattern = [4, 4]
        arrow.opacity = 1
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Create the path for the arrow, pointing to the right.
    private var arrowPath: CGPath {
        let length: CGFloat = 40
        let radius: CGFloat = 10

        let arrowhead = CGPoint.zero.move(in: 0, by: length)
        let left: CGPoint = arrowhead.move(in: -CGFloat.pi * 1.25, by: 0.5 * length)
        let right: CGPoint = arrowhead.move(in: CGFloat.pi * 1.25, by: 0.5 * length)

        let path = CGMutablePath()
        path.addEllipse(in: CGRect.zero.insetBy(dx: -radius, dy: -radius))
        path.move(to: .zero)
        path.addLine(to: arrowhead)
        path.addLine(to: left)
        path.move(to: arrowhead)
        path.addLine(to: right)

        return path
    }

    // Move arrow to the correct position when the path is set.
    func pathWasUpdated() {
        shapeLayer.path = lpath.cgPath
        gradient.setGradientFrame(lpath.pathBoundingBox.insetBy(dx: -3, dy: -3))
    }

    /// Update the arrow position according to the current animation index.
    func updateArrowPosition() {
        guard let lpath = lpath, animationIndex < lpath.pathElements.count else { return }

        let element: PathElement = lpath.pathElements[animationIndex]
        let state: DrawingState = isAnimating ? element.toState : element.fromState

        let transform = CGAffineTransform(translationX: state.position.x, y: state.position.y).rotated(by: -state.direction)
        arrow.transform = CATransform3DMakeAffineTransform(transform)
        arrow.position = .zero
    }

    /// Update the layout.
    override func layoutSubviews() {
        gradient.frame = bounds
        shapeLayer.frame = bounds
        arrow.frame = bounds

        updateArrowPosition()
    }

    /// Animate to the next character.
    /// This is only called when the animation has not finished yet.
    func animateNext(duration: Double) {
        let element = lpath.pathElements[animationIndex]

        // Animate self.strokeEnd and arrow.transform
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .linear))

        shapeLayer.strokeEnd = element.pathStrokeEnd
        updateArrowPosition()

        CATransaction.commit()
        animationIndex += 1
    }

    /// Do preliminary setup immediately before the animation starts.
    func beginAnimation() {
        arrow.opacity = 1
        isAnimating = true
    }

    /// Do clean-up after animation has finished.
    func finishAnimating() {
        arrow.opacity = 0
        isAnimating = false
    }

    /// Reset to start state.
    func reset() {
        animationIndex = 0
        updateArrowPosition()

        // StrokeEnd
        let anim = CABasicAnimation(keyPath: "strokeEnd")
        anim.duration = 1
        anim.fromValue = shapeLayer.strokeEnd
        anim.toValue = 0
        shapeLayer.strokeEnd = 0
        shapeLayer.add(anim, forKey: nil)
    }
}
