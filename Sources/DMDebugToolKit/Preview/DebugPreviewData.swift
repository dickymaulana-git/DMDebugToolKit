#if DEBUG

import Foundation

enum DebugPreviewData {

    // MARK: - Network

    static let networkLogs: [NetworkLog] = [

        NetworkLog(
            id: UUID(),
            timestamp: Date().addingTimeInterval(-12),
            method: "GET",
            url: "https://jsonplaceholder.typicode.com/users/1",
            statusCode: 200,
            duration: 0.034,
            requestHeaders: [
                "Accept": "application/json",
                "Content-Type": "application/json",
                "X-App-Version": "1.0.0"
            ],
            requestBody: nil,
            responseHeaders: [
                "Age": "7688",
                "Cache-Control": "max-age=43200",
                "Content-Encoding": "br",
                "Content-Type": "application/json; charset=utf-8",
                "Date": "Fri, 02 Oct 2026 09:11:29 GMT"
            ],
            responseBody: """
            {
              "id": 1,
              "name": "Leanne Graham",
              "username": "Bret",
              "email": "Sincere@april.biz",
              "address": {
                "street": "Kulas Light",
                "suite": "Apt. 556",
                "city": "Gwenborough",
                "zipcode": "92998-3874",
                "geo": {
                  "lat": "-37.3159",
                  "lng": "81.1496"
                }
              },
              "phone": "1-770-736-8031 x56442",
              "website": "hildegard.org",
              "company": {
                "name": "Romaguera-Crona",
                "catchPhrase": "Multi-layered client-server neural-net",
                "bs": "harness real-time e-markets"
              }
            }
            """
        ),

        NetworkLog(
            id: UUID(),
            timestamp: Date().addingTimeInterval(-18),
            method: "POST",
            url: "https://api.example.com/v1/login",
            statusCode: 200,
            duration: 0.182,
            requestHeaders: [
                "Accept": "application/json",
                "Content-Type": "application/json",
                "X-App-Version": "1.0.0"
            ],
            requestBody: """
            {
              "username": "demo@example.com",
              "password": "***"
            }
            """,
            responseHeaders: [
                "Content-Type": "application/json",
                "Content-Length": "184"
            ],
            responseBody: """
            {
              "success": true,
              "token": "***",
              "expiresIn": 3600,
              "user": {
                "id": 1001,
                "name": "Demo User"
              }
            }
            """
        ),

        NetworkLog(
            id: UUID(),
            timestamp: Date().addingTimeInterval(-25),
            method: "PUT",
            url: "https://api.example.com/v1/profile",
            statusCode: 204,
            duration: 0.087,
            requestHeaders: [
                "Accept": "application/json",
                "Content-Type": "application/json",
                "Authorization": "***"
            ],
            requestBody: """
            {
              "name": "Demo User",
              "phone": "+62 812 3456 7890"
            }
            """,
            responseHeaders: [
                "Cache-Control": "no-cache",
                "Content-Length": "0"
            ],
            responseBody: nil
        ),

        NetworkLog(
            id: UUID(),
            timestamp: Date().addingTimeInterval(-31),
            method: "GET",
            url: "https://jsonplaceholder.typicode.com/users/999999",
            statusCode: 404,
            duration: 0.291,
            requestHeaders: [
                "Accept": "application/json"
            ],
            requestBody: nil,
            responseHeaders: [
                "Content-Type": "application/json; charset=utf-8",
                "Cache-Control": "no-cache"
            ],
            responseBody: """
            {
              "error": "User not found",
              "status": 404,
              "message": "The requested user does not exist."
            }
            """
        ),

        NetworkLog(
            id: UUID(),
            timestamp: Date().addingTimeInterval(-38),
            method: "DELETE",
            url: "https://api.example.com/v1/session",
            statusCode: 500,
            duration: 1.243,
            requestHeaders: [
                "Accept": "application/json",
                "Authorization": "***"
            ],
            requestBody: nil,
            responseHeaders: [
                "Content-Type": "application/json",
                "X-Request-ID": "preview-12345"
            ],
            responseBody: """
            {
              "error": "Internal Server Error",
              "message": "Something went wrong."
            }
            """
        )
    ]

    // MARK: - Performance

    static let performanceSnapshots: [PerformanceSnapshot] = {

        let fpsValues: [Double] = [
            60, 59, 60, 58, 57,
            60, 59, 56, 55, 58,
            60, 60, 59, 57, 58,
            60, 59, 60, 58, 57
        ]

        let cpuValues: [Double] = [
            8.2, 7.4, 9.1, 11.3, 14.2,
            12.8, 10.4, 18.6, 21.2, 16.4,
            9.8, 8.7, 12.1, 15.4, 13.2,
            10.8, 9.4, 11.7, 8.9, 10.2
        ]

        return fpsValues.indices.map { index in
            PerformanceSnapshot(
                timestamp: Date().addingTimeInterval(
                    TimeInterval(index - fpsValues.count)
                ),
                fps: fpsValues[index],
                cpuUsage: cpuValues[index]
            )
        }
    }()

    // MARK: - Memory

    static let memorySnapshots: [MemorySnapshot] = [

        MemorySnapshot(
            timestamp: Date().addingTimeInterval(-20),
            usedMB: 211.2
        ),

        MemorySnapshot(
            timestamp: Date().addingTimeInterval(-19),
            usedMB: 213.4
        ),

        MemorySnapshot(
            timestamp: Date().addingTimeInterval(-18),
            usedMB: 214.8
        ),

        MemorySnapshot(
            timestamp: Date().addingTimeInterval(-17),
            usedMB: 215.1
        ),

        MemorySnapshot(
            timestamp: Date().addingTimeInterval(-16),
            usedMB: 216.3
        ),

        MemorySnapshot(
            timestamp: Date().addingTimeInterval(-15),
            usedMB: 215.9
        ),

        MemorySnapshot(
            timestamp: Date().addingTimeInterval(-14),
            usedMB: 217.2
        ),

        MemorySnapshot(
            timestamp: Date().addingTimeInterval(-13),
            usedMB: 218.1
        ),

        MemorySnapshot(
            timestamp: Date().addingTimeInterval(-12),
            usedMB: 217.8
        ),

        MemorySnapshot(
            timestamp: Date().addingTimeInterval(-11),
            usedMB: 219.4
        ),

        MemorySnapshot(
            timestamp: Date().addingTimeInterval(-10),
            usedMB: 220.1
        ),

        MemorySnapshot(
            timestamp: Date().addingTimeInterval(-9),
            usedMB: 219.7
        ),

        MemorySnapshot(
            timestamp: Date().addingTimeInterval(-8),
            usedMB: 221.2
        ),

        MemorySnapshot(
            timestamp: Date().addingTimeInterval(-7),
            usedMB: 220.8
        ),

        MemorySnapshot(
            timestamp: Date().addingTimeInterval(-6),
            usedMB: 221.5
        ),

        MemorySnapshot(
            timestamp: Date().addingTimeInterval(-5),
            usedMB: 222.1
        ),

        MemorySnapshot(
            timestamp: Date().addingTimeInterval(-4),
            usedMB: 221.8
        ),

        MemorySnapshot(
            timestamp: Date().addingTimeInterval(-3),
            usedMB: 222.4
        ),

        MemorySnapshot(
            timestamp: Date().addingTimeInterval(-2),
            usedMB: 222.0
        ),

        MemorySnapshot(
            timestamp: Date().addingTimeInterval(-1),
            usedMB: 222.6
        ),

        MemorySnapshot(
            timestamp: Date(),
            usedMB: 222.4
        )
    ]

    // MARK: - Logs

    static let logs: [DebugLogEntry] = [

        DebugLogEntry(
            timestamp: Date().addingTimeInterval(-5),
            level: .info,
            message: "Application launched successfully."
        ),

        DebugLogEntry(
            timestamp: Date().addingTimeInterval(-12),
            level: .debug,
            message: "Fetching user profile from API."
        ),

        DebugLogEntry(
            timestamp: Date().addingTimeInterval(-20),
            level: .warning,
            message: "Network request took longer than expected: 842 ms."
        ),

        DebugLogEntry(
            timestamp: Date().addingTimeInterval(-28),
            level: .error,
            message: "Failed to load profile image."
        ),

        DebugLogEntry(
            timestamp: Date().addingTimeInterval(-35),
            level: .debug,
            message: "Cache lookup completed in 12 ms."
        ),

        DebugLogEntry(
            timestamp: Date().addingTimeInterval(-44),
            level: .info,
            message: "User session restored."
        ),

        DebugLogEntry(
            timestamp: Date().addingTimeInterval(-53),
            level: .warning,
            message: "Memory usage increased by 18.4 MB."
        ),

        DebugLogEntry(
            timestamp: Date().addingTimeInterval(-65),
            level: .error,
            message: "Request failed with status code 500."
        )
    ]

    // MARK: - Device

    static let deviceInfo = DeviceInfo(
        model: "iPhone",
        systemName: "iOS",
        systemVersion: "18.6.2",
        screenSize: "393 × 852",
        screenScale: "3.0x",
        locale: "en_ID",
        timezone: "Asia/Jakarta",
        bundleIdentifier: "com.example.DebugToolkitDemo",
        appVersion: "1.0.0",
        appBuild: "42"
    )
}

#endif
