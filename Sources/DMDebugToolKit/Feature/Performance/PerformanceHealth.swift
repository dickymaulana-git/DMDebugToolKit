
import SwiftUI

enum PerformanceHealth {
    case collecting
    case healthy
    case warning
    case critical

    var title: String {
        switch self {
        case .collecting:
            return "Collecting"
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
        case .collecting:
            return .secondary
        case .healthy:
            return .green
        case .warning:
            return .orange
        case .critical:
            return .red
        }
    }

    static func fps(_ value: Double) -> PerformanceHealth {
        if value >= 55 { return .healthy }
        if value >= 45 { return .warning }
        return .critical
    }

    static func cpu(_ value: Double) -> PerformanceHealth {
        if value < 50 { return .healthy }
        if value <= 80 { return .warning }
        return .critical
    }

    static func memory(
        snapshots: [MemorySnapshot]
    ) -> PerformanceHealth {
        let window = Array(snapshots.suffix(30))

        guard window.count >= 15 else {
            return .collecting
        }

        let baseline = Array(window.prefix(5)).map(\.usedMB)
        let recent = Array(window.suffix(5)).map(\.usedMB)

        let baselineAverage =
            baseline.reduce(0, +) / Double(baseline.count)

        let recentAverage =
            recent.reduce(0, +) / Double(recent.count)

        let growth = recentAverage - baselineAverage

        if growth <= 20 {
            return .healthy
        }

        if growth <= 50 {
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

        if !healths.isEmpty &&
            healths.allSatisfy({ $0 == .collecting }) {
            return .collecting
        }

        return .healthy
    }
}
