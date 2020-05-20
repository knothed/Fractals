import Foundation
import UIKit

/// `CharByCharStringView` is part of a `CharByCharDrawingView` and animates the drawing of an L-System path.
/// This includes animating an arrow always showing the current position and direction.
internal class CharByCharStringView: UIView {
    let string: String

    var animationIndex = 0

    private let spacing: CGFloat = 20

    /// The text field showing the full string.
    private let textField = UITextField()

    /// The view highlighting the current animation progress.
    private let highlightView = UIView()

    /// Default initializer.
    init(string: String) {
        self.string = string
        super.init(frame: .zero)

        // Setup text field
        addSubview(textField)
        textField.text = string
        textField.textAlignment = .center
        textField.isUserInteractionEnabled = false
        textField.font = .monospacedSystemFont(ofSize: 50, weight: .light)
        textField.defaultTextAttributes.updateValue(spacing, forKey: NSAttributedString.Key.kern)

        // Setup highlight view
        addSubview(highlightView)
        highlightView.backgroundColor = UIColor(red: 1, green: 0.6, blue: 0.2, alpha: 0.4)
        highlightView.layer.cornerRadius = 8
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Update the layout.
    override func layoutSubviews() {
        if bounds.isEmpty { return }

        textField.frame = currentFrameForTextView
        highlightView.frame = currentFrameForHighlightView
    }

    /// Calculate the frame of the text field, according to the current animation index.
    var currentFrameForTextView: CGRect {
        var frame = bounds

        frame.size.width = max(
            bounds.width,
            string.size(with: textField.font!, kerning: spacing).width
        )

        // Shift text field to the left during animation if string is longer than the width
        let maxSize = bounds.width - 40
        let rectMax = textField.textRect(for: 0 ..< animationIndex).maxX
        if rectMax > maxSize {
            frame.origin.x -= (rectMax - maxSize)
        }

        frame.origin.x += spacing / 2 // Compensate for trailing kerning

        return frame
    }

    /// Calculate the frame of the highlight view, according to the current animation index.
    var currentFrameForHighlightView: CGRect {
        var frame = bounds

        var rect = textField.textRect(for: 0 ..< animationIndex)
        rect = textField.convert(rect, to: self)
        frame.origin.x = rect.origin.x - spacing / 2
        frame.size.width = rect.width

        // Shift text field to the left during animation if string is longer than the width
        let maxSize = bounds.width - 40
        if rect.maxX > maxSize {
            frame.origin.x -= (rect.maxX - maxSize)
            frame.origin.x += spacing / 2 // Somehow only required in here
        }

        return frame
    }

    /// Animate to the next character.
    /// This is only called when the animation has not finished yet.
    func animateNext(duration: Double) {
        animationIndex += 1
        UIView.animate(withDuration: duration, delay: 0, options: .curveLinear, animations: {
            self.textField.frame = self.currentFrameForTextView
            self.highlightView.frame = self.currentFrameForHighlightView
        })
    }

    /// Do preliminary setup immediately before the animation starts.
    func beginAnimation() {
        textField.frame = currentFrameForTextView
        highlightView.frame = currentFrameForHighlightView
    }

    /// Do clean-up after animation has finished.
    func finishAnimating() {
    }

    /// Reset to start state.
    func reset() {
        animationIndex = 0

        UIView.animate(withDuration: 1, delay: 0, options: .curveLinear, animations: {
            self.textField.frame = self.currentFrameForTextView
            self.highlightView.frame = self.currentFrameForHighlightView
        })
    }
}

// MARK: Extensions

private extension String {
    func size(with font: UIFont, kerning: CGFloat) -> CGSize {
        NSString(string: self).boundingRect(
            with: CGSize(width: Double.infinity, height: .infinity),
            options: .usesLineFragmentOrigin,
            attributes: [.font: font, .kern: kerning],
            context: nil
        ).size
    }
}

private extension UITextField {
    func textRect(for range: Range<Int>) -> CGRect {
        if range.isEmpty {
            let pos = position(from: beginningOfDocument, offset: range.lowerBound)!
            return caretRect(for: pos)
        }

        let start = position(from: beginningOfDocument, offset: range.lowerBound)!
        let end = position(from: beginningOfDocument, offset: range.upperBound)!
        let range = textRange(from: start, to: end)!
        return firstRect(for: range)
    }
}
