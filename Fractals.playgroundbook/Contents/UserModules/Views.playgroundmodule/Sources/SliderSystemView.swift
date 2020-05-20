import LSystem
import UIKit

/// `SliderSystemView` displays an L-System which is parametrized by a single value.
/// This value can by changed using the slider, which will live-update the L-System.
public class SliderSystemView: UIView {
    /// The block that determines the LSystem for a given slider value.
    private let block: (Double) -> LSystem

    private let evolutions: Int
    private var currentSystem: LSystem

    /// The starting angle that is used for drawing, depending on the slider value.
    private let startingAngle: (Double) -> Double

    /// The slider and the label showing the current progress.
    private let slider = UISlider()
    private let label = UILabel()
    private let labelFormat: String
    private let gradientColors: [UIColor]

    /// The shape layer.
    private let shapeLayer: EvolutionShapeLayer
    private var initialPathWasSet = false

    private var eventDamper: EventDamper<Double>!

    /// Default initializer.
    public init(valueRange: Range<Double>, startValue: Double, labelFormat: String, gradient gradientColors: GradientColors, startingAngleForDrawing: @escaping (Double) -> Double, evolutions: Int, system: @escaping (Double) -> LSystem) {
        self.block = system
        self.evolutions = evolutions
        self.startingAngle = startingAngleForDrawing
        self.labelFormat = labelFormat

        currentSystem = block(startValue)

        shapeLayer = EvolutionShapeLayer(gradientColors: gradientColors.colors, lineWidthRange: 2 ..< 2, animationDuration: 0.15, transitionDuration: 0.05)
        self.gradientColors = gradientColors.colors

        super.init(frame: .zero)
        addSubview(shapeLayer)
        backgroundColor = .white

        // Slider and label
        addSubview(slider)
        slider.setGradient(with: gradientColors.colors)
        slider.minimumValue = Float(valueRange.lowerBound)
        slider.maximumValue = Float(valueRange.upperBound)
        slider.value = Float(startValue)
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)

        addSubview(label)
        label.textAlignment = .center
        label.textColor = gradientColors.colors.last!
        label.text = String(format: labelFormat, startValue)

        // Event damper
        eventDamper = EventDamper<Double>(delayBetweenEvents: 0.15) { value in
            self.updateSystemWithSliderValue(value)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        if bounds.isEmpty { return }

        // Slider and label
        slider.frame = CGRect(x: 20, y: bounds.height - 90, width: bounds.width - 40, height: 30)
        slider.setGradient(with: gradientColors)
        label.frame = CGRect(x: 0, y: slider.frame.maxY + 5, width: 200, height: 40)
        label.center.x = bounds.width / 2

        // Shape layer
        shapeLayer.frame = CGRect(x: 0, y: 0, width: bounds.width, height: slider.frame.minY).insetBy(dx: 15, dy: 15)

        // Initial path or update path
        if !initialPathWasSet {
            initialPathWasSet = true
            shapeLayer.set(path: currentPath, animated: false)
        } else {
            updateSystemWithSliderValue(Double(slider.value))
        }
    }

    /// Generate the current L-System path depending on the current L-System and size.
    private var currentPath: LSystemPath {
        LSystemPath(
            string: currentSystem.apply(count: evolutions, to: currentSystem.startString),
            drawingRules: currentSystem.drawingRules,
            startDirection: startingAngle(Double(slider.value)),
            size: shapeLayer.bounds.size
        )
    }

    @objc private func sliderValueChanged() {
        eventDamper.newValue(Double(slider.value))
    }

    /// Actually udpate the system.
    private func updateSystemWithSliderValue(_ value: Double) {
        label.text = String(format: labelFormat, value)
        if bounds.isEmpty { return }
        currentSystem = block(Double(slider.value))
        shapeLayer.set(path: currentPath, animated: true)
    }
}

// MARK: Extensions

private extension UISlider {
    /// Fill the left part of the slider with a gradient.
    func setGradient(with colors: [UIColor]) {
        let gradient = RadialGradientLayer()
        gradient.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 5)
        gradient.colors = colors

        UIGraphicsBeginImageContextWithOptions(gradient.frame.size, false, 0)
        gradient.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        setMinimumTrackImage(image,  for: .normal)
    }
}

/// EventDamper is used to filter and strech incoming events so they do not occur too often in a given time interval.
private class EventDamper<Value> {
    private let delayBetweenEvents: Double
    private let eventCallback: (Value) -> Void

    /// Default initializer.
    init(delayBetweenEvents: Double, eventCallback: @escaping (Value) -> Void) {
        self.delayBetweenEvents = delayBetweenEvents
        self.eventCallback = eventCallback
    }

    /// The value that is being sent once enough time has passed.
    private var waitingValue: Value?
    private var timerForWaitingValue: Timer?

    private var timeOfLatestEvent: Double?

    /// Call when a new value appears.
    /// When this value is or will become valid (time-wise), `eventCallback` is called.
    func newValue(_ value: Value) {
        let time = CACurrentMediaTime()
        timerForWaitingValue?.invalidate()

        guard let latest = timeOfLatestEvent else { // First value
            timeOfLatestEvent = time
            return eventCallback(value)
        }

        // Fire new value
        if time - latest >= delayBetweenEvents {
            waitingValue = nil
            timeOfLatestEvent = time
            eventCallback(value)
        }

        // Set current value to waiting
        else {
            waitingValue = value
            timerForWaitingValue = Timer.scheduledTimer(timeInterval: delayBetweenEvents - (time - latest), target: self, selector: #selector(fire), userInfo: nil, repeats: false)
            RunLoop.main.add(timerForWaitingValue!, forMode: .common)
        }
    }

    @objc private func fire() {
        if let value = waitingValue {
            timeOfLatestEvent = CACurrentMediaTime()
            waitingValue = nil
            eventCallback(value)
        }
    }
}
