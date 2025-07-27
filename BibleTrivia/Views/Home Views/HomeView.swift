//
//  HomeView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 8.10.24.
//

import SwiftUI

struct HomeView: View {
    @Environment(QuizStore.self) var quizStore
    @Environment(\.userName) private var userName
    @Environment(Router.self) private var router
    
    @State private var openModal: Bool = false
    @State private var alertDialog: Bool = false
    
    @State private var tempQuiz: [Quiz] = [/*DummySVM.shared.tempQuiz*/]
//    @State private var dummyQuizzez = DummySVM.shared.quizes
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    //Top Buttons
                    HStack {
                        
                        Button("") {
                            
                        }
                        .buttonStyle(.score(score: "328"))
                        
                        Button("") {
                            
                        }
                        .buttonStyle(.streak(width: 123, streak: "500"))
                    }
                    
                    Spacer()
                    
                    //Unfinished Quizes
                    VStack(alignment: .leading) {
                        Text("Unfinished Quizzes")
                            .applyFont(.medium, size: 20)
                        
                        UnfinishedQuizesViewRow(quizes: $tempQuiz, isPresented: $openModal)
                    }
                    
                    //Find New Quizzes
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Find New Quizzes")
                            .applyFont(.medium, size: 20)
                        
                        FindQuizViewRow(quizes: quizStore.allQuizez, isPresented: $openModal)
                        
                    }
                    .padding(.top, 10)
                }
                .navigationTitle("Welcome, \(userName)!")
                .navigationBarBackButtonHidden()
                .navigationBarTitleDisplayMode(.large)
                .blur(radius: openModal ? 3 : 0)
                .disabled(openModal)
                .applyViewPaddings()
                .applyBackground()
                .applyAccountButton(avatar: Image("Avatars/jacob"), onTap: {
                    router.navigateTo(.account)
                })
            }
            .background(Color.BTBackground)
            
            if openModal {
                if let quiz = quizStore.chosenQuiz {
                    ChooseQuizModal(isPresented: $openModal, quiz: quiz, startQuiz: {
                        router.navigateTo(.quizView)
                        openModal = false
                    }, cancel: {
                        openModal = false
                    })
                    
                } else {
//                    AlertDialog(isPresented: .constant(true), title: "Error", message: "We coudn't load this quiz. Please try again later.", buttonTitle: "Close", primaryAction: {print("Error in getting quiz.")}, isAnotherAction: true)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
    .environment(QuizStore(supabase: Supabase()))
    .environment(Router.shared)
}


import SwiftUI


struct EmptyQuizView: View {
    var body: some View {
        
        VStack(alignment: .center, spacing: 5) {
            Image(systemName: "clock")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundStyle(Color.white)
                .symbolEffect(.rotate)
                .padding(.bottom, 8)
            Text("No Started Quizzes Yet")
                .font(.headline)
                .foregroundColor(.white)
            Text("Choose one from down below.")
                .font(.subheadline)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .padding()
        .background(Color.BTDarkGray)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

#Preview("EmptyQuizView") {
    EmptyQuizView()
}
