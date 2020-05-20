import LSystem
import UIKit

/// `EvolutionShapeLayer` animates between different LSystemPaths.
/// Thereby, animation is done by animating the path, if possible. Else, it fades between the paths.
internal class EvolutionShapeLayer: UIView {
    /// The layer drawing the full path. It acts as a mask for a gradient layer.
    private var shapeLayer: CAShapeLayer!
    private let gradient = RadialGradientContainer()

    /// A container layer containing the shapeLayer(s). This is required for a fade animation.
    private let maskContainer = CALayer()

    private var currentPath: LSystemPath!
    var generation = 0

    private let lineWidthRange: Range<CGFloat>
    private let animationDuration: Double
    private let transitionDuration: Double

    /// Default initializer.
    init(gradientColors: [UIColor], lineWidthRange: Range<CGFloat> = 2 ..< 3.5, animationDuration: Double, transitionDuration: Double) {
        self.lineWidthRange = lineWidthRange
        self.animationDuration = animationDuration
        self.transitionDuration = transitionDuration

        super.init(frame: .zero)
        shapeLayer = createShapeLayer(generation: 0)

        // Gradient layer
        addSubview(gradient)
        gradient.colors = gradientColors
        gradient.layer.mask = maskContainer
        maskContainer.addSublayer(shapeLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Create a shape layer that can be used as a mask for the gradient layer.
    func createShapeLayer(with path: CGPath? = nil, generation: Int) -> CAShapeLayer {
        shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.fillColor = .none
        shapeLayer.lineCap = .round
        shapeLayer.lineWidth = lineWidth(for: generation)
        shapeLayer.path = path
        return shapeLayer
    }

    func lineWidth(for generation: Int) -> CGFloat {
        let maxWidth = lineWidthRange.upperBound
        let diffPerGen = (lineWidthRange.upperBound - lineWidthRange.lowerBound) / 5
        return maxWidth - diffPerGen * CGFloat(max(0, min(5, generation - 1)))
    }

    /// Update the layout.
    override func layoutSubviews() {
        gradient.frame = bounds
        gradient.setGradientFrame(currentPath?.pathBoundingBox?.insetBy(dx: -3, dy: -3) ?? bounds)
        maskContainer.frame = bounds
        shapeLayer.frame = bounds
    }

    /// Set the path or animate it.
    func set(path: LSystemPath, animated: Bool) {
        defer { currentPath = path }

        guard animated else {
            shapeLayer.path = path.cgPath
            gradient.setGradientFrame(path.pathBoundingBox.insetBy(dx: -3, dy: -3))
            return
        }

        // Determine whether animation can be done by animating shapeLayer.path. Else, blend the transition.
        // Only paths which emerge from each other by replacing *drawing* segments can be animated. These are paths consisting of a single subpath and having a multiple of lines.
        let isMultiple = path.numberOfLines.isMultiple(of: currentPath.numberOfLines) || currentPath.numberOfLines.isMultiple(of: path.numberOfLines)
        let canAnimatePathDirectly = isMultiple && path.isSinglePath && currentPath.isSinglePath

        self.generation += 1
        if canAnimatePathDirectly {
            animatePathDirectly(to: path)
        } else {
            animatePathViaTransition(to: path)
        }
    }

    /// Perform a path animation by animating shapeLayer.path.
    private func animatePathDirectly(to path: LSystemPath) {
        shapeLayer.path = path.cgPath
        shapeLayer.lineWidth = lineWidth(for: generation)

        var fromPath = currentPath.cgPath!
        var toPath = path.cgPath!
        if path.numberOfLines > currentPath.numberOfLines {
            let factor = path.numberOfLines / max(1, currentPath.numberOfLines)
            fromPath = fromPath.splitAllLines(into: factor)
        } else {
            let factor = currentPath.numberOfLines / max(1, path.numberOfLines)
            toPath = toPath.splitAllLines(into: factor)
        }

        let anim = CABasicAnimation(keyPath: "path")
        anim.fromValue = fromPath
        anim.toValue = toPath
        anim.duration = animationDuration
        shapeLayer.add(anim, forKey: nil)

        let width = CABasicAnimation(keyPath: "lineWidth")
        width.fromValue = lineWidth(for: generation - 1)
        width.toValue = lineWidth(for: generation)
        width.duration = animationDuration
        shapeLayer.add(width, forKey: nil)

        gradient.animateGradientFrame(to: path.pathBoundingBox.insetBy(dx: -3, dy: -3), duration: animationDuration)
    }

    /// Perform a path animation by fading to the other path using a transition.
    private func animatePathViaTransition(to path: LSystemPath) {
        let old = shapeLayer!

        let new = createShapeLayer(with: path.cgPath, generation: generation)
        maskContainer.addSublayer(new)
        shapeLayer = new

        // Fade in `new` via CABasicAnimation
        let anim = CABasicAnimation(keyPath: "opacity")
        anim.fromValue = 0
        anim.toValue = 1
        anim.duration = transitionDuration
        new.add(anim, forKey: nil)

        // Fade out and remove `old` via CATransaction
        CATransaction.begin()
        CATransaction.setAnimationDuration(transitionDuration)
        CATransaction.setCompletionBlock {
            old.removeFromSuperlayer()
        }
        old.opacity = 0
        CATransaction.commit()

        gradient.animateGradientFrame(to: path.pathBoundingBox.insetBy(dx: -3, dy: -3), duration: transitionDuration)
    }
}

// MARK: CGPath + SplitAllLines

private extension CGPath {
    /// Create a CGPath from this path by splitting all lines into smaller lines. The paths look the same, but the new path has more points, which can be useful for animating.
    /// The path should only consist of "moveToPoint" and "addLineToPoint" elements as other elements are ignored and removed from the resulting path.
    func splitAllLines(into count: Int) -> CGPath {
        let result = CGMutablePath()

        var current = CGPoint.zero
        result.move(to: .zero)

        applyWithBlock { p in
            let element = p.pointee

            switch element.type {
            case .moveToPoint:
                current = element.points[0]
                result.move(to: current)

            case .addLineToPoint:
                let from = current
                current = element.points[0]

                for i in 1 ... count {
                    let point = interpolate(between: from, and: current, p: CGFloat(i) / CGFloat(count))
                    result.addLine(to: point)
                }

            default:
                ()
            }
        }

        return result
    }

    /// Interpolate in a straight line between two CGPoints.
    /// `p=0` yields the first point whereas `p=1` yields the second point.
    private func interpolate(between first: CGPoint, and second: CGPoint, p: CGFloat) -> CGPoint {
        return CGPoint(
            x: first.x * (1-p) + second.x * p,
            y: first.y * (1-p) + second.y * p
        )
    }
}
