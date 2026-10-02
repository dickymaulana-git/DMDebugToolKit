import UIKit
import SwiftUI

final class DebugViewController: UIViewController {

    let floatingButton: DebugFloatingButton

    private var hostingController:
        UIHostingController<DebugSheetHostView>?

    private let sheetState = DebugSheetState()

    private var hasInitialPosition = false

    init(
        buttonImage: UIImage?,
        environment: DebugToolkitEnvironment
    ) {

        floatingButton = DebugFloatingButton(
            image: buttonImage,
            environment: environment
        )

        super.init(
            nibName: nil,
            bundle: nil
        )
    }

    required init?(coder: NSCoder) {

        floatingButton = DebugFloatingButton(
            image: nil,
            environment: .dev
        )

        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear

        sheetState.onDismiss = { [weak self] in
            guard let self else {
                return
            }

            if let debugWindow = self.view.window as? DebugWindow {
                debugWindow.allowsFullInteraction = false
            }
        }

        setupSheetHost()
        setupFloatingButton()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard !hasInitialPosition else {
            return
        }

        hasInitialPosition = true

        let size: CGFloat = 52
        let margin: CGFloat = 16

        floatingButton.frame = CGRect(
            x: view.bounds.width - size - margin,
            y: view.bounds.height
                - size
                - view.safeAreaInsets.bottom
                - margin,
            width: size,
            height: size
        )
    }

    // MARK: - Sheet Host

    private func setupSheetHost() {

        let host = UIHostingController(
            rootView: DebugSheetHostView(
                state: sheetState
            )
        )

        host.view.backgroundColor = .clear

        addChild(host)

        view.insertSubview(
            host.view,
            at: 0
        )

        host.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(
                equalTo: view.topAnchor
            ),
            host.view.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            host.view.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            host.view.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            )
        ])

        host.didMove(toParent: self)

        hostingController = host
    }

    // MARK: - Floating Button

    private func setupFloatingButton() {

        view.addSubview(floatingButton)

        floatingButton.addTarget(
            self,
            action: #selector(openDebugMenu),
            for: .touchUpInside
        )

        let panGesture = UIPanGestureRecognizer(
            target: self,
            action: #selector(handlePan(_:))
        )

        panGesture.cancelsTouchesInView = false

        floatingButton.addGestureRecognizer(
            panGesture
        )
    }

    // MARK: - Drag

    @objc
    private func handlePan(
        _ gesture: UIPanGestureRecognizer
    ) {

        guard let button = gesture.view else {
            return
        }

        let translation = gesture.translation(
            in: view
        )

        button.center = CGPoint(
            x: button.center.x + translation.x,
            y: button.center.y + translation.y
        )

        gesture.setTranslation(
            .zero,
            in: view
        )

        clampButtonToScreen()

        if gesture.state == .ended ||
            gesture.state == .cancelled ||
            gesture.state == .failed {

            snapButtonToEdge()
        }
    }

    private func clampButtonToScreen() {

        let halfWidth =
            floatingButton.bounds.width / 2

        let halfHeight =
            floatingButton.bounds.height / 2

        let minX = halfWidth + 8

        let maxX =
            view.bounds.width
            - halfWidth
            - 8

        let minY =
            view.safeAreaInsets.top
            + halfHeight
            + 8

        let maxY =
            view.bounds.height
            - view.safeAreaInsets.bottom
            - halfHeight
            - 8

        floatingButton.center.x = min(
            max(
                floatingButton.center.x,
                minX
            ),
            maxX
        )

        floatingButton.center.y = min(
            max(
                floatingButton.center.y,
                minY
            ),
            maxY
        )
    }

    private func snapButtonToEdge() {

        let halfWidth =
            floatingButton.bounds.width / 2

        let leftX =
            halfWidth + 8

        let rightX =
            view.bounds.width
            - halfWidth
            - 8

        let targetX =
            floatingButton.center.x
                < view.bounds.width / 2
                ? leftX
                : rightX

        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: [
                .curveEaseOut,
                .beginFromCurrentState
            ]
        ) {

            self.floatingButton.center.x =
                targetX
        }
    }

    // MARK: - Debug Menu

    @objc
    private func openDebugMenu() {

        if let debugWindow = view.window as? DebugWindow {
            debugWindow.allowsFullInteraction = true
        }

        sheetState.present()
    }
}
