// NetworkLog

import Foundation

enum NetworkMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
    case head = "HEAD"
    case options = "OPTIONS"
    case unknown = "UNKNOWN"
}

struct NetworkLog: Identifiable {
    let id: UUID
    let timestamp: Date

    let method: String
    let url: String

    let statusCode: Int?
    let duration: TimeInterval

    let requestHeaders: [String: String]
    let requestBody: String?

    let responseHeaders: [String: String]
    let responseBody: String?
}
