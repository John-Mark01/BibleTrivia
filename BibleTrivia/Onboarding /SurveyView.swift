//
//  SurveyView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 19.01.25.
//

import SwiftUI

struct SurveyView: View {
    @Environment(Router.self) private var router
    @Environment(OnboardingManager.self) var onboardingManager
    
    @State private var resetSelection: Bool = false
    @State private var showDidYouKnow: Bool = false
    
    var continueIsDisabled: Bool {
        let quesitonIndex = onboardingManager.survey.currentQuestionIndex
        return onboardingManager.survey.questions[quesitonIndex].answers.filter({$0.isSelected}).count <= 0
    }
    var selectIsDisabled: Bool {
        let quesitonIndex = onboardingManager.survey.currentQuestionIndex
        return onboardingManager.survey.questions[quesitonIndex].answers.filter({$0.isSelected}).count == 1
    }
    
    func onContinue() {
        let quesitonIndex = onboardingManager.survey.currentQuestionIndex
        
        if (quesitonIndex + 1) % 2 == 0 {
            if !onboardingManager.didYouKnowIsShown {
                showDidYouKnow = true
                onboardingManager.didYouKnowIsShown = false
                resetSelection.toggle()
                return
            }
        }
        
        advanceToNextQuestion()
    }
    
    private func advanceToNextQuestion() {
        let questionIndex = onboardingManager.survey.currentQuestionIndex
        
        if questionIndex == onboardingManager.survey.numberOfQuestions - 1 {
            return
        } else {
            withAnimation {
                onboardingManager.survey.currentQuestionIndex += 1
            }
        }
//        resetSelection.toggle()
    }
    
    func onSelectAnswer(answer: Answer) {
        print("Selecting a answer")
        let quesitonIndex = onboardingManager.survey.currentQuestionIndex
        
        if onboardingManager.survey.questions[quesitonIndex].answers.filter({$0.isSelected}).count > 0 {
            return
        }
        
        if let index = onboardingManager.survey.questions[quesitonIndex].answers.firstIndex(where: {$0.id == answer.id}) {
            onboardingManager.survey.questions[quesitonIndex].answers[index].isSelected = true
        }
    }
    func onUnselectAnswer(answer: Answer) {
        print("Unselecting a answer")
        let quesitonIndex = onboardingManager.survey.currentQuestionIndex
        
        if let index = onboardingManager.survey.questions[quesitonIndex].answers.firstIndex(where: {$0.id == answer.id}) {
            onboardingManager.survey.questions[quesitonIndex].answers[index].isSelected = false
        }
    }
    
    func onNavigateBack() {
        let quesitonIndex = onboardingManager.survey.currentQuestionIndex
        if quesitonIndex == 0 {
            router.popBackStack()
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
                        
                        SurveyButton(
                            text: answer.text,
                            actionOnSelect: {onSelectAnswer(answer: answer)},
                            actionOnUnSelect: {onUnselectAnswer(answer: answer)},
                            disabled: selectIsDisabled,
                            resetSelection: $resetSelection)
                        
                    }
                }
                
            }
            .padding(.top, 40)
            
            Spacer()
            
            OnboardButton(text: "Continue",
                          disabled: continueIsDisabled,
                          action: onContinue)
            
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarBackButtonHidden()
        .ignoresSafeArea(.keyboard)
        .padding(.horizontal, Constants.hPadding)
        .padding(.vertical, 30)
        .background(Color.BTBackground)
        
        .sheet(isPresented: $showDidYouKnow, onDismiss: advanceToNextQuestion) {
            DidYouKnowScreen()
                .presentationDetents([.fraction(0.5)])
        }
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
    .environment(Router.shared)
}


