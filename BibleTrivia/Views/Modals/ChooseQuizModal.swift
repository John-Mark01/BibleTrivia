//
//  ChooseQuizModal.swift
//  BibleTrivia
//

import SwiftUI

struct ChooseQuizModal: View {
    let quiz: Quiz
    let startQuiz: () -> Void
    let cancel: () -> Void

    var body: some View {
        ZStack {
            Color.black
                .opacity(0.1)
                .onTapGesture(perform: cancel)

            VStack(alignment: .center, spacing: 10) {
                Text(quiz.name)
                    .applyFont(.medium, size: 20, textColor: .btPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)

                VStack(spacing: 22) {
                    InfoRow(image: "medal-star", title: "Level:", value: quiz.difficulty.title)
                    InfoRow(image: "task-square", title: "Questions:", value: "\(quiz.numberOfQuestions)")
                    InfoRow(image: "cup", title: "Points:", value: "\(quiz.totalPoints)")
                    InfoRow(image: "timer", title: "Time:", value: "\(Int(quiz.timeToComplete.rounded())) min")
                }

                Spacer()

                VStack {
                    Button("Start Quiz", action: startQuiz)
                        .buttonStyle(.primary)

                    Button("Cancel", action: cancel)
                        .buttonStyle(.secondary)
                }
            }
            .padding(25)
            .background(.btBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .fixedSize(horizontal: false, vertical: true)
            .padding(30)
        }
        .ignoresSafeArea()
    }
}

struct InfoRow: View {
    let image: String
    let title: LocalizedStringKey
    let value: String

    var body: some View {
        HStack {
            Image(image)
            Text(title)
                .applyFont(.medium, size: 18)
            Spacer()
            Text(value)
                .applyFont(.regular, size: 18)
        }
    }
}

// MARK: - Presentation

/// Shows `ChooseQuizModal` while `quiz` is non-nil, starts the quiz on
/// confirmation and navigates to the quiz screen.
private struct QuizStartModal: ViewModifier {
    @Binding var quiz: Quiz?
    @Environment(QuizStore.self) private var quizStore
    @Environment(Router.self) private var router

    func body(content: Content) -> some View {
        content
            .blur(radius: quiz != nil ? 3 : 0)
            .disabled(quiz != nil)
            .blurTabBar(quiz != nil)
            .overlay {
                if let quiz {
                    ChooseQuizModal(
                        quiz: quiz,
                        startQuiz: { start(quiz) },
                        cancel: { self.quiz = nil }
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }
            }
            .animation(.snappy, value: quiz?.id)
    }

    private func start(_ quiz: Quiz) {
        Task {
            if await quizStore.start(quiz) {
                self.quiz = nil
                router.navigate(to: .quiz)
            }
        }
    }
}

extension View {
    func quizStartModal(_ quiz: Binding<Quiz?>) -> some View {
        modifier(QuizStartModal(quiz: quiz))
    }
}

#Preview {
    ChooseQuizModal(quiz: SampleData.quizzes[0], startQuiz: {}, cancel: {})
}
