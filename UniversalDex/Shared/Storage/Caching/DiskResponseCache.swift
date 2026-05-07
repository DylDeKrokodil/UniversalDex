//
//  DiskResponseCache.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 05/05/2026.
//

import CryptoKit
import Foundation

actor DiskResponseCache {
    static let shared = DiskResponseCache(namespace: "api-responses")

    private let directoryURL: URL
    private let fileManager: FileManager
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(namespace: String, fileManager: FileManager = .default) {
        self.fileManager = fileManager

        let baseDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]

        directoryURL = baseDirectory
            .appending(path: "UniversalDex", directoryHint: .isDirectory)
            .appending(path: "Cache", directoryHint: .isDirectory)
            .appending(path: namespace, directoryHint: .isDirectory)

        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        try? fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
    }

    func value<Value: Codable>(
        forKey key: String,
        maxAge: TimeInterval
    ) -> Value? {
        let url = fileURL(forKey: key)

        guard let data = try? Data(contentsOf: url),
              let envelope = try? decoder.decode(CachedEnvelope<Value>.self, from: data),
              Date().timeIntervalSince(envelope.cachedAt) <= maxAge else {
            return nil
        }

        return envelope.value
    }

    func save<Value: Codable>(_ value: Value, forKey key: String) {
        let envelope = CachedEnvelope(cachedAt: Date(), value: value)

        guard let data = try? encoder.encode(envelope) else {
            return
        }

        try? fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        try? data.write(to: fileURL(forKey: key), options: [.atomic])
    }

    func removeValue(forKey key: String) {
        try? fileManager.removeItem(at: fileURL(forKey: key))
    }

    private func fileURL(forKey key: String) -> URL {
        let digest = SHA256.hash(data: Data(key.utf8))
        let fileName = digest.map { String(format: "%02x", $0) }.joined()

        return directoryURL.appending(path: "\(fileName).json")
    }
}

nonisolated private struct CachedEnvelope<Value: Codable>: Codable {
    let cachedAt: Date
    let value: Value
}
