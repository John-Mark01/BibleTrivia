//
//  AppError.swift
//  BibleTrivia
//

import Foundation
import Supabase

/// The single error type surfaced to the UI. Everything thrown by the API layer
/// is mapped into one of these cases so views can show a meaningful message.
enum AppError: LocalizedError, Equatable {
    case network
    case notAuthenticated
    case notFound(String)
    case server(String)
    case decoding
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .network:
            "You appear to be offline. Check your connection and try again."
        case .notAuthenticated:
            "Your session expired. Please sign in again."
        case .notFound(let message), .server(let message), .unknown(let message):
            message
        case .decoding:
            "We received data we couldn't read. Please update the app or try again later."
        }
    }

    init(_ error: Error) {
        switch error {
        case let error as AppError:
            self = error
        case let error as URLError where error.code != .cancelled:
            self = .network
        case let error as PostgrestError:
            switch error.code {
            case "42501", "PGRST301", "PGRST302": self = .notAuthenticated
            case "P0002": self = .notFound(error.message)
            default: self = .server(error.message)
            }
        case let error as AuthError:
            self = .server(error.message)
        case is DecodingError:
            self = .decoding
        default:
            self = .unknown(error.localizedDescription)
        }
    }

    /// True when the error came from a cancelled task and should be ignored.
    static func isCancellation(_ error: Error) -> Bool {
        if error is CancellationError { return true }
        if let error = error as? URLError, error.code == .cancelled { return true }
        return false
    }
}
