//
//  AppDebugLog.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 05/05/2026.
//

import Foundation

enum AppDebugLog {
    static func log(_ message: String) {
        #if DEBUG
        print("UniversalDex DEBUG | \(message)")
        #endif
    }
}
