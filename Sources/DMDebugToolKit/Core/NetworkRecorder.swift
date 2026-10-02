import Foundation

final class NetworkRecorder {

    static let shared = NetworkRecorder()

    private(set) var logs: [NetworkLog] = []

    private let queue = DispatchQueue(
        label: "DebugToolkit.NetworkRecorder"
    )

    private let maxLogs = 200

    private init() {}

    func record(
        method: String,
        url: String,
        statusCode: Int?,
        duration: TimeInterval,
        requestHeaders: [String: String] = [:],
        requestBody: String? = nil,
        responseHeaders: [String: String] = [:],
        responseBody: String? = nil
    ) {

        let log = NetworkLog(
            id: UUID(),
            timestamp: Date(),
            method: method,
            url: url,
            statusCode: statusCode,
            duration: duration,
            requestHeaders: requestHeaders,
            requestBody: requestBody,
            responseHeaders: responseHeaders,
            responseBody: responseBody
        )

        queue.sync {
            logs.insert(
                log,
                at: 0
            )

            if logs.count > maxLogs {
                logs.removeLast(
                    logs.count - maxLogs
                )
            }
        }
    }

    func clear() {
        queue.sync {
            logs.removeAll()
        }
    }
    
    func allLogs() -> [NetworkLog] {
        queue.sync {
            logs
        }
    }
}
