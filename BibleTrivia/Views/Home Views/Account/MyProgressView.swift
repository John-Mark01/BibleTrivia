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
                            .applyFont(.medium, size: 12, textColor: .BTPrimary)
                        
                        Spacer()
                    }
                }
                
                //Score Boards
                HStack {
                    BTContentBox {
                        VStack(alignment: .center, spacing: Constants.vStackSpacing) {
                            Image("quiz_roulette")
                            
                            Text("Total Quizzes")
                                .applyFont(.medium, size: 14, textColor: .BTBlack)
                            
                            Text("\(userStore.user.completedQuizzes?.count ?? 0)")
                                .applyFont(.semiBold, size: 20, textColor: .BTPrimary)
                                .padding(.top, -8)
                        }
                    }
                    
                    Spacer(minLength: 25)
                    
                    BTContentBox {
                        VStack(alignment: .center, spacing: Constants.vStackSpacing) {
                            Image("quiz_score")
                            
                            Text("Total Points")
                                .applyFont(.medium, size: 14, textColor: .BTBlack)
                            
                            Text("\(userStore.user.totalPoints)")
                                .applyFont(.semiBold, size: 20, textColor: .BTPrimary)
                                .padding(.top, -8)
                        }
                    }
                }
                
                //Quizzes History
                LazyVStack(alignment: .leading, spacing: Constants.vStackSpacing) {
                    //Title
                    HStack {
                        Text("Quizzes History")
                            .applyFont(.medium, size: 16, textColor: .BTBlack)
                        
                        Spacer()
                        
                        Text("See all")
                            .applyFont(.medium, size: 14, textColor: .BTPrimary)
                    }
                    
                    //Quizzes
                    ForEach(userStore.completedQuizzes, id: \.id) { quiz in
                        CompletedQuizzezViewRow(completedQuiz: quiz)
                    }
                }
            }
        }
        .navigationTitle("My Progress")
        .applyViewPaddings()
        .applyBackground()
    }
}

#Preview {
    PreviewEnvironmentView {
        MyProgressView()
    }
}

struct CompletedQuizzezViewRow: View {
    var completedQuiz: CompletedQuiz
    
    var body: some View {
        BTContentBox {
            HStack(alignment: .center, spacing: 12) {
                
                //TODO: Here should be the quiz photo
                RoundedRectangle(cornerRadius: 16)
                    .frame(width: 70, height: 72)
                    .foregroundStyle(.lightGray)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(completedQuiz.quiz.name)
                        .applyFont(.medium, size: 14, textColor: .BTBlack)
                    
                    Text(completedQuiz.session.completedAt)
                        .applyFont(.regular, size: 10, textColor: .lightGray)
                    
                    Text("\(10) Points") //TODO: Need to update user_sessions to include received points
                        .applyFont(.semiBold, size: 16, textColor: Color.init(hex: "6A5ADF"))
                        .padding(.top, 8)
                    
                    Spacer()
                }
                
                Spacer()
                
                Text(completedQuiz.session.passed ? "Passed" : "Failed")
                    .applyFont(.regular, size: 14, textColor: .white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 3)
                    .background(completedQuiz.session.passed ? Color.greenGradient : Color.redGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                    .frame(maxHeight: .infinity, alignment: .top)
            }
        }
    }
}
