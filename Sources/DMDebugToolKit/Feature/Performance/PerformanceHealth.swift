// PerformanceHealth.swift

import SwiftUI

enum PerformanceHealth {

    case healthy
    case warning
    case critical

    var title: String {
        switch self {
        case .healthy:
            return "Healthy"

        case .warning:
            return "Warning"

        case .critical:
            return "Critical"
        }
    }

    var color: Color {
        switch self {
        case .healthy:
            return DebugUIStyle.success

        case .warning:
            return DebugUIStyle.warning

        case .critical:
            return DebugUIStyle.critical
        }
    }

    static func fps(
        _ value: Double
    ) -> PerformanceHealth {

        if value >= 55 {
            return .healthy
        }

        if value >= 45 {
            return .warning
        }

        return .critical
    }

    static func cpu(
        _ value: Double
    ) -> PerformanceHealth {

        if value < 50 {
            return .healthy
        }

        if value <= 80 {
            return .warning
        }

        return .critical
    }

    static func memory(
        snapshots: [MemorySnapshot]
    ) -> PerformanceHealth {

        guard snapshots.count >= 10,
              let first = snapshots.first,
              let latest = snapshots.last
        else {
            return .healthy
        }

        let growth =
            latest.usedMB - first.usedMB

        let duration =
            latest.timestamp.timeIntervalSince(
                first.timestamp
            )

        guard duration > 0 else {
            return .healthy
        }

        let growthPerMinute =
            growth / duration * 60

        // Memory naik sangat sedikit / stabil
        if growthPerMinute < 5 {
            return .healthy
        }

        // Naik tetapi belum ekstrem
        if growthPerMinute < 15 {
            return .warning
        }

        return .critical
    }

    static func overall(
        _ healths: [PerformanceHealth]
    ) -> PerformanceHealth {

        if healths.contains(.critical) {
            return .critical
        }

        if healths.contains(.warning) {
            return .warning
        }

        return .healthy
    }
}
