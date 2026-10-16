import SwiftUI

private enum DebugMenuColors {
    static let network = Color(red: 0.25, green: 0.48, blue: 0.92)
    static let networkConditions = Color(red: 0.58, green: 0.39, blue: 0.88)
    static let performance = Color(red: 0.15, green: 0.64, blue: 0.41)
    static let memory = Color(red: 0.10, green: 0.59, blue: 0.72)
    static let cache = Color(red: 0.91, green: 0.51, blue: 0.18)
    static let logs = Color(red: 0.78, green: 0.57, blue: 0.17)
    static let device = Color(red: 0.10, green: 0.61, blue: 0.56)
    static let appearance = Color(red: 0.80, green: 0.36, blue: 0.63)
}

struct DebugView: View {

    private static let appVersion = "2.0.0"

    @AppStorage("dm.debug.toolkit.themeMode")
    private var themeMode = "system"

    @State private var selectedTitle = ""
    @State private var selectedDestination: AnyView?
    @State private var swipeBackOffset: CGFloat = 0
    
    private var selectedColorScheme: ColorScheme? {
        switch themeMode {
        case "light":
            return .light
        case "dark":
            return .dark
        default:
            return nil
        }
    }

    private var hasCustomBackButton: Bool {
        [
            "Network Inspector",
            "Network Conditions",
            "Performance Monitor",
            "Memory Monitor",
            "Cache Manager",
            "Logs",
            "Device Info",
            "Appearance"
        ].contains(selectedTitle)
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()

                // Keep the menu behind the active screen so it is revealed
                // while the user swipes the screen to the right.
                menuContent
                    .zIndex(0)

                if let destination = selectedDestination {
                    destination
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .offset(x: swipeBackOffset)
                        .background {
                            DebugViewInteractiveSwipeBackGesture(
                                onChanged: { offset in
                                    // Update without animation so the screen follows the finger.
                                    swipeBackOffset = min(
                                        max(0, offset),
                                        UIScreen.main.bounds.width
                                    )
                                },
                                onEnded: { shouldGoBack in
                                    finishSwipeBack(shouldGoBack: shouldGoBack)
                                }
                            )
                            .frame(width: 0, height: 0)
                        }
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .trailing),
                                removal: .move(edge: .trailing)
                            )
                        )
                        .zIndex(1)
                }
            }
            .navigationTitle(
                selectedDestination == nil || hasCustomBackButton
                    ? ""
                    : selectedTitle
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if selectedDestination != nil && !hasCustomBackButton {
                        Button(action: goBackToMenu) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.primary)
                        }
                    }
                }
            }
            .navigationBarHidden(
                selectedDestination == nil || hasCustomBackButton
            )
        }
        .navigationViewStyle(.stack)
        .preferredColorScheme(selectedColorScheme)
    }

    // MARK: - Main Menu

    private var menuContent: some View {
        VStack(spacing: 0) {
            headerView

            ScrollView(showsIndicators: false) {
                VStack(
                    alignment: .leading,
                    spacing: 28
                ) {
                    // MARK: - Network

                    section(title: "Network") {
                        menuRow(
                            title: "Network Inspector",
                            subtitle: "HTTP request and response logs",
                            icon: "arrow.left.arrow.right",
                            color: DebugMenuColors.network
                        ) {
                            AnyView(NetworkInspectorView(onBack: { goBackToMenu()}))
                        }

                        menuRow(
                            title: "Network Conditions",
                            subtitle: "Simulate latency, timeout and failed requests",
                            icon: "antenna.radiowaves.left.and.right",
                            color: DebugMenuColors.networkConditions
                        ) {
                            AnyView(NetworkConditionsView(onBack: { goBackToMenu() }))
                        }
                    }

                    // MARK: - Performance

                    section(title: "Performance") {
                        menuRow(
                            title: "Performance Monitor",
                            subtitle: "FPS, CPU and memory usage",
                            icon: "speedometer",
                            color: DebugMenuColors.performance
                        ) {
                            AnyView(PerformanceMonitorView(onBack: { goBackToMenu() }))
                        }

                        menuRow(
                            title: "Memory Monitor",
                            subtitle: "Memory usage and history",
                            icon: "memorychip",
                            color: DebugMenuColors.memory
                        ) {
                            AnyView(MemoryMonitorView(onBack: { goBackToMenu()}))
                        }
                    }

                    // MARK: - Caching

                    section(title: "Caching") {
                        menuRow(
                            title: "Cache Manager",
                            subtitle: "Inspect and clear application cache",
                            icon: "externaldrive",
                            color: DebugMenuColors.cache
                        ) {
                            AnyView(CacheManagerView(onBack: { goBackToMenu() }))
                        }
                    }

                    // MARK: - Debug

                    section(title: "Debug") {
                        menuRow(
                            title: "Logs",
                            subtitle: "Application debug logs",
                            icon: "doc.text.magnifyingglass",
                            color: DebugMenuColors.logs
                        ) {
                            AnyView(DebugLogView(onBack: { goBackToMenu() }))
                        }

                        menuRow(
                            title: "Device Info",
                            subtitle: "Device and application information",
                            icon: "iphone",
                            color: DebugMenuColors.device
                        ) {
                            AnyView(DeviceInfoView(onBack: { goBackToMenu() }))
                        }
                    }

                    // MARK: - Settings

                    section(title: "Settings") {
                        menuRow(
                            title: "Appearance",
                            subtitle: "System, light and dark theme",
                            icon: "circle.lefthalf.filled",
                            color: DebugMenuColors.appearance
                        ) {
                            AnyView(DebugThemeSettingsView(onBack: { goBackToMenu() }))
                        }
                    }
                }
                .padding(.vertical, 24)
                .padding(.horizontal, 16)
            }
        }
        .background(Color(uiColor: .systemBackground))
    }

    // MARK: - Header

    private var headerView: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("DM Debug Toolkit")
                    .font(.system(size: 21, weight: .bold))
                    .foregroundStyle(.primary)

                Text("Developer debugging tools")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)

            Text("v\(Self.appVersion)")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color(uiColor: .secondarySystemBackground))
                )
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 8)
        .background(Color(uiColor: .systemBackground))
    }

    // MARK: - Back Navigation

    private func goBackToMenu() {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedDestination = nil
            selectedTitle = ""
            swipeBackOffset = 0
        }
    }

    private func finishSwipeBack(shouldGoBack: Bool) {
        guard selectedDestination != nil else { return }

        if shouldGoBack {
            // Finish moving the current screen out, then return to the menu.
            withAnimation(.easeOut(duration: 0.16)) {
                swipeBackOffset = UIScreen.main.bounds.width
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedDestination = nil
                    selectedTitle = ""
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    swipeBackOffset = 0
                }
            }
        } else {
            // The swipe was too short: spring the screen back into place.
            withAnimation(.interactiveSpring(response: 0.28, dampingFraction: 0.82)) {
                swipeBackOffset = 0
            }
        }
    }

    // MARK: - Section

    private func section<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: 10
        ) {
            Text(title)
                .font(DebugUIStyle.sectionTitle)
                .foregroundStyle(.secondary)
                .padding(.leading, 2)

            VStack(spacing: 4) {
                content()
            }
        }
    }

    // MARK: - Tap Gesture Row

    private func menuRow(
        title: String,
        subtitle: String,
        icon: String,
        color: Color,
        destination: @escaping () -> AnyView?
    ) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(
                    .system(
                        size: 14,
                        weight: .semibold
                    )
                )
                .foregroundStyle(color)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(color.opacity(0.12))
                )

            VStack(
                alignment: .leading,
                spacing: 4
            ) {
                Text(title)
                    .font(DebugUIStyle.bodyMedium)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(subtitle)
                    .font(DebugUIStyle.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
            }

            Spacer(minLength: 4)

            Image(systemName: "chevron.right")
                .font(
                    .system(
                        size: 14,
                        weight: .semibold
                    )
                )
                .foregroundStyle(.tertiary)
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
        .contentShape(RoundedRectangle(cornerRadius: 20))
        .onTapGesture {
            guard let destination = destination() else { return }

            swipeBackOffset = 0
            selectedTitle = title
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedDestination = destination
            }
        }
    }
}

// MARK: - Interactive Swipe-Back Gesture

/// Adds a left-edge pan recognizer to the enclosing UINavigationController view.
/// The gesture is used only to drive the existing manual screen selection.
private struct DebugViewInteractiveSwipeBackGesture: UIViewControllerRepresentable {
    let onChanged: (CGFloat) -> Void
    let onEnded: (Bool) -> Void

    func makeUIViewController(context: Context) -> GestureController {
        let controller = GestureController()
        controller.onChanged = onChanged
        controller.onEnded = onEnded
        return controller
    }

    func updateUIViewController(
        _ controller: GestureController,
        context: Context
    ) {
        controller.onChanged = onChanged
        controller.onEnded = onEnded
        controller.installGestureIfNeeded()
    }

    final class GestureController: UIViewController, UIGestureRecognizerDelegate {
        var onChanged: ((CGFloat) -> Void)?
        var onEnded: ((Bool) -> Void)?

        private weak var installedView: UIView?
        private var edgePan: UIScreenEdgePanGestureRecognizer?

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            installGestureIfNeeded()
        }

        override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)

            if let edgePan {
                installedView?.removeGestureRecognizer(edgePan)
            }

            edgePan = nil
            installedView = nil
        }

        func installGestureIfNeeded() {
            guard let navigationController = nearestNavigationController() else {
                return
            }

            let targetView = navigationController.view!

            if installedView === targetView, edgePan != nil {
                return
            }

            if let edgePan {
                installedView?.removeGestureRecognizer(edgePan)
            }

            let gesture = UIScreenEdgePanGestureRecognizer(
                target: self,
                action: #selector(handleEdgePan(_:))
            )
            gesture.edges = .left
            gesture.delegate = self
            gesture.cancelsTouchesInView = false

            targetView.addGestureRecognizer(gesture)
            installedView = targetView
            edgePan = gesture
        }

        private func nearestNavigationController() -> UINavigationController? {
            var current: UIViewController? = self

            while let controller = current {
                if let navigationController = controller as? UINavigationController {
                    return navigationController
                }

                if let navigationController = controller.navigationController {
                    return navigationController
                }

                current = controller.parent
            }

            return nil
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
                let velocity = gesture.velocity(in: gesture.view).x
                let width = gesture.view?.bounds.width ?? UIScreen.main.bounds.width
                let shouldGoBack =
                    translation > max(90, width * 0.28) ||
                    (velocity > 800 && translation > 24)

                onEnded?(shouldGoBack)

            case .cancelled, .failed:
                onEnded?(false)

            default:
                break
            }
        }

        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard let pan = gestureRecognizer as? UIPanGestureRecognizer else {
                return true
            }

            let velocity = pan.velocity(in: pan.view)
            return velocity.x > 0 && abs(velocity.x) > abs(velocity.y)
        }

        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            true
        }
    }
}

// MARK: - Theme Settings

struct DebugThemeSettingsView: View {

    @AppStorage("dm.debug.toolkit.themeMode")
    private var themeMode = "system"

    var onBack: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                DebugBackButton(action: onBack)
                Spacer()
                Color.clear.frame(width: 40, height: 40)
            }
            .overlay {
                Text("Appearance")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.primary)
                    .allowsHitTesting(false)
            }
            .padding()
            .background(Color(uiColor: .systemBackground))

            Form {
                Section {
                    themeOption(
                        title: "System",
                        subtitle: "Follow the app's system appearance",
                        value: "system",
                        icon: "iphone"
                    )

                    themeOption(
                        title: "Light",
                        subtitle: "Always use light appearance",
                        value: "light",
                        icon: "sun.max"
                    )

                    themeOption(
                        title: "Dark",
                        subtitle: "Always use dark appearance",
                        value: "dark",
                        icon: "moon"
                    )
                } footer: {
                    Text("This preference is saved for future sessions.")
                }
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationBarHidden(true)
        .navigationViewStyle(.stack)
        .preferredColorScheme(selectedColorScheme)
    }

    private var selectedColorScheme: ColorScheme? {
        switch themeMode {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    private func themeOption(
        title: String,
        subtitle: String,
        value: String,
        icon: String
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .frame(width: 28)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.primary)

                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if themeMode == value {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.tint)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            themeMode = value

            NotificationCenter.default.post(
                name: Notification.Name(
                    "DMDebugToolkitAppearanceDidChange"
                ),
                object: nil
            )
        }
    }
}

#if DEBUG
struct DebugView_Previews: PreviewProvider {
    private static let previewDefaults: UserDefaults = {
        let defaults = UserDefaults(
            suiteName: "DMDebugToolkitPreview"
        )!

        if defaults.object(
            forKey: "dm.debug.toolkit.themeMode"
        ) == nil {
            defaults.set(
                "system",
                forKey: "dm.debug.toolkit.themeMode"
            )
        }

        return defaults
    }()

    static var previews: some View {
        DebugView()
            .defaultAppStorage(previewDefaults)
            .previewDisplayName("DM Debug Toolkit")
    }
}
#endif
