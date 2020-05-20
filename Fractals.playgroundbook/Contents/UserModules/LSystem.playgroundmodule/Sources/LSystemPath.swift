import CoreGraphics

/// Contains a path describing a fully drawn string using drawing rules.
/// This class also describes the partial states during drawing to allow animating drawing the path.
public class LSystemPath {
    private let string: String
    private let drawingRules: [String: DrawingRule]

    /// The final path, resized to the specified size.
    public private(set) var cgPath: CGPath!
    public private(set) var pathBoundingBox: CGRect!

    /// The individual path elements, each corresponding to a character from the string.
    public private(set) var pathElements: [PathElement]!

    /// States whether the path contains only of a single (`true`) or of multiple (`false`) subpaths.
    public private(set) var isSinglePath: Bool!

    /// The number of drawn lines the path consists of.
    public private(set) var numberOfLines: Int!

    /// Default initializer.
    /// Precondition: all letters in the string must have an associated rule.
    public init(string: String, drawingRules: [String: DrawingRule], startDirection: Double, size: CGSize) {
        self.string = string
        self.drawingRules = drawingRules
        createPath(containerSize: size, startDirection: startDirection)
    }

    /// Create the path using self's string and drawing rules.
    private func createPath(containerSize: CGSize, startDirection: Double) {
        pathElements = [PathElement]()
        pathElements.reserveCapacity(string.count)

        var path = CGMutablePath()
        path.move(to: .zero)

        isSinglePath = true
        numberOfLines = 0

        var state = DrawingState(position: CGPoint.zero, direction: CGFloat(startDirection) * CGFloat.pi / 180.0)
        var stack = [DrawingState]()

        for character in string {
            let rule = drawingRules[String(character)] ?? .ignore
            let oldState = state

            switch rule {
            case .draw:
                let nextPosition = state.position.move(in: state.direction, by: 1)
                path.addLine(to: nextPosition)
                numberOfLines += 1
                state = DrawingState(position: nextPosition, direction: state.direction)

            case .move:
                let nextPosition = state.position.move(in: state.direction, by: 1)
                path.move(to: nextPosition)
                isSinglePath = false
                state = DrawingState(position: nextPosition, direction: state.direction)

            case .ignore:
                ()

            case .turnLeft(angle: let angle):
                state = DrawingState(position: state.position, direction: state.direction + CGFloat(angle) * CGFloat.pi / 180.0)

            case .turnRight(angle: let angle):
                state = DrawingState(position: state.position, direction: state.direction - CGFloat(angle) * CGFloat.pi / 180.0)

            case .saveState:
                stack.append(state)

            case .restoreState:
                isSinglePath = false
                state = stack.removeLast()
                path.move(to: state.position)
            }

            pathElements.append(PathElement(fromState: oldState, toState: state, rule: rule))
        }

        // Transform path to fit inside the container
        let container = CGRect(origin: .zero, size: containerSize).insetBy(dx: 10, dy: 10)
        var pathRect = path.boundingBoxOfPath.insetBy(dx: -0.001, dy: -0.001) // Bugfix for empty paths

        var transform = CGAffineTransform(translationX: -pathRect.minX, y: -pathRect.minY)
        let scale = min(container.width / pathRect.width, container.height / pathRect.height)
        transform = transform.concatenating(CGAffineTransform(scaleX: scale, y: scale))
        pathRect = pathRect.applying(transform)
        transform = transform.concatenating(CGAffineTransform(translationX: container.midX - pathRect.width * 0.5, y: container.midY - pathRect.height * 0.5))

        path = path.mutableCopy(using: &transform) ?? CGMutablePath()

        for i in 0 ..< pathElements.count {
            pathElements[i].fromState.position = pathElements[i].fromState.position.applying(transform)
            pathElements[i].toState.position = pathElements[i].toState.position.applying(transform)
        }

        // Set pathStrokeFrom and pathStrokeEnd
        var current: CGFloat = 0
        for i in 0 ..< pathElements.count {
            pathElements[i].pathStrokeFrom = current / CGFloat(numberOfLines)
            if case .draw = pathElements[i].rule { current += 1 }
            pathElements[i].pathStrokeEnd = current / CGFloat(numberOfLines)
        }

        self.cgPath = path
        self.pathBoundingBox = path.boundingBoxOfPath
    }
}

/// A single element of the path, associated with exactly one character.
public struct PathElement {
    public fileprivate(set) var fromState: DrawingState
    public fileprivate(set) var toState: DrawingState
    public let rule: DrawingRule

    // Animating this path element means drawing the full path from `pathStrokeFrom` to `pathStrokeTo`.
    public fileprivate(set) var pathStrokeFrom: CGFloat!
    public fileprivate(set) var pathStrokeEnd: CGFloat!
}

/// The state before/after drawing a path element.
public struct DrawingState {
    public fileprivate(set) var position: CGPoint
    public fileprivate(set) var direction: CGFloat // 0 means right, going counterclockwise until 360
}

// MARK: CoreGraphics Extensions

public extension CGPoint {
    /// Move `length` units in a given direction.
    /// Thereby, 0 means right, going counterclockwise until 2pi.
    func move(in direction: CGFloat, by length: CGFloat) -> CGPoint {
        let dx = cos(direction) * length
        let dy = -sin(direction) * length
        return CGPoint(x: x + dx, y: y + dy)
    }
}

private extension CGRect {
    /// Find a transform transforming `self` to `destination`.
    func transform(to destination: CGRect) -> CGAffineTransform {
        CGAffineTransform.identity
            .translatedBy(x: destination.midX - self.midX, y: destination.midY - self.midY)
            .scaledBy(x: destination.width / self.width, y: destination.height / self.height)
    }
}
