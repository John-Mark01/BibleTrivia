//
//  UserManager.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 11.01.25.
//

import Foundation
import Supabase

@Observable class UserManager {
    
    var user: UserModel = UserModel(name: "", age: 0, avatarString: "", userLevel: .deacon, completedQuizzes: [], points: 0, streek: 0, userPlan: .free)
    let streakManager = StreakManager()
    let supabase = SupabaseClient(supabaseURL: Secrets.supabaseURL, supabaseKey: Secrets.supabaseAPIKey)
    
//    init(user: UserModel) {
//        self.user = user
//    }
    
 
    func setupUser() async {
        //Download initial user data
        
        
    }
    
    func downloadUserData() async {
        LoadingManager.shared.show()
        
        do {
            let user: UserModel = try await supabase
                .from("users")
                .select()
                .eq("id", value: supabase.auth.session.user.id)
                .execute()
                .value

            print("User - \(user.name)")
            LoadingManager.shared.hide()
        } catch {
            LoadingManager.shared.hide()
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
    
    func signOut() async {
        LoadingManager.shared.show()
        
        try? await supabase.auth.signOut()
        
        LoadingManager.shared.hide()
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

