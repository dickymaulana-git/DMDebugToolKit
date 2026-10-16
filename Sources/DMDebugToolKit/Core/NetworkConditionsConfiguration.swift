import Foundation

public enum NetworkConditionMode: String, CaseIterable, Identifiable {
    case normal
    case latency
    case failure
    case timeout

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .normal: return "Normal"
        case .latency: return "Artificial Latency"
        case .failure: return "Simulate Failure"
        case .timeout: return "Simulate Timeout"
        }
    }

    public var subtitle: String {
        switch self {
        case .normal:
            return "Send requests normally"
        case .latency:
            return "Delay requests before they are sent"
        case .failure:
            return "Fail requests without contacting the server"
        case .timeout:
            return "Return a timeout error after the configured delay"
        }
    }

    public var systemImage: String {
        switch self {
        case .normal: return "checkmark.circle"
        case .latency: return "hourglass"
        case .failure: return "xmark.octagon"
        case .timeout: return "clock.badge.exclamationmark"
        }
    }
}

/// Shared configuration for the Network Conditions UI and the optional Moya integration.
public struct NetworkConditionsConfiguration {
    public static let modeKey = "dm.debug.networkConditions.mode"
    public static let latencyMillisecondsKey = "dm.debug.networkConditions.latencyMilliseconds"
    public static let timeoutSecondsKey = "dm.debug.networkConditions.timeoutSeconds"

    public let mode: NetworkConditionMode
    public let latencyMilliseconds: Double
    public let timeoutSeconds: Double

    public static var current: NetworkConditionsConfiguration {
        let defaults = UserDefaults.standard
        defaults.register(defaults: [
            modeKey: NetworkConditionMode.normal.rawValue,
            latencyMillisecondsKey: 1500.0,
            timeoutSecondsKey: 10.0
        ])

        let storedMode = defaults.string(forKey: modeKey) ?? NetworkConditionMode.normal.rawValue
        let mode = NetworkConditionMode(rawValue: storedMode) ?? .normal
        let latency = defaults.double(forKey: latencyMillisecondsKey)
        let timeout = defaults.double(forKey: timeoutSecondsKey)

        return NetworkConditionsConfiguration(
            mode: mode,
            latencyMilliseconds: min(max(latency, 250), 5000),
            timeoutSeconds: min(max(timeout, 1), 30)
        )
    }
}
