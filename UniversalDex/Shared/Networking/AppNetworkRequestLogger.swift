//
//  AppNetworkRequestLogger.swift
//  UniversalDex
//
//  Created by Codex on 09/05/2026.
//

import Foundation

enum AppNetworkRequestLogger {
    static func register() {
        #if DEBUG
        let didRegister = URLProtocol.registerClass(AppNetworkRequestLoggingURLProtocol.self)

        if didRegister {
            AppDebugLog.log("Network request logging enabled")
        } else {
            AppDebugLog.log("Network request logging was already enabled")
        }
        #endif
    }
}

#if DEBUG
private final class AppNetworkRequestLoggingURLProtocol: URLProtocol {
    private static let handledRequestKey = "UniversalDex.AppNetworkRequestLoggingURLProtocol.handled"

    private var session: URLSession?
    private var dataTask: URLSessionDataTask?
    private var startDate: Date?
    private var receivedByteCount = 0

    override class func canInit(with request: URLRequest) -> Bool {
        guard URLProtocol.property(forKey: handledRequestKey, in: request) == nil else {
            return false
        }

        guard let scheme = request.url?.scheme?.lowercased() else {
            return false
        }

        return scheme == "http" || scheme == "https"
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        startDate = Date()
        receivedByteCount = 0

        let requestDescription = Self.describe(request)
        AppDebugLog.log("Network request started: \(requestDescription)")

        let mutableRequest = (request as NSURLRequest).mutableCopy() as? NSMutableURLRequest
        guard let mutableRequest else {
            client?.urlProtocol(self, didFailWithError: URLError(.badURL))
            return
        }

        URLProtocol.setProperty(true, forKey: Self.handledRequestKey, in: mutableRequest)

        let session = URLSession(
            configuration: .default,
            delegate: self,
            delegateQueue: nil
        )
        self.session = session

        dataTask = session.dataTask(with: mutableRequest as URLRequest)
        dataTask?.resume()
    }

    override func stopLoading() {
        dataTask?.cancel()
        session?.invalidateAndCancel()
        session = nil
        dataTask = nil
    }

    private nonisolated static func describe(_ request: URLRequest) -> String {
        let method = request.httpMethod ?? "GET"
        let url = request.url.map(sanitizedURLString) ?? "<missing url>"

        return "\(method) \(url)"
    }

    private nonisolated static func sanitizedURLString(_ url: URL) -> String {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return url.absoluteString
        }

        components.queryItems = components.queryItems?.map { item in
            guard isSensitiveQueryItem(item.name) else {
                return item
            }

            return URLQueryItem(name: item.name, value: "<redacted>")
        }

        return components.string ?? url.absoluteString
    }

    private nonisolated static func isSensitiveQueryItem(_ name: String) -> Bool {
        let lowercasedName = name.lowercased()
        let sensitiveFragments = [
            "access_token",
            "apikey",
            "authorization",
            "email",
            "key",
            "password",
            "refresh_token",
            "secret",
            "token"
        ]

        return sensitiveFragments.contains { lowercasedName.contains($0) }
    }

    private func elapsedMilliseconds() -> Int {
        guard let startDate else {
            return 0
        }

        return Int(Date().timeIntervalSince(startDate) * 1_000)
    }

    private func receivedBytesText() -> String {
        ByteCountFormatter.string(fromByteCount: Int64(receivedByteCount), countStyle: .file)
    }
}

extension AppNetworkRequestLoggingURLProtocol: URLSessionDataDelegate {
    func urlSession(
        _: URLSession,
        dataTask _: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        completionHandler(.allow)
    }

    func urlSession(
        _: URLSession,
        dataTask _: URLSessionDataTask,
        didReceive data: Data
    ) {
        receivedByteCount += data.count
        client?.urlProtocol(self, didLoad: data)
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {
        defer {
            session.finishTasksAndInvalidate()
            self.session = nil
            dataTask = nil
        }

        let requestDescription = Self.describe(request)

        if let error {
            AppDebugLog.log("Network request failed: \(requestDescription) after \(elapsedMilliseconds())ms - \(error.localizedDescription)")
            client?.urlProtocol(self, didFailWithError: error)
            return
        }

        let statusCode = (task.response as? HTTPURLResponse)?.statusCode
        let statusText = statusCode.map(String.init) ?? "no status"

        AppDebugLog.log(
            "Network request finished: \(requestDescription) -> \(statusText) in \(elapsedMilliseconds())ms (\(receivedBytesText()))"
        )
        client?.urlProtocolDidFinishLoading(self)
    }
}
#endif
