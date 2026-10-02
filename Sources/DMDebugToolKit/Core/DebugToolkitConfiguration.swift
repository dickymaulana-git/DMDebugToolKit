import UIKit

public struct DebugToolkitConfiguration {

    public let environment: DebugToolkitEnvironment
    public let icon: UIImage?
    public let systemIcon: String?

    public init(
        environment: DebugToolkitEnvironment,
        icon: UIImage? = nil,
        systemIcon: String? = nil
    ) {
        self.environment = environment
        self.icon = icon
        self.systemIcon = systemIcon
    }
}
