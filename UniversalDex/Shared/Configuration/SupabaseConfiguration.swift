//
//  SupabaseConfiguration.swift
//  UniversalDex
//
//  Created by Codex on 08/05/2026.
//

import Foundation

struct SupabaseConfiguration {
    let url: URL
    let anonKey: String

    private static let fileName = "Supabase"
    private static let urlKey = "SUPABASE_URL"
    private static let anonKeyKey = "SUPABASE_ANON_KEY"
    private static let placeholderValues: Set<String> = [
        "YOUR_SUPABASE_PROJECT_URL",
        "YOUR_SUPABASE_ANON_KEY",
        "SUPABASE_URL",
        "SUPABASE_ANON_KEY"
    ]

    static func load(from bundle: Bundle = .main) -> SupabaseConfiguration? {
        guard let resourceURL = bundle.url(forResource: fileName, withExtension: "plist"),
              let data = try? Data(contentsOf: resourceURL),
              let plist = try? PropertyListSerialization.propertyList(
                from: data,
                format: nil
              ) as? [String: String],
              let urlString = plist[urlKey]?.trimmingCharacters(in: .whitespacesAndNewlines),
              let anonKey = plist[anonKeyKey]?.trimmingCharacters(in: .whitespacesAndNewlines),
              !urlString.isEmpty,
              !anonKey.isEmpty,
              !placeholderValues.contains(urlString),
              !placeholderValues.contains(anonKey),
              let url = URL(string: urlString) else {
            return nil
        }

        return SupabaseConfiguration(url: url, anonKey: anonKey)
    }
}
