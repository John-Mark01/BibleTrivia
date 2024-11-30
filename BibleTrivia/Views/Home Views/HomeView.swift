//
//  HomeView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 8.10.24.
//

import SwiftUI

struct HomeView: View {
    @Environment(QuizStore.self) var quizStore
    @EnvironmentObject var router: Router
    @State private var viewModel = HomeViewViewModel()
    @State private var openModal: Bool = false
    @State private var alertDialog: Bool = false
    
    @State private var tempQuiz = [DummySVM.shared.tempQuiz]
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Welcome, Chris!")
                            .modifier(CustomText(size: 24, font: .semiBold))
                        Spacer()
                    }
                    //MARK: Top Buttons
                    HStack {
                        
                        Button(action: {
                            //TODO: Modal showing the scorring
                        }) {
                            HStack {
                                Image("star")
                                    .resizable()
                                    .frame(width: 34, height: 34)
                                    .foregroundStyle(Color.yellow)
                                    .padding(.trailing, 4)
                                Text("Score:")
                                    .modifier(CustomText(size: 24, font: .semiBold))
                                    .foregroundStyle(Color.white)
                                Text("328")
                                    .modifier(CustomText(size: 24, font: .regular))
                                    .foregroundStyle(Color.white)
                            }
                            
                        }
                        .frame(width: 212, height: 70)
                        .buttonStyle(ScoreButton())
                        
                        Spacer()
                        Button(action: {
                            //TODO: Modal showing the streak
                            print("Streak pressed")
                        }) {
                            HStack {
                                Image(systemName: "bolt.fill")
                                    .resizable()
                                    .frame(width: 24, height: 34)
                                    .foregroundStyle(Color.BTDarkGray)
                                
                                Text("3")
                                    .modifier(CustomText(size: 34, font: .semiBold))
                                    .foregroundStyle(Color.white)
                                    .bold()
                            }
                        }
                        
                        .buttonStyle(StreakButton())
                    }
                    
                    Spacer()
                    
                    //MARK: Unfinished Quizes
                    VStack(alignment: .leading) {
                        Text("Unfinished Quizzes")
                            .modifier(CustomText(size: 20, font: .medium))
                        
                        UnfinishedQuizesViewRow(quizes: $tempQuiz, isPresented: $openModal)
                    }
                    
                    //MARK: Find New Quizzes
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Find New Quizzes")
                            .modifier(CustomText(size: 20, font: .medium))
                        
                        FindQuizViewRow(quizes: DummySVM.shared.quizes, isPresented: $openModal)
                        
                    }
                    .padding(.top, 10)
                }
                .padding(.horizontal, Constants.hPadding)
                .padding(.vertical, Constants.vPadding)
                .navigationTitle("Home")
                .navigationBarTitleDisplayMode(.inline)
                .background(Color.BTBackground)
                .blur(radius: openModal ? 3 : 0)
                .disabled(openModal)
                
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            
                        }) {
                            Image(systemName: "line.3.horizontal")
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            router.navigate(to: .account)
                        }) {
                            Image("Avatars/jacob")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .clipShape(
                                    Circle()
                                )
                                .background(
                                    Circle()
                                        .frame(width: 36, height: 36)
                                )
                            
                        }
                    }
                }
            }
            .background(Color.BTBackground)
            
            if openModal {
                if let quiz = quizStore.chosenQuiz {
                    ChooseQuizModal(isPresented: $openModal, quiz: quiz, startQuiz: {
                        router.navigate(to: .quizView)
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
    .tint(Color.BTPrimary)
    .environment(QuizStore())
}
