import UIKit

final class DebugWindow: UIWindow {

    weak var interactiveView: UIView?

    var allowsFullInteraction = false

    override func hitTest(
        _ point: CGPoint,
        with event: UIEvent?
    ) -> UIView? {

        let hitView = super.hitTest(
            point,
            with: event
        )

        if allowsFullInteraction {
            return hitView
        }

        guard let interactiveView else {
            return nil
        }

        if hitView === interactiveView ||
            hitView?.isDescendant(
                of: interactiveView
            ) == true {

            return hitView
        }

        return nil
    }
}
