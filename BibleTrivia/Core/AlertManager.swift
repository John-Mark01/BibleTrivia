//
//  AlertManager.swift
//  BibleTrivia
//

import Foundation

/// App-wide alert presenter. One instance is created at the composition root and
/// injected into stores and the environment; the overlay is rendered by
/// `applyAlertHandling()` on the root view.
@MainActor
@Observable
final class AlertManager {

    struct Alert: Identifiable {
        let id = UUID()
        let title: LocalizedStringResource
        let message: LocalizedStringResource
        let buttonTitle: LocalizedStringResource
        let action: () -> Void
    }

    private(set) var current: Alert?

    var isPresented: Bool {
        get { current != nil }
        set { if !newValue { current = nil } }
    }

    func showAlert(
        type: AlertType,
        title: LocalizedStringResource? = nil,
        message: LocalizedStringResource,
        buttonText: LocalizedStringResource = "OK",
        action: @escaping () -> Void = {}
    ) {
        current = Alert(
            title: title ?? type.title,
            message: message,
            buttonTitle: buttonText,
            action: action
        )
    }

    /// Shows an error unless it represents a cancelled task.
    func show(_ error: Error, buttonText: LocalizedStringResource = "Dismiss", action: @escaping () -> Void = {}) {
        guard !AppError.isCancellation(error) else { return }
        let message = AppError(error).errorDescription ?? "Something went wrong. Please try again."
        showAlert(type: .error, message: "\(message)", buttonText: buttonText, action: action)
    }

    func showQuizExitAlert(quizName: String, action: @escaping () -> Void) {
        showAlert(
            type: .warning,
            title: "Quit Quiz?",
            message: "Do you want to quit \(quizName)?\nYou can finish it later.",
            buttonText: "Quit Quiz",
            action: action
        )
    }

    func showFeatureComingSoonAlert(for feature: String) {
        showAlert(type: .information, message: "\(feature) is coming soon. Stay tuned!", buttonText: "Close")
    }
}

enum AlertType {
    case error, warning, success, information

    var title: LocalizedStringResource {
        switch self {
        case .error: "Error"
        case .warning: "Warning"
        case .success: "Success"
        case .information: "Information"
        }
    }
}
