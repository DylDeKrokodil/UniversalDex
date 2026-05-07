//
//  APIResponseCachePolicy.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 05/05/2026.
//

import Foundation

enum APIResponseCachePolicy {
    case returnCacheDataElseLoad
    case reloadIgnoringCache
}
