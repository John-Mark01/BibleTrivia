//
//  MyProgressView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 16.12.24.
//

import SwiftUI

struct MyProgressView: View {
    @Environment(Router.self) private var router
    @Environment(UserStore.self) private var userStore
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: Constants.vStackSpacing + 8) {
                
                //User Info Card
                UserAccountCard(user: userStore.user, viewUse: .myProgress)
                
                //Motivation text
                BTContentBox {
                    HStack(spacing: Constants.vStackSpacing) {
                        Image("bulzai")
                        
                        Text("Keep up the good work, wou are ahead of others :)")
                            .applyFont(.medium, size: 12, textColor: .btPrimary)
                        
                        Spacer()
                    }
                }
                
                //Score Boards
                HStack {
                    BTContentBox {
                        VStack(alignment: .center, spacing: Constants.vStackSpacing) {
                            Image("quiz_roulette")
                            
                            Text("Total Quizzes")
                                .applyFont(.medium, size: 14, textColor: .btBlack)
                            
                            Text("\(userStore.user.completedQuizzes ?? 0)")
                                .applyFont(.semiBold, size: 20, textColor: .btPrimary)
                                .padding(.top, -8)
                        }
                    }
                    
                    Spacer(minLength: 25)
                    
                    BTContentBox {
                        VStack(alignment: .center, spacing: Constants.vStackSpacing) {
                            Image("quiz_score")
                            
                            Text("Total Points")
                                .applyFont(.medium, size: 14, textColor: .btBlack)
                            
                            Text("\(userStore.user.totalPoints)")
                                .applyFont(.semiBold, size: 20, textColor: .btPrimary)
                                .padding(.top, -8)
                        }
                    }
                }
                
                //Quizzes History
                LazyVStack(alignment: .leading, spacing: Constants.vStackSpacing) {
                    
                    //Title
                    HStack {
                        Text("Quizzes History")
                            .applyFont(.medium, size: 16, textColor: .btBlack)
                        
                        Spacer()
                        
                        Text("See all")
                            .applyFont(.medium, size: 14, textColor: .btPrimary)
                            .makeButton(
                                action: {}, //TODO: Add a full list of quizzez history. Reuse the `AllQuizzezScreen`
                                addHapticFeedback: true,
                                feedbackStyle: .selection
                            )
                    }
                    
                    //Quizzes
                    ForEach(userStore.completedQuizzes.indices, id: \.self) { index in
                        // allow only the first 10 quizzez to be rendered on screen
                        if index <= 10 {
                            CompletedQuizzezViewRow(completedQuiz: userStore.completedQuizzes[index])
                        }
                    }
                }
            }
            .applyViewPaddings(.vertical)
        }
        .navigationTitle("My Progress")
        .navigationBarTitleDisplayMode(.large)
        .applyViewPaddings(.horizontal)
        .applyBackground()
    }
}

#Preview {
    PreviewEnvironmentView {
        MyProgressView()
    }
}
