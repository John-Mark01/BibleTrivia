//
//  Router.swift
//  BibleTrivia
//

import SwiftUI

/// Navigation state for the single `NavigationStack` in `RootView`.
/// The path is a plain array, so it always matches what's on screen,
/// including swipe-back gestures.
@MainActor
@Observable
final class Router {

    enum Destination: Hashable {
        // Onboarding
        case registration
        case login
        case emailVerificationPending(email: String)
        case forgotPassword

        // Signed in
        case quiz
        case allTopics
        case topicQuizzes
        case account
        case myProgress
    }

    var path: [Destination] = []

    func navigate(to destination: Destination) {
        path.append(destination)
    }

    func pop() {
        _ = path.popLast()
    }

    func popToRoot() {
        path.removeAll()
    }

    /// Replaces the whole stack, e.g. "Back to login" from deep in onboarding.
    func reset(to destination: Destination) {
        path = [destination]
    }
}

extension Router.Destination {
    @ViewBuilder
    var view: some View {
        switch self {
        case .registration: RegistrationView()
        case .login: LoginView()
        case .emailVerificationPending(let email): EmailVerificationPendingView(email: email)
        case .forgotPassword: ForgotPasswordView()
        case .quiz: QuizView()
        case .allTopics: AllTopicsView()
        case .topicQuizzes: TopicQuizzesView()
        case .account: AccountView()
        case .myProgress: MyProgressView()
        }
    }
}
