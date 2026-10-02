import Foundation
import Moya
import DMDebugToolKit

public final class DebugMoyaPlugin: PluginType {

    private let maxBodySize = 100_000

    private let sensitiveHeaders: Set<String> = [
        "authorization",
        "cookie",
        "set-cookie",
        "proxy-authorization",
        "x-api-key",
        "api-key"
    ]

    private struct RequestContext {
        let startTime: Date
        let request: URLRequest
    }

    private var contexts: [String: [RequestContext]] = [:]

    private let lock = NSLock()

    public init() {}

    public func willSend(
        _ request: RequestType,
        target: TargetType
    ) {
        guard let urlRequest = request.request else {
            return
        }

        let key = requestKey(from: urlRequest)

        let context = RequestContext(
            startTime: Date(),
            request: urlRequest
        )

        lock.lock()
        contexts[key, default: []].append(context)
        lock.unlock()
    }

    public func didReceive(
        _ result: Result<Response, MoyaError>,
        target: TargetType
    ) {
        let response: Response?

        switch result {
        case .success(let value):
            response = value

        case .failure(let error):
            response = error.response
        }

        guard let response else {
            return
        }

        let urlRequest = response.request

        let key = requestKey(
            method: urlRequest?.httpMethod,
            url: urlRequest?.url
        )

        let context = popContext(for: key)

        let duration: TimeInterval

        if let context {
            duration = Date().timeIntervalSince(
                context.startTime
            )
        } else {
            duration = 0
        }

        let requestHeaders = sanitizeHeaders(
            context?.request.allHTTPHeaderFields ?? [:]
        )

        let requestBody = bodyString(
            from: context?.request.httpBody
        )

        let responseHeaders =
            response.response?.allHeaderFields.reduce(
                into: [String: String]()
            ) { result, item in

                result[String(describing: item.key)] =
                    String(describing: item.value)
            } ?? [:]

        let responseBody = bodyString(
            from: response.data
        )

        DebugToolkit.recordNetwork(
            method: urlRequest?.httpMethod ?? "-",
            url: urlRequest?.url?.absoluteString ?? "-",
            statusCode: response.statusCode,
            duration: duration,
            requestHeaders: requestHeaders,
            requestBody: requestBody,
            responseHeaders: sanitizeHeaders(responseHeaders),
            responseBody: responseBody
        )
    }

    private func popContext(
        for key: String
    ) -> RequestContext? {

        lock.lock()
        defer {
            lock.unlock()
        }

        guard var values = contexts[key],
              !values.isEmpty
        else {
            return nil
        }

        let context = values.removeFirst()

        if values.isEmpty {
            contexts.removeValue(forKey: key)
        } else {
            contexts[key] = values
        }

        return context
    }

    private func requestKey(
        from request: URLRequest
    ) -> String {
        requestKey(
            method: request.httpMethod,
            url: request.url
        )
    }

    private func requestKey(
        method: String?,
        url: URL?
    ) -> String {
        "\(method ?? "-")|\(url?.absoluteString ?? "-")"
    }

    private func bodyString(
        from data: Data?
    ) -> String? {

        guard let data,
              !data.isEmpty
        else {
            return nil
        }

        let limitedData = data.count > maxBodySize
            ? Data(data.prefix(maxBodySize))
            : data

        let body: String

        if let jsonObject = try? JSONSerialization.jsonObject(
            with: limitedData
        ),
        let prettyData = try? JSONSerialization.data(
            withJSONObject: jsonObject,
            options: [.prettyPrinted]
        ),
        let prettyString = String(
            data: prettyData,
            encoding: .utf8
        ) {
            body = prettyString
        } else {
            body = String(
                data: limitedData,
                encoding: .utf8
            ) ?? "<Binary Data>"
        }

        if data.count > maxBodySize {
            return body + "\n\n...[truncated]"
        }

        return body
    }

    private func sanitizeHeaders(
        _ headers: [String: String]
    ) -> [String: String] {

        headers.reduce(into: [:]) { result, item in

            if sensitiveHeaders.contains(
                item.key.lowercased()
            ) {
                result[item.key] = "***"
            } else {
                result[item.key] = item.value
            }
        }
    }
}
