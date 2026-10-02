import XCTest
@testable import DMDebugToolKit

final class DebugToolkitTests: XCTestCase {

    // MARK: - Network Recorder

    func testNetworkRecorderRecord() {
        let recorder = NetworkRecorder.shared

        recorder.clear()

        recorder.record(
            method: "POST",
            url: "https://example.com/users",
            statusCode: 201,
            duration: 0.123,
            requestHeaders: [
                "Content-Type": "application/json"
            ],
            requestBody: """
            {
              "name": "Dicky"
            }
            """,
            responseHeaders: [
                "Content-Type": "application/json"
            ],
            responseBody: """
            {
              "id": 1,
              "name": "Dicky"
            }
            """
        )

        XCTAssertEqual(
            recorder.allLogs().count,
            1
        )

        let log = recorder.allLogs()[0]

        XCTAssertEqual(
            log.method,
            "POST"
        )

        XCTAssertEqual(
            log.url,
            "https://example.com/users"
        )

        XCTAssertEqual(
            log.statusCode,
            201
        )

        XCTAssertEqual(
            log.duration,
            0.123,
            accuracy: 0.001
        )

        XCTAssertEqual(
            log.requestHeaders["Content-Type"],
            "application/json"
        )

        XCTAssertTrue(
            log.requestBody?.contains("Dicky") == true
        )

        XCTAssertTrue(
            log.responseBody?.contains("\"id\": 1") == true
        )
    }

    func testNetworkRecorderClear() {
        let recorder = NetworkRecorder.shared

        recorder.clear()

        recorder.record(
            method: "GET",
            url: "https://example.com",
            statusCode: 200,
            duration: 0.1
        )

        XCTAssertEqual(
            recorder.allLogs().count,
            1
        )

        recorder.clear()

        XCTAssertTrue(
            recorder.allLogs().isEmpty
        )
    }

    func testNetworkRecorderMaximumLogs() {
        let recorder = NetworkRecorder.shared

        recorder.clear()

        for index in 0..<250 {
            recorder.record(
                method: "GET",
                url: "https://example.com/\(index)",
                statusCode: 200,
                duration: 0.1
            )
        }

        XCTAssertEqual(
            recorder.allLogs().count,
            200
        )

        XCTAssertEqual(
            recorder.allLogs().first?.url,
            "https://example.com/249"
        )

        XCTAssertEqual(
            recorder.allLogs().last?.url,
            "https://example.com/50"
        )

        recorder.clear()
    }

    // MARK: - Debug Logger

    func testDebugLoggerLevels() {
        let logger = DebugLogger.shared

        logger.clear()

        logger.info("Info message")
        logger.warning("Warning message")
        logger.error("Error message")
        logger.debug("Debug message")

        XCTAssertEqual(
            logger.entries.count,
            4
        )

        XCTAssertEqual(
            logger.entries[0].level,
            .info
        )

        XCTAssertEqual(
            logger.entries[1].level,
            .warning
        )

        XCTAssertEqual(
            logger.entries[2].level,
            .error
        )

        XCTAssertEqual(
            logger.entries[3].level,
            .debug
        )

        XCTAssertEqual(
            logger.entries[0].message,
            "Info message"
        )

        logger.clear()
    }

    func testDebugLoggerClear() {
        let logger = DebugLogger.shared

        logger.clear()

        logger.info("Test")

        XCTAssertFalse(
            logger.entries.isEmpty
        )

        logger.clear()

        XCTAssertTrue(
            logger.entries.isEmpty
        )
    }

    func testDebugLoggerMaximumEntries() {
        let logger = DebugLogger.shared

        logger.clear()

        for index in 0..<600 {
            logger.info("Message \(index)")
        }

        XCTAssertEqual(
            logger.entries.count,
            500
        )

        XCTAssertEqual(
            logger.entries.first?.message,
            "Message 100"
        )

        XCTAssertEqual(
            logger.entries.last?.message,
            "Message 599"
        )

        logger.clear()
    }

    // MARK: - Performance Monitor

    func testPerformanceMonitorInitialState() {
        let monitor = PerformanceMonitor.shared

        monitor.stop()
        monitor.reset()

        XCTAssertEqual(
            monitor.currentFPS,
            0
        )

        XCTAssertEqual(
            monitor.currentCPUUsage,
            0
        )

        XCTAssertEqual(
            monitor.peakCPUUsage,
            0
        )

        XCTAssertTrue(
            monitor.snapshots.isEmpty
        )
    }

    func testPerformanceMonitorReset() {
        let monitor = PerformanceMonitor.shared

        monitor.stop()
        monitor.reset()

        XCTAssertTrue(
            monitor.snapshots.isEmpty
        )

        XCTAssertEqual(
            monitor.averageFPS,
            0
        )

        XCTAssertEqual(
            monitor.minimumFPS,
            0
        )

        XCTAssertEqual(
            monitor.averageCPUUsage,
            0
        )
    }

    // MARK: - Memory Monitor

    func testMemoryMonitorReset() {
        let monitor = MemoryMonitor.shared

        monitor.stop()
        monitor.reset()

        XCTAssertTrue(
            monitor.snapshots.isEmpty
        )

        XCTAssertEqual(
            monitor.peakMemoryMB,
            0
        )

        XCTAssertEqual(
            monitor.memoryGrowthMB,
            0
        )

        XCTAssertEqual(
            monitor.memoryTrendPerMinuteMB,
            0
        )
    }
}
