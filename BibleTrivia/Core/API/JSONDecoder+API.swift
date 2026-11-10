//
//  JSONDecoder+API.swift
//  BibleTrivia
//

import Foundation

extension JSONDecoder {
    /// Decoder for backend JSON: snake_case keys and Postgres timestamps.
    static let api: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            guard let date = PostgresDate.parse(string) else {
                throw DecodingError.dataCorruptedError(
                    in: container, debugDescription: "Unrecognised date: \(string)")
            }
            return date
        }
        return decoder
    }()
}

/// Parses timestamps as Postgres emits them in JSON, e.g.
/// `2026-11-10T15:35:13.179548+00:00`, `2026-11-10T15:35:13+00:00`, `2026-11-10T15:35:13Z`.
enum PostgresDate {
    static func parse(_ string: String) -> Date? {
        // ISO8601DateFormatter handles at most millisecond precision, so trim
        // any extra fractional digits (Postgres uses microseconds).
        var normalized = string
        if let dot = string.firstIndex(of: ".") {
            let fractionStart = string.index(after: dot)
            let fractionEnd = string[fractionStart...].firstIndex { !$0.isNumber } ?? string.endIndex
            let digits = string[fractionStart..<fractionEnd]
            if digits.count > 3 {
                normalized = String(string[..<fractionStart]) + digits.prefix(3) + string[fractionEnd...]
            }
        }
        return withFraction.date(from: normalized) ?? withoutFraction.date(from: normalized)
    }

    nonisolated(unsafe) private static let withFraction: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    nonisolated(unsafe) private static let withoutFraction: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
}
