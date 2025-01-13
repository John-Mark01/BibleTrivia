//
//  UserManager.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 11.01.25.
//

import Foundation

@Observable class UserManager {
    
    let user: UserModel = UserModel()
    let streakManager = StreakManager()
    
//    init(user: UserModel) {
//        self.user = user
//    }
    
 
    func setupUser() async {
        //Download initial user data
        
        
        //Check the user in to update his streak
        do {
            let userStreak = try await streakManager.checkIn(userId: user.id!)
            user.streek = userStreak.currentStreak
        } catch {
            
        }
    }
}
