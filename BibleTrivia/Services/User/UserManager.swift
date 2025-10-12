//
//  UserManager.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 11.01.25.
//

import Foundation
import Supabase

@Observable class UserManager: RouterAccessible {
    
    let supabaseClient: SupabaseClient
    let userRepository: UserRepositoryProtocol
    let alertManager: AlertManager
    
    var user: UserModel = UserModel()
    var startedQuizzes: [StartedQuiz] = []
    var completedQuizzes: [Quiz] = [] {
        didSet {
            self.user.completedQuizzes = completedQuizzes.map(\.id)
        }
    }
    
    init(supabase: Supabase, alertManager: AlertManager = .shared) {
        self.userRepository = UserRepository(supabase: supabase)
        self.supabaseClient = supabase.supabaseClient
        self.alertManager = alertManager
    }
    
    func fetchUserAndDownloadInitialData(userID: UUID) async {
        LoadingManager.shared.show()
        defer { LoadingManager.shared.hide() }
        
        await fetchUser(userID: userID)
        await checkInUser(userID: userID)
        await getUserStartedQuizzez()
        await getUserCompletedQuizzez()
    }
    
    /// Fetches user data. This does NOT include user's quiz object. Just raw data
    /// - Parameter userID: supabase.auth.session.user.id // the logged in user in the Auth sessiion
    func fetchUser(userID: UUID) async {
        LoadingManager.shared.show()
        defer { LoadingManager.shared.hide() }
        
        do {
            let user = try await userRepository.getInitialUserData(for: userID)
            await MainActor.run {
                self.user = user
            }
            log(with: "✅ Successfully fetched user.")
            
        } catch {
            alertManager.showAlert(
                type: .error,
                message: "Coudn't fetch your data. Please try to log in again.",
                buttonText: "Go to login",
                action: { [weak self] in
                    self?.router.popToRoot()
                }
            )
            log(with: "❌ Failed to fetch user — \(error.localizedDescription)")
        }
    }
    
    /// Checks in user and backend updates his streak,
    /// calls `check_and_update_streak` in Supabase
    /// - Parameter userID: supabase.auth.session.user.id // the logged in user in the Auth sessiion
    func checkInUser(userID: UUID) async {
        do {
            try await supabaseClient
                .rpc("check_and_update_streak", params: ["user_uuid" : userID])
                .execute()
            log(with: "✅ Successfully checked in user")
            
        } catch {
            alertManager.showAlert(
                type: .error,
                message: "Something wend wrong when trying to check you in. Please try again.",
                buttonText: "Dismiss",
                action: {}
            )
            log(with: "❌ Failed to check in user - \(error.localizedDescription)")
        }
    }
    
    func getUserStartedQuizzez() async {
        do {
            self.startedQuizzes = try await userRepository.getUserStartedQuizzez()
            log(with: "✅ Recieved \(startedQuizzes.count) started quizzes for user")
            
        } catch {
            alertManager.showAlert(
                type: .error,
                message: "Something wend wrong when trying to get your started quizzes. Please try again.",
                buttonText: "Dismiss",
                action: {}
            )
            log(with: "❌ Failed to get user's started quizzez - \(error.localizedDescription)")
        }
    }
    
    func getUserCompletedQuizzez() async {
        do {
            self.completedQuizzes = try await userRepository
                .getUserCompletedQuizzez()
                .map(\.quiz)
            log(with: "✅ Recieved \(completedQuizzes.count) completed quizzes for user")
            
        } catch {
            alertManager.showAlert(
                type: .error,
                message: "Something wend wrong when trying to get your completed quizzes. Please try again.",
                buttonText: "Dismiss",
                action: {}
            )
            log(with: "❌ Failed to get user's completed quizzez - \(error.localizedDescription)")
        }
    }
    
    /// Function that adds started quizzez for user
    /// If the completed quiz already exists, then the operation is discarded.
    /// - Parameter quiz: a `StartedQuiz` quiz by the user
    func addStartedQuiz(_ quiz: StartedQuiz) {
        guard startedQuizzes.contains(where: { $0.quiz.id == quiz.quiz.id}) == false else { return }
        Task {
            await MainActor.run {
                self.startedQuizzes.append(quiz)
            }
        }
    }
    
    func convertStartedQuizToCompletedQuiz(_ quiz: Quiz) {
        Task {
            await MainActor.run {
                removeStartedQuiz(quiz)
                addCompletedQuiz(quiz)
            }
        }
    }
    
    private func removeStartedQuiz(_ quiz: Quiz) {
        guard startedQuizzes.contains(where: { $0.quiz.id == quiz.id}) else { return }
        self.startedQuizzes.removeAll { $0.quiz.id == quiz.id }
    }
    
    
    /// Function that adds completed quizzez for user
    /// If the completed quiz already exists, then the operation is discarded.
    /// - Parameter quiz: a completed quiz by the user
    private func addCompletedQuiz(_ quiz: Quiz) {
        guard completedQuizzes.contains(where: { $0.id == quiz.id}) == false else { return }
        self.completedQuizzes.append(quiz)
    }
    
    private func log(with message: String) {
        print("🟠 UserManager: \(message)\n")
    }
}

