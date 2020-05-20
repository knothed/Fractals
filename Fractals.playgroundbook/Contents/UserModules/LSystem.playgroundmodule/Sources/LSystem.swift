/// `ProductionRule` describes a rule of how a single character can be evolved into a new string in an evolution phase.
/// A rule could like follows: (A -> A-B). You can construct it like this: `let rule = "A" ~> "A-B"`.
public struct ProductionRule {
    public let predecessor: String
    public let successor: String

    /// Create a ProductionRule looking like this: `predecessor -> successor`.
    public init(predecessor: String, successor: String) {
        self.predecessor = predecessor
        self.successor = successor
    }
}

/// `DrawingRule` describes how a single character will be drawn.
public enum DrawingRule {
    /// Draw a line segment of fixed length in the current drawing direction.
    case draw

    /// Move a line segment of fixed length in the current drawing direction, without actually drawing.
    case move

    /// Stay at the current position and rotate the drawing direction by `angle` (in degrees).
    case turnLeft(angle: Double)

    /// Stay at the current position and rotate the drawing direction by `angle` (in degrees).
    case turnRight(angle: Double)

    /// Save the current state (i.e. position and drawing direction) onto the stack.
    case saveState

    /// Restore and pop the topmost state (i.e. position and drawing direction) from the stack.
    case restoreState

    /// Do nothing.
    case ignore
}

/// An `LSystem` describes the initial configuration and the rules of an [L-System](https://en.wikipedia.org/wiki/L-system).
public struct LSystem {
    /// The start string of the system.
    public let startString: String

    /// All production rules.
    public let productionRules: [ProductionRule]

    /// All drawing rules.
    /// These **MUST** cover all characters that are used in the start string and in the production rules (else, the system cannot be drawn).
    public let drawingRules: [String: DrawingRule]

    /// Create an L-System-configuration from the start string and the rules.
    public init(startString: String,
                productionRules: [ProductionRule],
                drawingRules: [String: DrawingRule]) {
        self.startString = startString
        self.productionRules = productionRules
        self.drawingRules = drawingRules
    }
}

infix operator ~>

/// Construct a production rule as follows: `let rule = "A" ~> "A-B"`.
public func ~>(predecessor: String, successor: String) -> ProductionRule {
    ProductionRule(predecessor: predecessor, successor: successor)
}
