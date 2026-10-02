import UIKit
import SwiftUI

final class DebugSheetViewController: UIViewController {

    private let dimView = UIView()
    private let sheetView = UIView()

    private var hostingController:
        UIHostingController<DebugView>?

    private var sheetBottomConstraint:
        NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBackground()
        setupSheet()
        setupContent()
        setupGestures()
    }

    // MARK: - Background

    private func setupBackground() {

        view.backgroundColor = .clear

        dimView.backgroundColor =
            UIColor.black.withAlphaComponent(0.28)

        view.addSubview(dimView)

        dimView.translatesAutoresizingMaskIntoConstraints =
            false

        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(
                equalTo: view.topAnchor
            ),
            dimView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            dimView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            dimView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            )
        ])

        dimView.alpha = 0
    }

    // MARK: - Sheet

    private func setupSheet() {

        sheetView.backgroundColor =
            .systemBackground

        sheetView.layer.cornerRadius = 22

        sheetView.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner
        ]

        sheetView.clipsToBounds = true

        view.addSubview(sheetView)

        sheetView.translatesAutoresizingMaskIntoConstraints =
            false

        sheetBottomConstraint =
            sheetView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor,
                constant: 500
            )

        NSLayoutConstraint.activate([
            sheetView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),

            sheetView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),

            sheetView.heightAnchor.constraint(
                equalTo: view.heightAnchor,
                multiplier: 0.90
            ),

            sheetBottomConstraint
        ])
    }

    // MARK: - Content

    private func setupContent() {

        let hostingController =
            UIHostingController(
                rootView: DebugView()
            )

        self.hostingController =
            hostingController

        addChild(hostingController)

        sheetView.addSubview(
            hostingController.view
        )

        hostingController.view.backgroundColor =
            .clear

        hostingController.view.translatesAutoresizingMaskIntoConstraints =
            false

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(
                equalTo: sheetView.topAnchor
            ),

            hostingController.view.leadingAnchor.constraint(
                equalTo: sheetView.leadingAnchor
            ),

            hostingController.view.trailingAnchor.constraint(
                equalTo: sheetView.trailingAnchor
            ),

            hostingController.view.bottomAnchor.constraint(
                equalTo: sheetView.bottomAnchor
            )
        ])

        hostingController.didMove(
            toParent: self
        )
    }

    // MARK: - Gestures

    private func setupGestures() {

        let tapGesture =
            UITapGestureRecognizer(
                target: self,
                action: #selector(
                    handleBackgroundTap
                )
            )

        dimView.addGestureRecognizer(
            tapGesture
        )

        let panGesture =
            UIPanGestureRecognizer(
                target: self,
                action: #selector(
                    handleSheetPan(_:)
                )
            )

        sheetView.addGestureRecognizer(
            panGesture
        )
    }

    @objc
    private func handleBackgroundTap() {
        dismissSheet()
    }

    // MARK: - Sheet Pan

    @objc
    private func handleSheetPan(
        _ gesture: UIPanGestureRecognizer
    ) {
        let translation =
            gesture.translation(in: view)

        switch gesture.state {

        case .changed:

            guard translation.y > 0 else {
                return
            }

            sheetBottomConstraint.constant =
                translation.y

        case .ended:

            if translation.y > 120 {
                dismissSheet()
            } else {
                UIView.animate(
                    withDuration: 0.25
                ) {
                    self.sheetBottomConstraint.constant = 0
                    self.view.layoutIfNeeded()
                }
            }

        default:
            break
        }
    }

    // MARK: - Presentation

    override func viewDidAppear(
        _ animated: Bool
    ) {
        super.viewDidAppear(animated)

        sheetBottomConstraint.constant = 0

        UIView.animate(
            withDuration: 0.28,
            delay: 0,
            options: [.curveEaseOut]
        ) {
            self.dimView.alpha = 1
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - Dismiss

    private func dismissSheet() {

        // Kembalikan DebugWindow ke mode
        // floating-button-only sebelum dismiss.
        if let debugWindow =
            view.window as? DebugWindow {

            debugWindow.allowsFullInteraction = false
        }

        sheetBottomConstraint.constant =
            view.bounds.height

        UIView.animate(
            withDuration: 0.22,
            delay: 0,
            options: [.curveEaseIn]
        ) {
            self.dimView.alpha = 0
            self.view.layoutIfNeeded()
        } completion: { _ in

            self.dismiss(
                animated: false
            )
        }
    }
}
