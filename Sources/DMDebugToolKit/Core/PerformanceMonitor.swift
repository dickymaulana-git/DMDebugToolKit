// PerformanceMonitor.swift

import Foundation
import UIKit
import Darwin

struct PerformanceSnapshot {
    let timestamp: Date
    let fps: Double
    let cpuUsage: Double
}

final class PerformanceMonitor {

    static let shared = PerformanceMonitor()

    private(set) var snapshots: [PerformanceSnapshot] = []

    private var displayLink: CADisplayLink?
    private var timer: Timer?

    private var frameCount = 0
    private var lastFrameTimestamp: CFTimeInterval = 0

    private(set) var currentFPS: Double = 0
    private(set) var currentCPUUsage: Double = 0
    private(set) var peakCPUUsage: Double = 0
    
    var averageFPS: Double {
        let validFPS = snapshots
            .map(\.fps)
            .filter { $0 > 0 }

        guard !validFPS.isEmpty else {
            return 0
        }

        return validFPS.reduce(0, +)
            / Double(validFPS.count)
    }

    var minimumFPS: Double {
        snapshots
            .map(\.fps)
            .filter { $0 > 0 }
            .min() ?? 0
    }

    var averageCPUUsage: Double {

        guard !snapshots.isEmpty else {
            return 0
        }

        return snapshots
            .map(\.cpuUsage)
            .reduce(0, +)
            / Double(snapshots.count)
    }

    private init() {}

    // MARK: - Start

    func start() {
        guard displayLink == nil else {
            return
        }

        frameCount = 0
        lastFrameTimestamp = 0

        let link = CADisplayLink(
            target: self,
            selector: #selector(frameTick)
        )

        link.add(
            to: .main,
            forMode: .common
        )

        displayLink = link

        timer = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: true
        ) { [weak self] _ in
            self?.samplePerformance()
        }
    }

    // MARK: - Stop

    func stop() {
        displayLink?.invalidate()
        displayLink = nil

        timer?.invalidate()
        timer = nil
    }

    // MARK: - Reset

    func reset() {
        snapshots.removeAll()

        currentFPS = 0
        currentCPUUsage = 0
        peakCPUUsage = 0

        frameCount = 0
        lastFrameTimestamp = 0
    }

    // MARK: - Performance Sampling

    private func samplePerformance() {

        let cpu = currentCPUUsageValue()

        currentCPUUsage = cpu
        peakCPUUsage = max(
            peakCPUUsage,
            cpu
        )

        let snapshot = PerformanceSnapshot(
            timestamp: Date(),
            fps: currentFPS,
            cpuUsage: cpu
        )

        snapshots.append(snapshot)

        if snapshots.count > 60 {
            snapshots.removeFirst()
        }
    }

    // MARK: - FPS

    @objc
    private func frameTick(
        _ displayLink: CADisplayLink
    ) {
        if lastFrameTimestamp == 0 {
            lastFrameTimestamp = displayLink.timestamp
            return
        }

        frameCount += 1

        let elapsed =
            displayLink.timestamp - lastFrameTimestamp

        guard elapsed >= 1 else {
            return
        }

        currentFPS =
            Double(frameCount) / elapsed

        frameCount = 0
        lastFrameTimestamp =
            displayLink.timestamp
    }

    // MARK: - CPU

    private func currentCPUUsageValue() -> Double {

        var threadList: thread_act_array_t?
        var threadCount: mach_msg_type_number_t = 0

        let result = task_threads(
            mach_task_self_,
            &threadList,
            &threadCount
        )

        guard result == KERN_SUCCESS,
              let threadList
        else {
            return 0
        }

        var totalCPUUsage: Double = 0

        for index in 0..<Int(threadCount) {

            let thread = threadList[index]

            var info = thread_basic_info()

            var count = mach_msg_type_number_t(
                MemoryLayout<thread_basic_info>.size
                / MemoryLayout<integer_t>.size
            )

            let result = withUnsafeMutablePointer(
                to: &info
            ) { pointer in

                pointer.withMemoryRebound(
                    to: integer_t.self,
                    capacity: Int(count)
                ) {

                    thread_info(
                        thread,
                        thread_flavor_t(
                            THREAD_BASIC_INFO
                        ),
                        $0,
                        &count
                    )
                }
            }

            if result == KERN_SUCCESS {

                if (info.flags & TH_FLAGS_IDLE) == 0 {

                    totalCPUUsage +=
                        Double(info.cpu_usage)
                        / Double(TH_USAGE_SCALE)
                        * 100
                }
            }

            mach_port_deallocate(
                mach_task_self_,
                thread
            )
        }

        let size = vm_size_t(
            threadCount
            * mach_msg_type_number_t(
                MemoryLayout<thread_t>.stride
            )
        )

        vm_deallocate(
            mach_task_self_,
            vm_address_t(
                UInt(bitPattern: threadList)
            ),
            size
        )

        return totalCPUUsage
    }
}
