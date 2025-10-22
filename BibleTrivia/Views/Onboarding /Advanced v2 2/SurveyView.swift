//
//  SurveyView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 19.01.25.
//
//
//import SwiftUI
//
//struct SurveyView: View {
//    @Environment(Router.self) private var router
//    @Environment(OnboardingManager.self) var onboardingManager
//    
//    @State private var resetSelection: Bool = false
//    @State private var showDidYouKnow: Bool = false
//    
//    var continueIsDisabled: Bool {
//        let quesitonIndex = onboardingManager.survey.currentQuestionIndex
//        return onboardingManager.survey.questions[quesitonIndex].answers.filter({$0.isSelected}).count <= 0
//    }
//    var selectIsDisabled: Bool {
//        let quesitonIndex = onboardingManager.survey.currentQuestionIndex
//        return onboardingManager.survey.questions[quesitonIndex].answers.filter({$0.isSelected}).count == 1
//    }
//    
//    func onContinue() {
//        let quesitonIndex = onboardingManager.survey.currentQuestionIndex
//        
//        if (quesitonIndex + 1) % 2 == 0 {
//            if !onboardingManager.didYouKnowIsShown {
//                showDidYouKnow = true
//                onboardingManager.didYouKnowIsShown = false
//                resetSelection.toggle()
//                return
//            }
//        }
//        advance()
//    }
//    
//    private func advance() {
//        withAnimation {
//            onboardingManager.advanceToNextQuestion()
//        }
//    }
//    
//    func onNavigateBack() {
//        let quesitonIndex = onboardingManager.survey.currentQuestionIndex
//        if quesitonIndex == 0 {
//            router.popBackStack()
//        } else {
//            withAnimation {
//                onboardingManager.survey.currentQuestionIndex -= 1
//            }
//        }
//    }
//    
//    var body: some View {
//        VStack(alignment: .leading) {
//            HStack {
//                Button(action: {
//                    onNavigateBack()
//                }) {
//                    Image("Icon/pointing_arrow")
//                        .frame(width: 44, height: 44)
//                        .layoutDirectionBehavior(.mirrors(in: .leftToRight))
//                }
//                
//                LinearProgressView(progress: onboardingManager.survey.currentQuestionIndex + 1,
//                                   goal: onboardingManager.survey.numberOfQuestions,
//                                   showPercentage: false)
//            }
//            
//            ScrollView(showsIndicators: false) {
//                VStack(alignment: .leading, spacing: 40) {
//                    
//                    Text(onboardingManager.survey.questions[onboardingManager.survey.currentQuestionIndex].text)
//                        .applyFont(.semiBold, size: 30)
//                    
//                    VStack(alignment: .leading, spacing: 16) {
//                        ForEach(onboardingManager.survey.currentQuestion.answers, id: \.id) { answer in
//                            SurveyButton(
//                                text: answer.text,
//                                isSelected: answer.isSelected,
//                                action: {
//                                    withAnimation {
//                                        onboardingManager.onSelectAnswer(answer: answer)
//                                    }
//                                },
//                                disabled: selectIsDisabled
//                            )
//                        }
//                    }
//                    
//                }
//                .padding(.top, 40)
//            }
//            
//            Spacer()
//            
//            OnboardButton(text: "Continue",
//                          disabled: continueIsDisabled,
//                          action: onContinue)
//            
//            
//        }
//        .applyBackground()
//        .applyViewPaddings()
//        .navigationBarBackButtonHidden()
//        .sheet(isPresented: $showDidYouKnow, onDismiss: advance) {
//            DidYouKnowScreen()
//                .presentationDetents([.fraction(0.5)])
//        }
//    }
//}
//
//#Preview {
//    let manager = OnboardingManager.mock
//    PreviewEnvironmentView {
//        SurveyView()
//            .onAppear {
//                manager.loadSurvey()
//            }
//    }
//}
//
//
