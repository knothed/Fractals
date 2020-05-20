import LSystem
import UIKit

/// A view drawing a full `LSystem` and animating the evolution when repeatedly applying the production rules.
public class EvolutionView: UIView {
    /// The system itself and its drawing description.
    private let system: LSystem
    private let drawing: LSystemEvolutionDrawingDescription

    private var currentGeneration: Int
    private var currentString: String

    private var isAnimating = false

    /// The maximum supported generation number.
    /// This limitations is obviously due to performance reasons, because L-Systems get more complex (space-wise) exponentially.
    private let maxGeneration: Int

    /// The view showing and animating the path.
    private let shapeLayer: EvolutionShapeLayer

    /// Replay button which is shown after the animation has finished.
    private let replayButton = UIButton(type: .system)

    /// Default initializer.
    public init(drawing: LSystemEvolutionDrawingDescription) {
        self.system = drawing.system
        self.drawing = drawing

        maxGeneration = drawing.maxGeneration
        currentGeneration = drawing.startGeneration
        currentString = system.apply(count: currentGeneration, to: system.startString)

        shapeLayer = EvolutionShapeLayer(gradientColors: drawing.gradient.colors, lineWidthRange: drawing.lineWidthRange, animationDuration: 0.5, transitionDuration: 0.2)

        super.init(frame: .zero)
        addSubview(shapeLayer)
        backgroundColor = .white

        // Replay button
        replayButton.frame = CGRect(x: 0, y: 0, width: 120, height: 50)
        replayButton.tintColor = drawing.gradient.colors.last! // Outermost color
        replayButton.titleEdgeInsets.left = 20
        replayButton.setTitle("replay", for: .normal)
        replayButton.setImage(UIImage(systemName: "gobackward"), for: .normal)
        replayButton.alpha = 0
        replayButton.addTarget(self, action: #selector(replay), for: .touchUpInside)
        addSubview(replayButton)

        // Schedule animations
        Timing.perform(after: 1, identification: .object(self), block: beginAnimation)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Update the layout.
    public override func layoutSubviews() {
        if bounds.isEmpty { return }

        // Create new CGPath when size changes
        shapeLayer.frame = bounds.insetBy(dx: 15, dy: 15)
        updatePath(animated: false)

        // Replay button
        replayButton.frame.origin = CGPoint(x: bounds.width - 120, y: 0)

        // Reschedule start of animations
        if !isAnimating {
            Timing.cancelTasks(withObject: self)
            Timing.perform(after: 1, identification: .object(self), block: beginAnimation)
        }
    }

    /// Begin animating.
    private func beginAnimation() {
        isAnimating = true
        evolveAndAnimate()
    }

    /// Evolve and schedule the next evolution step.
    private func evolveAndAnimate() {
        guard currentGeneration < maxGeneration else {
            return animationFinished()
        }

        evolve()
        Timing.perform(after: 1) {
            self.evolveAndAnimate()
        }
    }

    /// Called when the animation has finished.
    private func animationFinished() {
        Timing.perform(after: 0.5) {
            UIView.animate(withDuration: 0.4) {
                self.replayButton.alpha = 1
            }
        }
    }

    /// Evolve one generation.
    private func evolve() {
        guard currentGeneration < maxGeneration else { return }

        currentGeneration += 1
        currentString = system.apply(to: currentString)
        updatePath(animated: true)
    }

    /// Reset the state and replay the animation.
    @objc private func replay() {
        UIView.animate(withDuration: 0.2) {
            self.replayButton.alpha = 0
        }

        // Reset properties
        currentGeneration = drawing.startGeneration
        currentString = system.apply(count: currentGeneration, to: system.startString)

        // Reset path
        shapeLayer.generation = -1
        updatePath(animated: true)

        // Schedule animations
        Timing.perform(after: 1, block: beginAnimation)
    }

    /// Update the shapeLayer's path.
    private func updatePath(animated: Bool) {
        let path = LSystemPath(
            string: currentString,
            drawingRules: system.drawingRules,
            startDirection: drawing.startingAngle.angle(for: currentGeneration),
            size: shapeLayer.bounds.size
        )
        shapeLayer.set(path: path, animated: animated)
    }
}
