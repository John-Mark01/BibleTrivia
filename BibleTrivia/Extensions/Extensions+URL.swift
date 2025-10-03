//
//  Extensions+URL.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 3.10.25.
//

import Foundation

// Helper extension for URL query parameters
extension URL {
    var queryParameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return nil
        }
        
        var params = [String: String]()
        for item in queryItems {
            params[item.name] = item.value
        }
        return params
    }
}
