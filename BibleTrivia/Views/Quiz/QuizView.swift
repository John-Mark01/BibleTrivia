//
//  QuizView.swift
//  BibleTrivia
//

import SwiftUI

struct QuizView: View {
    @Environment(QuizStore.self) private var quizStore
    @Environment(Router.self) private var router

    var body: some View {
        Group {
            if let player = quizStore.player {
                QuizPlayView(player: player)
            } else {
                ContentUnavailableView {
                    Label("No quiz selected", systemImage: "questionmark.circle")
                } actions: {
                    Button("Go Back") { router.pop() }
                }
            }
        }
        .navigationBarBackButtonHidden()
        .applyBackground()
        // The player is released only once the screen is gone, so it stays
        // visible during the pop animation.
        .onDisappear { quizStore.close() }
    }
}

private struct QuizPlayView: View {
    let player: QuizPlayer

    @Environment(QuizStore.self) private var quizStore
    @Environment(Router.self) private var router
    @Environment(AlertManager.self) private var alertManager

    private var isReviewing: Bool { player.phase == .reviewing }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 16) {
                LinearProgressView(progress: isReviewing
                    ? Double(player.questionNumber) / Double(max(player.quiz.numberOfQuestions, 1))
                    : player.progress)
                    .setStroke(color: .btDarkGray, size: 1)

                Image("Icon/close")
                    .makeButton(action: onClose, addHapticFeedback: true, feedbackStyle: .error)
                    .accessibilityLabel("Close quiz")
            }

            if let question = player.currentQuestion {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Question \(player.questionNumber) of \(player.quiz.numberOfQuestions)")
                            .applyFont(.semiBold, size: 14)

                        Text(question.displayText)
                            .applyFont(.semiBold, size: 20)

                        VStack(spacing: 16) {
                            ForEach(Array(question.answers.enumerated()), id: \.element.id) { index, answer in
                                AnswerRow(
                                    answer: answer,
                                    letter: Question.letter(forAnswerAt: index),
                                    state: state(of: answer, in: question)
                                ) {
                                    player.toggleSelection(answerId: answer.id)
                                }
                            }
                        }
                        .padding(.top, 16)

                        if isReviewing, let explanation = question.explanation, !explanation.isEmpty {
                            ExplanationBox(text: explanation)
                                .padding(.top, 8)
                        }
                    }
                }
                .id(question.id)
                .transition(.push(from: .trailing))
            }

            Spacer(minLength: 0)

            if isReviewing {
                HStack {
                    Button("") { withAnimation { player.goToPreviousQuestion() } }
                        .buttonStyle(.next(width: 67, direction: .left))
                        .disabled(player.isFirstQuestion)
                        .opacity(player.isFirstQuestion ? 0.4 : 1)
                        .accessibilityLabel("Previous question")
                    Spacer()
                    Button("") { onReviewNext() }
                        .buttonStyle(.next(width: 67, direction: .right))
                        .accessibilityLabel(player.isLastQuestion ? "Show results" : "Next question")
                }
            } else {
                HStack(alignment: .center, spacing: 20) {
                    Spacer()
                    Text(player.isLastQuestion ? "FINISH" : "NEXT")
                        .applyFont(.regular, size: 14, textColor: .btPrimary)
                    Button("") { onSubmit() }
                        .buttonStyle(.next(width: 67, direction: .right))
                        .accessibilityLabel(player.isLastQuestion ? "Finish quiz" : "Next question")
                }
            }
        }
        .applyViewPaddings()
        .animation(.snappy, value: player.currentIndex)
        .blur(radius: player.phase == .finished ? 3 : 0)
        .disabled(player.phase == .finished)
        .overlay {
            if player.phase == .finished, let completion = player.completion {
                FinishedQuizModal(
                    player: player,
                    completion: completion,
                    onContinue: onFinish,
                    onReview: { withAnimation { player.startReview() } }
                )
                .transition(.opacity)
            }
        }
        .animation(.snappy, value: player.phase)
    }

    private func state(of answer: Answer, in question: Question) -> AnswerRow.State {
        let isSelected = player.selectedAnswerId(for: question) == answer.id
        guard isReviewing else { return isSelected ? .selected : .idle }
        if answer.isCorrect { return isSelected ? .correctSelected : .correct }
        return isSelected ? .incorrectSelected : .idle
    }

    private func onSubmit() {
        switch player.submitCurrentAnswer() {
        case .noSelection:
            alertManager.showAlert(type: .warning, message: "Please select an answer.", buttonText: "Okay")
        case .advanced:
            break
        case .reachedEnd:
            Task { await quizStore.complete() }
        }
    }

    private func onReviewNext() {
        if !player.goToNextQuestion() {
            player.showResults()
        }
    }

    private func onClose() {
        switch player.phase {
        case .playing:
            alertManager.showQuizExitAlert(quizName: player.quiz.name) {
                Task {
                    if await quizStore.saveAndExit() {
                        router.pop()
                    }
                }
            }
        case .reviewing:
            player.showResults()
        case .finished:
            onFinish()
        }
    }

    private func onFinish() {
        router.pop()
    }
}

private struct ExplanationBox: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "book.closed.fill")
                .foregroundStyle(.btPrimary)
            Text(text)
                .applyFont(.regular, size: 15)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16).fill(.btPrimary.opacity(0.08)))
    }
}

private extension Question {
    /// Question text with a trailing "?" when the content has no ending punctuation.
    var displayText: String {
        guard let last = text.trimmingCharacters(in: .whitespaces).last else { return text }
        return last.isPunctuation ? text : text + "?"
    }
}

#Preview {
    let app = AppDependencies.preview()
    app.quizStore.resume(SampleData.inProgressAttempt)
    return PreviewEnvironment(app: app) {
        QuizView()
    }
}
