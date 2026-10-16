// DebugLogger

import Foundation

public enum DebugLogLevel: String {
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
    case debug = "DEBUG"
}

public struct DebugLogEntry: Identifiable {
    public let id = UUID()
    public let timestamp: Date
    public let level: DebugLogLevel
    public let message: String

    public init(
        timestamp: Date,
        level: DebugLogLevel,
        message: String
    ) {
        self.timestamp = timestamp
        self.level = level
        self.message = message
    }
}

public final class DebugLogger {
    public static let shared = DebugLogger()

    private(set) public var entries: [DebugLogEntry] = []

    private let queue = DispatchQueue(
        label: "DebugToolkit.Logger"
    )

    private let maxEntries = 500

    private init() {}

    public func info(_ message: String) {
        add(level: .info, message: message)
    }

    public func warning(_ message: String) {
        add(level: .warning, message: message)
    }

    public func error(_ message: String) {
        add(level: .error, message: message)
    }

    public func debug(_ message: String) {
        add(level: .debug, message: message)
    }

    public func clear() {
        queue.sync {
            entries.removeAll()
        }
    }

    public func allEntries() -> [DebugLogEntry] {
        queue.sync {
            entries
        }
    }

    private func add(
        level: DebugLogLevel,
        message: String
    ) {
        let entry = DebugLogEntry(
            timestamp: Date(),
            level: level,
            message: message
        )

        queue.sync {
            entries.append(entry)

            if entries.count > maxEntries {
                entries.removeFirst(
                    entries.count - maxEntries
                )
            }
        }

        print("[\(level.rawValue)] \(message)")
    }
}
