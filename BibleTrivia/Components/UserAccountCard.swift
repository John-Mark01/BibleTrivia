//
//  UserAccountCard.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 2.12.24.
//

import SwiftUI

struct UserAccountCard: View {
    var user: UserModel
    var viewUse: UseCase = .account
    var body: some View {
        
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(Color.BTPrimary)
                .frame(maxWidth: .infinity)

            
            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .top, spacing: 10) {
                    
                    Image("Avatars/jacob") //TODO: Get custom user image or avatar
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: 60, height: 60)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(user.name)
                            .applyFont(.semiBold, size: 20, textColor: .white)
                        
                        Text("\(user.totalPoints)pts | \(user.userLevel.stringValue)")
                            .applyFont(.medium, size: 14, textColor: .white)
                        
                        if viewUse == .myProgress {
                            HStack(alignment: .top, spacing: 10) {
                                LinearProgressView(progress: user.totalPoints, goal: user.nextLevel.rawValue, showPercentage: false, fillColor: .white, backgroundOpacity: 0.4)
                                
                                Text((UserLevel(rawValue: user.userLevel.rawValue + 1)?.stringValue ?? ""))
                                    .applyFont(.semiBold, size: 13, textColor: .white)
                                    .offset(y: -1)
                            }
                        }
                        
                    }
                    Spacer()
                }
                
                if viewUse == .account {
                    UserScoreCard(user: user)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
    
        }
    }
    
    enum UseCase {
        case account
        case myProgress
    }
}

struct UserScoreCard: View {
    var user: UserModel
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .frame(maxWidth: .infinity, maxHeight: 70)
                .foregroundStyle(Color.white.opacity(0.4))
            
            HStack(alignment: .center) {
                // Points
                VStack(alignment: .center, spacing: 4) {
                    Text("\(user.totalPoints)")
                        .applyFont(.medium, size: 18, textColor: .white)
                    
                    Text("Points")
                        .applyFont(.medium, size: 14, textColor: .white.opacity(0.7))
                }
                Spacer()
                
                Text("|")
                    .foregroundStyle(Color.white.opacity(0.7))
                
                Spacer()
                
                // Streak
                VStack(alignment: .center, spacing: 4) {
                    Text("\(user.streak)")
                        .applyFont(.medium, size: 18, textColor: .white)
                    
                    Text("Days Steek")
                        .applyFont(.medium, size: 14, textColor: .white.opacity(0.7))
                }
                
                Spacer()
                Text("|")
                    .foregroundStyle(Color.white.opacity(0.7))
                Spacer()
                
                // Streak
                VStack(alignment: .center, spacing: 4) {
                    Text("\(user.completedQuizzes ?? 0)")
                        .applyFont(.medium, size: 18, textColor: .white)
                    
                    Text("Quizzez")
                        .applyFont(.medium, size: 14, textColor: .white.opacity(0.7))
                }
                
            }
            .padding()
            
        }
        .background(Color.BTPrimary)
        
    }
}
//#Preview("Score Card") {
//    let userStreak = UserStreak()
//    let user = UserModel(name: "John-Mark Iliev", age: 23, avatarString: "Avatars/jacob", userLevel: .youthPastor, completedQuizzes: [], points: 328, streek: UserStreak().currentStreak, userPlan: .free)
//    UserScoreCard(user: user)
//        .padding(30)
//}
//#Preview {
//    let user = UserModel(name: "John-Mark Iliev", age: 23, avatarString: "Avatars/jacob", userLevel: .youthPastor, completedQuizzes: [], points: 328, streek: 34, userPlan: .free)
//    UserAccountCard(user: user, viewUse: .myProgress)
//        .frame(height: 50)
//}
