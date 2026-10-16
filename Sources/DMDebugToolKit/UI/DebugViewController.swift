
import UIKit
import SwiftUI

final class DebugViewController: UIViewController {

    let floatingButton: DebugFloatingButton

    private var hostingController:
        UIHostingController<DebugSheetHostView>?

    private let sheetState = DebugSheetState()
    
    private let appearanceKey = "dm.debug.toolkit.themeMode"
    private var appearanceObserver: NSObjectProtocol?

    private var hasInitialPosition = false
    private var dragStartCenter: CGPoint = .zero
    private var isDragging = false

    private let buttonSize: CGFloat = 52
    private let edgeMargin: CGFloat = 12
    private let dragThreshold: CGFloat = 8

    private let positionXKey =
        "DMDebugToolkit.FloatingButton.PositionX"

    private let positionYKey =
        "DMDebugToolkit.FloatingButton.PositionY"

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

        observeAppearanceChanges()

        sheetState.onDismiss = { [weak self] in
            guard let self else { return }

            if let debugWindow = self.view.window as? DebugWindow {
                debugWindow.allowsFullInteraction = false
            }
        }

        setupSheetHost()
        setupFloatingButton()
        applyDebugAppearance()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard
            view.bounds.width > 0,
            view.bounds.height > 0
        else {
            return
        }

        if !hasInitialPosition {
            hasInitialPosition = true

            floatingButton.frame = CGRect(
                x: 0,
                y: 0,
                width: buttonSize,
                height: buttonSize
            )

            restoreOrSetInitialPosition()
        } else {
            floatingButton.center = clampedCenter(
                floatingButton.center
            )
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        applyDebugAppearance()
    }

    deinit {
        if let appearanceObserver {
            NotificationCenter.default.removeObserver(appearanceObserver)
        }
    }

    private func observeAppearanceChanges() {
        appearanceObserver = NotificationCenter.default.addObserver(
            forName: Notification.Name(
                "DMDebugToolkitAppearanceDidChange"
            ),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.applyDebugAppearance()
        }
    }

    private func applyDebugAppearance() {
        let mode = UserDefaults.standard.string(
            forKey: "dm.debug.toolkit.themeMode"
        ) ?? "system"

        let style: UIUserInterfaceStyle

        switch mode {
        case "light":
            style = .light
        case "dark":
            style = .dark
        default:
            style = .unspecified
        }

        overrideUserInterfaceStyle = style
        hostingController?.overrideUserInterfaceStyle = style

        if let debugWindow = view.window as? DebugWindow {
            debugWindow.overrideUserInterfaceStyle = style
        }
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
        floatingButton.frame = CGRect(
            x: 0,
            y: 0,
            width: buttonSize,
            height: buttonSize
        )

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

        // Drag cancels the button's touch tracking.
        // A normal tap still triggers .touchUpInside.
        panGesture.cancelsTouchesInView = true
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1

        floatingButton.addGestureRecognizer(panGesture)
    }

    // MARK: - Initial Position

    private func restoreOrSetInitialPosition() {
        let defaults = UserDefaults.standard

        if
            defaults.object(forKey: positionXKey) != nil,
            defaults.object(forKey: positionYKey) != nil
        {
            floatingButton.center = CGPoint(
                x: defaults.double(forKey: positionXKey)
                    * view.bounds.width,
                y: defaults.double(forKey: positionYKey)
                    * view.bounds.height
            )
        } else {
            // First launch: top-right, inside the safe area.
            let safeInsets = view.safeAreaInsets

            floatingButton.center = CGPoint(
                x: view.bounds.maxX
                    - safeInsets.right
                    - edgeMargin
                    - buttonSize / 2,
                y: view.bounds.minY
                    + safeInsets.top
                    + edgeMargin
                    + buttonSize / 2
            )
        }

        floatingButton.center = clampedCenter(
            floatingButton.center
        )

        savePosition()
    }

    // MARK: - Drag

    @objc
    private func handlePan(
        _ gesture: UIPanGestureRecognizer
    ) {
        switch gesture.state {
        case .began:
            dragStartCenter = floatingButton.center
            isDragging = false

        case .changed:
            let translation = gesture.translation(in: view)

            if hypot(
                translation.x,
                translation.y
            ) >= dragThreshold {
                isDragging = true
            }

            guard isDragging else {
                return
            }

            let proposedCenter = CGPoint(
                x: dragStartCenter.x + translation.x,
                y: dragStartCenter.y + translation.y
            )

            floatingButton.center = clampedCenter(
                proposedCenter
            )

        case .ended:
            guard isDragging else {
                return
            }

            let translation = gesture.translation(in: view)

            floatingButton.center = clampedCenter(
                CGPoint(
                    x: dragStartCenter.x + translation.x,
                    y: dragStartCenter.y + translation.y
                )
            )

            snapButtonToEdge()
            isDragging = false

        case .cancelled, .failed:
            if isDragging {
                snapButtonToEdge()
            }

            isDragging = false

        default:
            break
        }
    }

    // MARK: - Clamp To Safe Area

    private func clampedCenter(
        _ proposedCenter: CGPoint
    ) -> CGPoint {
        let bounds = view.bounds
        let safeInsets = view.safeAreaInsets

        let halfWidth = floatingButton.bounds.width / 2
        let halfHeight = floatingButton.bounds.height / 2

        let minX = safeInsets.left
            + edgeMargin
            + halfWidth

        let maxX = bounds.width
            - safeInsets.right
            - edgeMargin
            - halfWidth

        let minY = safeInsets.top
            + edgeMargin
            + halfHeight

        let maxY = bounds.height
            - safeInsets.bottom
            - edgeMargin
            - halfHeight

        return CGPoint(
            x: min(
                max(proposedCenter.x, minX),
                max(maxX, minX)
            ),
            y: min(
                max(proposedCenter.y, minY),
                max(maxY, minY)
            )
        )
    }

    // MARK: - Snap To Nearest Edge

    private func snapButtonToEdge() {
        let halfWidth = floatingButton.bounds.width / 2
        let safeInsets = view.safeAreaInsets

        let leftX = safeInsets.left
            + edgeMargin
            + halfWidth

        let rightX = view.bounds.width
            - safeInsets.right
            - edgeMargin
            - halfWidth

        let targetX = floatingButton.center.x
            < view.bounds.midX
            ? leftX
            : rightX

        let target = clampedCenter(
            CGPoint(
                x: targetX,
                y: floatingButton.center.y
            )
        )

        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            usingSpringWithDamping: 0.85,
            initialSpringVelocity: 0.4,
            options: [
                .curveEaseOut,
                .beginFromCurrentState,
                .allowUserInteraction
            ]
        ) {
            self.floatingButton.center = target
        } completion: { [weak self] _ in
            self?.savePosition()
        }
    }

    // MARK: - Save Position

    private func savePosition() {
        guard
            view.bounds.width > 0,
            view.bounds.height > 0
        else {
            return
        }

        let defaults = UserDefaults.standard

        defaults.set(
            Double(floatingButton.center.x / view.bounds.width),
            forKey: positionXKey
        )

        defaults.set(
            Double(floatingButton.center.y / view.bounds.height),
            forKey: positionYKey
        )
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
