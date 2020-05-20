import UIKit

/// A full description on how an L-System should be drawn by an EvolutionView.
public struct LSystemEvolutionDrawingDescription {
    public let system: LSystem

    /// The colors of the gradient.
    public let gradient: GradientColors

    /// The starting angle that is used for drawing.
    public let startingAngle: StartingAngle

    /// The initial and the maximum generation number.
    public let startGeneration: Int
    public let maxGeneration: Int

    /// The width of the line; the line gets thinner from generation to generation.
    public let lineWidthRange: Range<CGFloat>

    /// Default initializer.
    public init(system: LSystem, gradient: GradientColors, startingAngle: StartingAngle, startGeneration: Int = 0, maxGeneration: Int, lineWidthRange: Range<CGFloat> = 2 ..< 3.5) {
        self.system = system
        self.gradient = gradient
        self.startingAngle = startingAngle
        self.startGeneration = startGeneration
        self.lineWidthRange = lineWidthRange
        self.maxGeneration = maxGeneration
    }
}

/// Describes different colorings for the radial gradient that is used to draw L-Systems.
public enum GradientColors {
    case orange
    case green
    case snow

    public var colors: [UIColor] {
        switch self {
        case .orange:
            return [.yellow, .orange, .red, UIColor(red: 0.4, green: 0, blue: 0, alpha: 1), .black]

        case .green:
            return [UIColor(red: 0.4, green: 0.8, blue: 0, alpha: 1), UIColor(red: 0, green: 0.5, blue: 0, alpha: 1), .brown]

        case .snow:
            return [.blue, .blue, UIColor(red: 0.5, green: 0.5, blue: 1, alpha: 1), .blue, .blue]
        }
    }
}

/// Describes how the starting angle is calculated based on the evolution index.
public enum StartingAngle {
    case angle(Double)
    case even(Double, odd: Double)
    case block((Int) -> Double)

    public func angle(for evolution: Int) -> Double {
        switch self {
        case let .angle(angle):
            return angle

        case let .even(even, odd: odd):
            return evolution.isMultiple(of: 2) ? even : odd

        case let .block(block):
            return block(evolution)
        }
    }
}

