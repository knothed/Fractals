import LSystem
import UIKit

/// A view drawing a string and associated `DrawingRule`s, character by character, showing each individual `DrawingRule` that is applied.
/// It consists of a `CharByCharShapeLayer` for drawing the path, and a `CharByCharStringView` for showing the current progress.
public class CharByCharDrawingView: UIView {
    private let string: String
    private let drawingRules: [String: DrawingRule]
    private let startDirection: Double

    /// The view containing the string.
    private let stringView: CharByCharStringView

    /// The layer animating the path.
    private let shapeLayer: CharByCharShapeLayer
    private var lpath: LSystemPath!

    /// Replay button which is shown after the animation has finished.
    private let replayButton = UIButton(type: .system)

    private var animationIndex = 0
    private var isAnimating = false

    /// Default initializer.
    public init(string: String, drawingRules: [String: DrawingRule], gradient: GradientColors, startDirection: Double = 0) {
        self.string = string
        self.drawingRules = drawingRules
        self.startDirection = startDirection

        shapeLayer = CharByCharShapeLayer(gradient: gradient)
        stringView = CharByCharStringView(string: string)

        super.init(frame: .zero)
        backgroundColor = .white

        addSubview(stringView)
        addSubview(shapeLayer)

        // Replay button
        replayButton.frame = CGRect(x: 0, y: 0, width: 120, height: 50)
        replayButton.tintColor = gradient.colors.last! // Outermost color
        replayButton.titleEdgeInsets.left = 20
        replayButton.setTitle("replay", for: .normal)
        replayButton.setImage(UIImage(systemName: "gobackward"), for: .normal)
        replayButton.alpha = 0
        replayButton.addTarget(self, action: #selector(replay), for: .touchUpInside)
        addSubview(replayButton)

        Timing.perform(after: 0.5, identification: .object(self), block: beginAnimation)
    }

    public required init(coder: NSCoder) {
        fatalError("Not implemented!")
    }

    public override func layoutSubviews() {
        if bounds.isEmpty { return }

        updateFrames()

        // Create new path object (because it is dependent on the layer size)
        lpath = LSystemPath(string: string, drawingRules: drawingRules, startDirection: startDirection, size: shapeLayer.bounds.size)
        shapeLayer.lpath = lpath

        // Reschedule start of animations
        if !isAnimating {
            Timing.cancelTasks(withObject: self)
            Timing.perform(after: 0.5, identification: .object(self), block: beginAnimation)
        }
    }

    func updateFrames() {
        // Leave 80px space at the bottom because of the playground
        stringView.frame = CGRect(x: 0, y: bounds.height - 120, width: bounds.width, height: 70)
        shapeLayer.frame = CGRect(x: 40, y: 90, width: bounds.width - 80, height: stringView.frame.minY - 120)

        // Replay button
        replayButton.frame.origin = CGPoint(x: bounds.width - 120, y: 0)
    }

    /// Begin animating the path.
    private func beginAnimation() {
        isAnimating = true

        shapeLayer.beginAnimation()
        stringView.beginAnimation()

        let totalDuration = min(12, 1.2 * Double(lpath.pathElements.count))
        let elementDuration = totalDuration / Double(lpath.pathElements.count)
        Timing.perform(after: 0.5 * elementDuration) {
            self.animateCurrentCharacter(duration: 0.6 * elementDuration, delay: 0.4 * elementDuration)
        }
    }

    /// Animate the character at the current animation index.
    private func animateCurrentCharacter(duration: Double, delay: Double) {
        guard animationIndex < lpath.pathElements.count else {
            return animationFinished()
        }

        shapeLayer.animateNext(duration: duration)
        stringView.animateNext(duration: 0.9 * duration)

        // Schedule next animation
        Timing.perform(after: duration + delay) {
            self.animationIndex += 1
            self.animateCurrentCharacter(duration: duration, delay: delay)
        }
    }

    /// Close the current playground page after animations have finished.
    private func animationFinished() {
        isAnimating = false
        shapeLayer.finishAnimating()
        stringView.finishAnimating()

        Timing.perform(after: 0.5) {
            UIView.animate(withDuration: 0.4) {
                self.replayButton.alpha = 1
            }
        }
    }

    /// Reset the state and replay the animation.
    @objc private func replay() {
        UIView.animate(withDuration: 0.2) {
            self.replayButton.alpha = 0
        }

        animationIndex = 0
        shapeLayer.reset()
        stringView.reset()

        // Schedule animations
        Timing.perform(after: 2, block: beginAnimation)
    }
}
