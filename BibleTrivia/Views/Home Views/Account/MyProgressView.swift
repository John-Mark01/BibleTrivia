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
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                    
                    BTContentBox {
                        VStack(alignment: .center, spacing: Constants.vStackSpacing) {
                            Image("quiz_score")
                            
                            Text("Total Points")
                                .applyFont(.medium, size: 14, textColor: .BTBlack)
                            
                            Text("\(userStore.user.totalPoints)")
                                .applyFont(.semiBold, size: 20, textColor: .BTPrimary)
                                .padding(.top, -8)
                        }
                        .padding(.horizontal, 20)
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

struct BTContentBox<Content: View>: View {
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        content()
            .padding(Constants.horizontalPadding)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.boxStroke, lineWidth: 1)
                    .foregroundStyle(.white)
            )
    }
}

#Preview("SurfaceStack") {
    
    VStack {
        BTContentBox {
            HStack {
                Text("Hello")
                Image(systemName: "house")
                    .font(.largeTitle)
            }
        }
        
        Spacer()
    }
    .applyViewPaddings()
    .applyBackground()
}
