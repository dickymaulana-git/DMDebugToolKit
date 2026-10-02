import Foundation
import Darwin

struct MemorySnapshot {
    let timestamp: Date
    let usedMB: Double
}

final class MemoryMonitor {

    static let shared = MemoryMonitor()

    private(set) var snapshots: [MemorySnapshot] = []

    private(set) var peakMemoryMB: Double = 0

    private var timer: Timer?

    private init() {}

    var currentMemoryMB: Double {
        Double(currentMemoryUsage()) / 1024 / 1024
    }

    func start() {
        guard timer == nil else {
            return
        }

        sample()

        timer = Timer.scheduledTimer(
            withTimeInterval: 1.0,
            repeats: true
        ) { [weak self] _ in
            self?.sample()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func reset() {
        snapshots.removeAll()
        peakMemoryMB = 0
    }

    private func sample() {
        let memory = currentMemoryMB

        let snapshot = MemorySnapshot(
            timestamp: Date(),
            usedMB: memory
        )

        snapshots.append(snapshot)

        peakMemoryMB = max(
            peakMemoryMB,
            memory
        )

        // Keep only the last 60 seconds
        if snapshots.count > 60 {
            snapshots.removeFirst()
        }
    }

    private func currentMemoryUsage() -> UInt64 {
        var info = mach_task_basic_info()

        var count = mach_msg_type_number_t(
            MemoryLayout<mach_task_basic_info>.size
            / MemoryLayout<integer_t>.size
        )

        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(
                to: integer_t.self,
                capacity: Int(count)
            ) {
                task_info(
                    mach_task_self_,
                    task_flavor_t(MACH_TASK_BASIC_INFO),
                    $0,
                    &count
                )
            }
        }

        guard result == KERN_SUCCESS else {
            return 0
        }

        return UInt64(info.resident_size)
    }
    
    var memoryGrowthMB: Double {
        guard let first = snapshots.first,
              let latest = snapshots.last
        else {
            return 0
        }

        return latest.usedMB - first.usedMB
    }

    var memoryTrendPerMinuteMB: Double {
        guard snapshots.count >= 2,
              let first = snapshots.first,
              let latest = snapshots.last
        else {
            return 0
        }

        let duration =
            latest.timestamp.timeIntervalSince(
                first.timestamp
            )

        guard duration > 0 else {
            return 0
        }

        return memoryGrowthMB / duration * 60
    }
}
