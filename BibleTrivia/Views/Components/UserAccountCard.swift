//
//  UserAccountCard.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 2.12.24.
//

import SwiftUI

struct UserAccountCard: View {
    var user: UserModel
    
    var body: some View {
        
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(Color.BTPrimary)
                .frame(maxWidth: .infinity)

            
            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .top, spacing: 10) {
                    
                    Image(user.avatarString)
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: 60, height: 60)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(user.name)
                            .modifier(CustomText(size: 20, font: .semiBold))
                            .foregroundStyle(Color.white)
                        
                        Text("\(user.totalPoints)pts | \(user.userLevel.stringValue)")
                            .modifier(CustomText(size: 14, font: .medium))
                            .foregroundStyle(Color.white)
                        
                    }
                    
                    Spacer()
                }
                
                UserScoreCard(user: user)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
    
        }
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
                        .modifier(CustomText(size: 18, font: .medium))
                        .foregroundStyle(Color.white)
                    
                    Text("Points")
                        .modifier(CustomText(size: 14, font: .medium))
                        .foregroundStyle(Color.white.opacity(0.7))
                }
                Spacer()
                
                Text("|")
                    .foregroundStyle(Color.white.opacity(0.7))
                
                Spacer()
                
                // Streak
                VStack(alignment: .center, spacing: 4) {
                    Text("\(user.streek)")
                        .modifier(CustomText(size: 18, font: .medium))
                        .foregroundStyle(Color.white)
                    
                    Text("Days Steek")
                        .modifier(CustomText(size: 14, font: .medium))
                        .foregroundStyle(Color.white.opacity(0.7))
                }
                
                Spacer()
                Text("|")
                    .foregroundStyle(Color.white.opacity(0.7))
                Spacer()
                
                // Streak
                VStack(alignment: .center, spacing: 4) {
                    Text("\(user.completedQuizzes.count)")
                        .modifier(CustomText(size: 18, font: .medium))
                        .foregroundStyle(Color.white)
                    
                    Text("Quizzez")
                        .modifier(CustomText(size: 14, font: .medium))
                        .foregroundStyle(Color.white.opacity(0.7))
                }
                
            }
            .padding()
            
        }
        .background(Color.BTPrimary)
        
    }
}
#Preview("Score Card") {
    let user = UserModel(name: "John-Mark Iliev", age: 23, avatarString: "Avatars/jacob", userLevel: .youthPastor, completedQuizzes: [], points: 328, streek: 34, userPlan: .free)
    UserScoreCard(user: user)
        .padding(30)
}
#Preview {
    let user = UserModel(name: "John-Mark Iliev", age: 23, avatarString: "Avatars/jacob", userLevel: .youthPastor, completedQuizzes: [], points: 328, streek: 34, userPlan: .free)
    UserAccountCard(user: user)
}
