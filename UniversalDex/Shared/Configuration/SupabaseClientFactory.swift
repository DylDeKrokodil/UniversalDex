//
//  SupabaseClientFactory.swift
//  UniversalDex
//
//  Created by Codex on 08/05/2026.
//

import Foundation

#if canImport(Supabase)
import Supabase

enum SupabaseClientFactory {
    static func makeClient(configuration: SupabaseConfiguration) -> SupabaseClient {
        SupabaseClient(
            supabaseURL: configuration.url,
            supabaseKey: configuration.anonKey,
            options: .init(
                auth: .init(
                    emitLocalSessionAsInitialSession: true
                )
            )
        )
    }
}
#endif
