//
//  UserManager.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 11.01.25.
//

import Foundation
import Supabase

@Observable class UserManager {
    
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
            self.user = user
        } catch let error as UserRepository.UserRepositoryError {
            alertManager.showBTErrorAlert(error.toBTError(), buttonTitle: "Dimiss", action: {})
        } catch {
            alertManager.showAlert(
                type: .error,
                message: "Unexpected error occurred",
                buttonText: "Dismiss",
                action: {}
            )
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
        } catch {
            print(error.localizedDescription) //TODO: Add alerts for all those erros caught
        }
    }
    
    func getUserStartedQuizzez() async {
        do {
            self.startedQuizzes = try await userRepository.getUserStartedQuizzez()
        } catch {
            print(error.localizedDescription) //TODO: Add alerts for all those erros caught
        }
    }
    
    func getUserCompletedQuizzez() async {
        do {
            self.completedQuizzes = try await userRepository
                .getUserCompletedQuizzez()
                .map(\.quiz)
            print("✅ Recieved \(completedQuizzes.count) completed quizzes for user\n")
        } catch {
            print(error.localizedDescription) //TODO: Add alerts for all those erros caught
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
}

