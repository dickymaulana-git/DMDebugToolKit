// DebugLogger

import Foundation

enum DebugLogLevel: String {
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
    case debug = "DEBUG"
}

struct DebugLogEntry: Identifiable {
    let id = UUID()
    let timestamp: Date
    let level: DebugLogLevel
    let message: String
}

final class DebugLogger {

    static let shared = DebugLogger()

    private(set) var entries: [DebugLogEntry] = []

    private let queue = DispatchQueue(
        label: "DebugToolkit.Logger"
    )

    private let maxEntries = 500

    private init() {}

    func info(_ message: String) {
        add(
            level: .info,
            message: message
        )
    }

    func warning(_ message: String) {
        add(
            level: .warning,
            message: message
        )
    }

    func error(_ message: String) {
        add(
            level: .error,
            message: message
        )
    }

    func debug(_ message: String) {
        add(
            level: .debug,
            message: message
        )
    }

    func clear() {
        queue.sync {
            entries.removeAll()
        }
    }
    
    func allEntries() -> [DebugLogEntry] {
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

        print(
            "[\(level.rawValue)] \(message)"
        )
    }
}
