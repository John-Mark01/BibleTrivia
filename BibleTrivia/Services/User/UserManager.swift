//
//  UserManager.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 11.01.25.
//

import Foundation
import Supabase

@Observable class UserManager {
    
    let userRepository: UserRepositoryProtocol
    let alertManager: AlertManager
    
    var user: UserModel = UserModel()
    let streakManager = StreakManager()
    let supabase = SupabaseClient(supabaseURL: Secrets.supabaseURL, supabaseKey: Secrets.supabaseAPIKey)
    
    init(supabase: Supabase, alertManager: AlertManager) {
        self.userRepository = UserRepository(supabase: supabase)
        self.alertManager = alertManager
    }
    
    func fetchUser(userID: UUID) async {
        LoadingManager.shared.show()
        defer { LoadingManager.shared.hide() }
        do {
            let user = try await userRepository.getInitialUserData(for: userID)
            self.user = user
        } catch let error as UserRepository.UserRepositoryError {
            await alertManager.showBTErrorAlert(error.toBTError(), buttonTitle: "Dimiss", action: {})
        } catch {
            await alertManager.showAlert(
                type: .error,
                message: "Unexpected error occurred",
                buttonText: "Dismiss",
                action: {}
            )
        }
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
            await alertManager.showAlert(type: .error, message: "Coudn't sign out", buttonText: "Dissmiss", action: {})
        }
    }
}

//MARK: Onboarding + Registration Information
extension UserManager {
}

//MARK: Streak
extension UserManager {
    
    func checkInUser() async {
        do {
            try await supabase
                .rpc("check_and_update_streak", params: ["user_uuid" : supabase.auth.session.user.id])
                .execute()
        } catch {
            print(error.localizedDescription)
        }
    }
}

