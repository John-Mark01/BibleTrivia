//
//  HomeView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 8.10.24.
//

import SwiftUI

struct HomeView: View {
    @Environment(QuizStore.self) var quizStore
    @State private var viewModel = HomeViewViewModel()
    @State private var openModal: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Welcome, Chris!")
                        .modifier(CustomText(size: 24, font: .title))
                    Spacer()
                }
                //MARK: Top Buttons
                HStack {
                    
                    Button(action: {
                        //TODO: Modal showing the scorring
                    }) {
                        HStack {
                            Image(systemName: "star.fill")
                                .resizable()
                                .frame(width: 34, height: 34)
                                .foregroundStyle(Color.yellow)
                                .padding(.trailing, 4)
                            Text("Score:")
                                .modifier(CustomText(size: 24, font: .questionTitle))
                                .foregroundStyle(Color.white)
                            Text("328")
                                .modifier(CustomText(size: 24, font: .body))
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
                                .modifier(CustomText(size: 34, font: .questionTitle))
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
                        .modifier(CustomText(size: 20, font: .heading))
                    
                    UnfinishedQuizesViewRow(quizes: viewModel.quizzes, isPresented: $openModal)
                }
                
                //MARK: Find New Quizzes
                VStack(alignment: .leading, spacing: 10) {
                    Text("Find New Quizzes")
                        .modifier(CustomText(size: 20, font: .heading))
                    ForEach(viewModel.quizzes, id: \.id) { quiz in
                        FindQuizViewRow(quiz: quiz)
                    }
                    
                }
                .padding(.top, 10)
            }
            .padding(.horizontal, Constants.hPadding)
            .padding(.vertical, Constants.vPadding)
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.BTBackground)
            .blur(radius: openModal ? 3 : 0)
            .sheet(isPresented: $openModal) {
                ChooseQuizModal(isPresented: $openModal)
                    .presentationDetents([.fraction(0.5)])
                    .presentationBackground(.clear)
                    .presentationCornerRadius(20)
                    .presentationDragIndicator(.visible)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        
                    }) {
                        Image(systemName: "line.3.horizontal")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        
                    }) {
                        Circle()
                            .frame(width: 32, height: 32)
                            .background(
                                Image("profile_pic")
                                    .resizable()
                                    .scaledToFit()
                            )
                    }
                }
            }
        }
        .background(Color.BTBackground)
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }.tint(Color.BTPrimary)
}
