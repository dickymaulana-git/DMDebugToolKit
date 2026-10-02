import UIKit

public enum DebugToolkit {
    
    private static var overlayWindow: DebugWindow?
    private static var activationObserver: NSObjectProtocol?
    
    private static var configuration:
    DebugToolkitConfiguration?
    
    // MARK: - Start
    
    public static func start(
        configuration: DebugToolkitConfiguration
    ) {
        DispatchQueue.main.async {
            if !configuration.environment.isEnabled {
                stopImmediately()
                return
            }

            DebugToolkit.configuration = configuration

            teardownOverlay()
            setup()
        }
    }
    
    private static func stopImmediately() {
        removeActivationObserver()
        teardownOverlay()
        configuration = nil
    }
    
    private static func teardownOverlay() {
        overlayWindow?.rootViewController = nil
        overlayWindow?.isHidden = true
        overlayWindow = nil
    }
    
    // MARK: - Stop
    
    public static func stop() {
        DispatchQueue.main.async {
            stopImmediately()
        }
    }
    
    // MARK: - Setup
    
    private static func setup() {
        
        guard overlayWindow == nil else {
            return
        }
        
        guard let configuration else {
            return
        }
        
        guard configuration.environment.isEnabled else {
            return
        }
        
        guard let scene =
                UIApplication.shared.connectedScenes
            .compactMap({
                $0 as? UIWindowScene
            })
                .first(where: {
                    $0.activationState == .foregroundActive
                })
        else {
            observeSceneActivation()
            return
        }
        
        let window = DebugWindow(
            windowScene: scene
        )
        
        let buttonImage: UIImage?
        
        if let icon = configuration.icon {
            buttonImage = icon
        } else if let systemIcon =
                    configuration.systemIcon {
            buttonImage = UIImage(
                systemName: systemIcon
            )
        } else {
            buttonImage = UIImage(
                systemName: "hammer.fill"
            )
        }
        
        let viewController = DebugViewController(
            buttonImage: buttonImage,
            environment: configuration.environment
        )
        
        window.rootViewController = viewController
        window.backgroundColor = .clear
        window.windowLevel = .alert + 1
        
        // Force view loading so floatingButton is ready.
        _ = viewController.view
        
        window.interactiveView =
        viewController.floatingButton
        
        window.isHidden = false
        
        overlayWindow = window
        
        removeActivationObserver()
    }
    
    // MARK: - Scene Activation
    
    private static func observeSceneActivation() {
        
        guard activationObserver == nil else {
            return
        }
        
        activationObserver =
        NotificationCenter.default.addObserver(
            forName: UIScene.didActivateNotification,
            object: nil,
            queue: .main
        ) { _ in
            setup()
        }
    }
    
    private static func removeActivationObserver() {
        
        guard let activationObserver else {
            return
        }
        
        NotificationCenter.default.removeObserver(
            activationObserver
        )
        
        DebugToolkit.activationObserver = nil
    }
    
    // MARK: - Network
    
    public static func recordNetwork(
        method: String,
        url: String,
        statusCode: Int?,
        duration: TimeInterval,
        requestHeaders: [String: String],
        requestBody: String?,
        responseHeaders: [String: String],
        responseBody: String?
    ) {
        NetworkRecorder.shared.record(
            method: method,
            url: url,
            statusCode: statusCode,
            duration: duration,
            requestHeaders: requestHeaders,
            requestBody: requestBody,
            responseHeaders: responseHeaders,
            responseBody: responseBody
        )
    }
}
