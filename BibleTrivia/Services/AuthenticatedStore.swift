//
//  AuthenticatedStore.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 21.10.25.
//

import Foundation

@MainActor protocol AuthenticatedStore: AnyObject {
    var router: Router { get }
    var alertManager: AlertManager { get }
    var userId: UUID? { get }
}

extension AuthenticatedStore {
    /// Centralized auth check function for user.
    /// Example: user was logged in but then his session is terminated, while the app was open
    /// Returns unwrapped userId or shows error and navigates to root
    func requireAuthentication() -> UUID? {
        guard let userId = userId else {
            alertManager.showAlert(
                type: .error,
                message: "Your session expired. Please sign in again.",
                buttonText: "Go to Login",
                action: { [weak self] in
                    self?.router.popToRoot()
                }
            )
            return nil
        }
        return userId
    }
}
