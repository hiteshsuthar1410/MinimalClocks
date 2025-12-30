//
//  NetworkService.swift
//  MinimalClocks
//
//  Created by Hitesh Suthar on 18/01/25.
//

import Foundation
protocol NetworkService {
    func fetch<T: Codable>(_ type: T.Type, from collection: String, whereField: String?, isEqualTo: Any?) async throws -> [T]
}
