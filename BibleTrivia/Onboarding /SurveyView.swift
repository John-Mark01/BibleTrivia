//
//  SurveyView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 19.01.25.
//

import SwiftUI

struct SurveyView: View {
    @EnvironmentObject var router: Router
    @Environment(OnboardingManager.self) var onboardingManager
    
    var disableButton: Bool {
        let quesitonIndex = onboardingManager.survey.currentQuestionIndex
        return onboardingManager.survey.questions[quesitonIndex].answers.filter({$0.isSelected}).count <= 0
    }
    func onContinue() {
        let quesitonIndex = onboardingManager.survey.currentQuestionIndex
        if quesitonIndex == onboardingManager.survey.numberOfQuestions {
            
        } else {
            if onboardingManager.survey.currentQuestionIndex <= onboardingManager.survey.numberOfQuestions {
                withAnimation {
                    onboardingManager.survey.currentQuestionIndex += 1
                }
            }
        }
    }
    func onSelectAnswer(answer: Answer) {
        let quesitonIndex = onboardingManager.survey.currentQuestionIndex
        
        if onboardingManager.survey.questions[quesitonIndex].answers.filter({$0.isSelected}).count > 0 {
            return
        }
        
        if let index = onboardingManager.survey.questions[quesitonIndex].answers.firstIndex(where: {$0.id == answer.id}) {
            onboardingManager.survey.questions[quesitonIndex].answers[index].isSelected = true
        }
    }
    func onUnselectAnswer(answer: Answer) {
        let quesitonIndex = onboardingManager.survey.currentQuestionIndex
        
        if let index = onboardingManager.survey.questions[quesitonIndex].answers.firstIndex(where: {$0.id == answer.id}) {
            onboardingManager.survey.questions[quesitonIndex].answers[index].isSelected = false
        }
    }
    
    func onNavigateBack() {
        let quesitonIndex = onboardingManager.survey.currentQuestionIndex
        if quesitonIndex == 0 {
            router.navigateBack()
        } else {
            withAnimation {
                onboardingManager.survey.currentQuestionIndex -= 1
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button(action: {
                    onNavigateBack()
                }) {
                    Image("Arrow")
                        .frame(width: 44, height: 44)
                        .layoutDirectionBehavior(.mirrors(in: .leftToRight))
                }
                
                LinearProgressView(progress: onboardingManager.survey.currentQuestionIndex + 1,
                                   goal: onboardingManager.survey.numberOfQuestions,
                                   showPercentage: false)
            }
            
            VStack(alignment: .leading, spacing: 40) {
                
                Text(onboardingManager.survey.questions[onboardingManager.survey.currentQuestionIndex].text)
                    .modifier(CustomText(size: 30, font: .semiBold))
                
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(onboardingManager.survey.questions[onboardingManager.survey.currentQuestionIndex].answers, id: \.id) { answer in
                        
                        let index = onboardingManager.survey.questions[onboardingManager.survey.currentQuestionIndex].answers.firstIndex(where: {$0.id == answer.id}) ?? 0
                        
                        AnswerViewRow(answer: answer,
                                      abcLetter: onboardingManager.getAnswerABC(index: index),
                                      selectAnswer: {onSelectAnswer(answer: answer)},
                                      unselectAnswer: {onUnselectAnswer(answer: answer)},
                                      isInReview: false)
                    }
                }
                
            }
            .padding(.top, 40)
            
            Spacer()
            
            OnboardButton(text: "Continue",
                          disabled: disableButton,
                          action: onContinue)
            
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarBackButtonHidden()
        .ignoresSafeArea(.keyboard)
        .padding(.horizontal, Constants.hPadding)
        .padding(.vertical, 30)
        .background(Color.BTBackground)
    }
}

#Preview {
    let manager = OnboardingManager()
    NavigationStack {
        SurveyView()
            .onAppear {
                manager.loadSurvey()
            }
    }
    .environment(manager)
    .environmentObject(Router())
}
