//
//  UserManager.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 11.01.25.
//

import Foundation
import Supabase

@Observable class UserManager {
    
    let supabase = SupabaseClient(supabaseURL: Secrets.supabaseURL, supabaseKey: Secrets.supabaseAPIKey)
    
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
        self.alertManager = alertManager
    }
    
    func fetchUserAndDownloadInitialData(userID: UUID) async {
        Task {
            await fetchUser(userID: userID)
            await checkInUser(userID: userID)
            await getUserStartedQuizzez()
            await getUserCompletedQuizzez()
        }
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
            try await supabase
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
    
    func addStartedQuiz(_ quiz: StartedQuiz) {
        guard startedQuizzes.contains(where: { $0.quiz.id == quiz.quiz.id}) == false else { return }
        self.startedQuizzes.append(quiz)
    }
    
    func convertStartedQuizToCompletedQuiz(_ quiz: Quiz) {
        removeStartedQuiz(quiz)
        addCompletedQuiz(quiz)
    }
    
    private func removeStartedQuiz(_ quiz: Quiz) {
        guard startedQuizzes.contains(where: { $0.quiz.id == quiz.id}) else { return }
        self.startedQuizzes.removeAll { $0.quiz.id == quiz.id }
    }
    
    
    private func addCompletedQuiz(_ quiz: Quiz) {
        guard completedQuizzes.contains(where: { $0.id == quiz.id}) else { return }
        self.completedQuizzes.append(quiz)
    }
}


//MARK: Authentication
extension UserManager {
    
    // EMAIL && Password
    func signUp(email: String, password: String, firstName: String = "", lastName: String = "", age: String) async throws {
        
        let userName = "\(firstName) \(lastName)".capitalized
        let userAge = Int(age) ?? 0
        
        try await supabase.auth.signUp(
            email: email,
            password: password,
            data: [
                "first_name": .string(firstName),
                "last_name": .string(lastName),
                "user_name": .string(userName),
                "age": .integer(userAge)
            ]
        )
    }
    
    func signIn(email: String, password: String, callBack: @escaping (Bool) -> Void) async throws {
        LoadingManager.shared.show()
        
        do {
            try await supabase.auth.signIn(email: email, password: password)
            callBack(true)
            LoadingManager.shared.hide()
        }
        catch {
            LoadingManager.shared.hide()
            print("Coudnt sign in")
        }
    }
    
    func signOut(completion: @escaping () -> Void) async {
        LoadingManager.shared.show()
        defer { LoadingManager.shared.hide() }
        
        do {
            try await supabase.auth.signOut()
            completion()
        } catch {
            alertManager.showAlert(type: .error, message: "Coudn't sign out", buttonText: "Dissmiss", action: {})
        }
    }
}

