
import SwiftUI
import UIKit

struct DebugSwipeBackGesture: UIViewControllerRepresentable {
    var onBack: () -> Void
    var onChanged: (CGFloat) -> Void

    func makeUIViewController(context: Context) -> Controller {
        let controller = Controller()
        controller.onBack = onBack
        controller.onChanged = onChanged
        return controller
    }

    func updateUIViewController(
        _ controller: Controller,
        context: Context
    ) {
        controller.onBack = onBack
        controller.onChanged = onChanged
        controller.installGestureIfNeeded()
    }

    final class Controller: UIViewController,
                            UIGestureRecognizerDelegate {
        var onBack: (() -> Void)?
        var onChanged: ((CGFloat) -> Void)?

        private weak var gestureView: UIView?
        private var edgePan: UIScreenEdgePanGestureRecognizer?

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            installGestureIfNeeded()
        }

        func installGestureIfNeeded() {
            guard let navigationView =
                    navigationController?.view ?? parent?.view
            else {
                return
            }

            if gestureView === navigationView, edgePan != nil {
                return
            }

            if let edgePan {
                gestureView?.removeGestureRecognizer(edgePan)
            }

            let gesture = UIScreenEdgePanGestureRecognizer(
                target: self,
                action: #selector(handleEdgePan(_:))
            )

            gesture.edges = .left
            gesture.delegate = self
            gesture.cancelsTouchesInView = false

            navigationView.addGestureRecognizer(gesture)

            gestureView = navigationView
            edgePan = gesture
        }

        @objc private func handleEdgePan(
            _ gesture: UIScreenEdgePanGestureRecognizer
        ) {
            let translation = max(
                0,
                gesture.translation(in: gesture.view).x
            )

            switch gesture.state {
            case .began, .changed:
                onChanged?(translation)

            case .ended:
                let velocity = gesture.velocity(
                    in: gesture.view
                ).x

                let width = gesture.view?.bounds.width ?? 0

                if translation > width * 0.30 || velocity > 800 {
                    onChanged?(0)
                    onBack?()
                } else {
                    onChanged?(0)
                }

            case .cancelled, .failed:
                onChanged?(0)

            default:
                break
            }
        }

        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith
            otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            true
        }
    }
}
