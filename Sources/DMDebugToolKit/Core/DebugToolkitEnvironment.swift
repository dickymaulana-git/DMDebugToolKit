import Foundation

public enum DebugToolkitEnvironment {

    case dev
    case uat
    case stg
    case prod

    public var displayName: String {
        switch self {
        case .dev:
            return "DEV"

        case .uat:
            return "UAT"

        case .stg:
            return "STG"

        case .prod:
            return "PROD"
        }
    }

    public var isEnabled: Bool {
        switch self {
        case .dev, .uat, .stg:
            return true

        case .prod:
            return false
        }
    }
}
