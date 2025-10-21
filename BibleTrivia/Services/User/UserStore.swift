//
//  UserStore.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 11.01.25.
//

import Foundation
import Supabase

@Observable class UserStore: RouterAccessible, AuthenticatedStore {
    
    let supabaseClient: SupabaseClient
    let alertManager: AlertManager
    let supabase: Supabase
    
    var userId: UUID?
    private var userRepository: UserRepositoryProtocol?
    
    init(supabase: Supabase, alertManager: AlertManager = .shared) {
        self.supabase = supabase
        self.supabaseClient = supabase.supabaseClient
        self.alertManager = alertManager
        self.userRepository = UserRepository(supabase: supabase)
    }
    
    
    var user: UserModel = UserModel()
    var startedQuizzes: [StartedQuiz] = [] {
        didSet {
            self.user.startedQuizzes = startedQuizzes.map(\.id).count
        }
    }
    var completedQuizzes: [CompletedQuiz] = [] {
        didSet {
            self.user.completedQuizzes = completedQuizzes.map(\.id).count
        }
    }
    
    
    // MARK: - Authentication
    
    /// Call this after user authenticates to set up the store
    func setUserId(_ id: UUID) {
        self.userId = id
    }
    
    // MARK: - User Data Methods
    
    func fetchUserAndDownloadInitialData() async {
        LoadingManager.shared.show()
        defer { LoadingManager.shared.hide() }
        
        await fetchUser()
        await checkInUser()
        await getUserStartedQuizzez()
        await getUserCompletedQuizzezCount()
    }
    
    /// Fetches user data. This does NOT include user's quiz object. Just raw data
    func fetchUser() async {
        guard let userId = requireAuthentication() else { return }
        guard let userRepository = userRepository else {
            log(with: "❌ Cannot fetch user - repository not initialized")
            return
        }
        
        do {
            let user = try await userRepository.getInitialUserData(for: userId)
            await MainActor.run {
                self.user = user
            }
            log(with: "✅ Successfully fetched user.")
            
        } catch {
            alertManager.showAlert(
                type: .error,
                message: "Couldn't fetch your data. Please try to log in again.",
                buttonText: "Go to login",
                action: { [weak self] in
                    self?.router.popToRoot()
                }
            )
            log(with: "❌ Failed to fetch user — \(error.localizedDescription)")
        }
    }
    
    /// Checks in user and backend updates their streak
    func checkInUser() async {
        guard let userId = requireAuthentication() else { return }
        
        do {
            try await supabaseClient
                .rpc("check_and_update_streak", params: ["user_uuid": userId])
                .execute()
            log(with: "✅ Successfully checked in user")
            
        } catch {
            alertManager.showAlert(
                type: .error,
                message: "Something went wrong when trying to check you in. Please try again.",
                buttonText: "Dismiss",
                action: {}
            )
            log(with: "❌ Failed to check in user - \(error.localizedDescription)")
        }
    }
    
    func getUserStartedQuizzez() async {
        guard let userId = requireAuthentication() else { return }
        guard let userRepository = userRepository else {
            log(with: "❌ Cannot get started quizzes - repository not initialized")
            return
        }
        
        do {
            self.startedQuizzes = try await userRepository.getUserStartedQuizzez(for: userId)
            log(with: "✅ Received \(startedQuizzes.count) started quizzes for user")
            
        } catch {
            alertManager.showAlert(
                type: .error,
                message: "Something went wrong when trying to get your started quizzes. Please try again.",
                buttonText: "Dismiss",
                action: {}
            )
            log(with: "❌ Failed to get user's started quizzes - \(error.localizedDescription)")
        }
    }
    
    func getUserCompletedQuizzez() async {
        guard let userId = requireAuthentication() else { return }
        guard let userRepository = userRepository else {
            log(with: "❌ Cannot get completed quizzes - repository not initialized")
            return
        }
        
        do {
            self.completedQuizzes = try await userRepository.getUserCompletedQuizzez(for: userId)
            log(with: "✅ Received \(completedQuizzes.count) completed quizzes for user")
            
        } catch {
            alertManager.showAlert(
                type: .error,
                message: "Something went wrong when trying to get your completed quizzes. Please try again.",
                buttonText: "Dismiss",
                action: {}
            )
            log(with: "❌ Failed to get user's completed quizzes - \(error.localizedDescription)")
        }
    }
    
    func getUserCompletedQuizzezCount() async {
        guard let userId = requireAuthentication() else { return }
        guard let userRepository = userRepository else {
            log(with: "❌ Cannot get completed quizzes count - repository not initialized")
            return
        }
        
        do {
            self.user.completedQuizzes = try await userRepository.getUserCompletedQuizzezCount(for: userId)
            log(with: "✅ Received \(user.completedQuizzes, default: "0") count for user's completed quizzes")
            
        } catch {
            alertManager.showAlert(
                type: .error,
                message: "Something went wrong when trying to get your completed quizzes count. Please try again.",
                buttonText: "Dismiss",
                action: {}
            )
            log(with: "❌ Failed to get user's completed quizzes count - \(error.localizedDescription)")
        }
    }
    
    /// Function that adds started quizzes for user
    func addStartedQuiz(_ quiz: StartedQuiz) {
        guard startedQuizzes.contains(where: { $0.quiz.id == quiz.quiz.id}) == false else { return }
        Task {
            await MainActor.run {
                self.startedQuizzes.append(quiz)
            }
        }
    }
    
    func convertStartedQuizToCompletedQuiz(_ completedQuiz: CompletedQuiz) {
        Task {
            await MainActor.run {
                removeStartedQuiz(completedQuiz.quiz)
                addCompletedQuiz(completedQuiz)
            }
        }
    }
    
    private func removeStartedQuiz(_ quiz: Quiz) {
        guard startedQuizzes.contains(where: { $0.quiz.id == quiz.id}) else { return }
        self.startedQuizzes.removeAll { $0.quiz.id == quiz.id }
    }
    
    private func addCompletedQuiz(_ completedQuiz: CompletedQuiz) {
        guard completedQuizzes.contains(where: { $0.id == completedQuiz.id}) == false else { return }
        self.completedQuizzes.append(completedQuiz)
    }
    
    private func log(with message: String) {
        print("🔵 UserStore: \(message)\n")
    }
}

