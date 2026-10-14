import UIKit

final class DebugWindow: UIWindow {

    weak var interactiveView: UIView?
    var allowsFullInteraction = false

    override func hitTest(
        _ point: CGPoint,
        with event: UIEvent?
    ) -> UIView? {
        guard isHidden == false, alpha > 0.01 else {
            return nil
        }

        guard let hitView = super.hitTest(point, with: event) else {
            return nil
        }

        // Menu debug sedang terbuka.
        if allowsFullInteraction {
            return hitView
        }

        guard let interactiveView,
              !interactiveView.isHidden,
              interactiveView.alpha > 0.01,
              interactiveView.isUserInteractionEnabled
        else {
            return nil
        }

        // Convert point from window coordinates into button coordinates.
        let buttonPoint = interactiveView.convert(point, from: self)

        guard interactiveView.bounds.contains(buttonPoint) else {
            return nil
        }

        // Keep interaction limited to the floating button.
        let buttonHit = interactiveView.hitTest(
            buttonPoint,
            with: event
        )

        return buttonHit
    }
}
