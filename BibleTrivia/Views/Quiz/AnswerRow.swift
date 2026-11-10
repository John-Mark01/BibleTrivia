//
//  AnswerRow.swift
//  BibleTrivia
//

import SwiftUI

struct AnswerRow: View {
    enum State {
        case idle
        case selected
        /// Review: the correct answer, not picked by the user.
        case correct
        /// Review: the correct answer, picked by the user.
        case correctSelected
        /// Review: a wrong answer picked by the user.
        case incorrectSelected

        var isReview: Bool {
            switch self {
            case .idle, .selected: false
            case .correct, .correctSelected, .incorrectSelected: true
            }
        }
    }

    let answer: Answer
    let letter: String
    let state: State
    let onTap: () -> Void

    @SwiftUI.State private var tapCount = 0

    var body: some View {
        Button {
            tapCount += 1
            onTap()
        } label: {
            HStack(alignment: .center, spacing: 16) {
                Circle()
                    .foregroundStyle(circleColor)
                    .frame(width: 28, height: 28)
                    .overlay(Text(letter).foregroundStyle(letterColor))

                Text(answer.text)
                    .applyFont(.regular, size: 16, textColor: textColor)
                    .multilineTextAlignment(.leading)

                Spacer()
            }
            .padding(.horizontal, Constants.horizontalPadding)
            .frame(minHeight: 50)
            .background(RoundedRectangle(cornerRadius: 20).fill(backgroundColor))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(strokeColor, lineWidth: 2)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(state.isReview)
        .sensoryFeedback(.selection, trigger: tapCount)
        .accessibilityLabel("\(letter). \(answer.text)")
        .accessibilityAddTraits(state == .selected || state == .correctSelected || state == .incorrectSelected ? .isSelected : [])
        .accessibilityHint(accessibilityHint)
    }

    private var backgroundColor: Color {
        switch state {
        case .idle: .btBackground
        case .selected, .incorrectSelected: .clear
        case .correct, .correctSelected: .btPrimary
        }
    }

    private var strokeColor: Color {
        switch state {
        case .idle, .correct: .btStroke
        case .selected: .btPrimary
        case .correctSelected: .btBlack
        case .incorrectSelected: .btIncorrect
        }
    }

    private var circleColor: Color {
        switch state {
        case .idle: .btAnswer
        case .selected: .btPrimary
        case .correct, .correctSelected: .white
        case .incorrectSelected: .btIncorrect
        }
    }

    private var letterColor: Color {
        switch state {
        case .idle: .black
        case .selected, .incorrectSelected: .white
        case .correct, .correctSelected: .btPrimary
        }
    }

    private var textColor: Color {
        switch state {
        case .idle: .btBlack
        case .selected: .btPrimary
        case .correct, .correctSelected: .white
        case .incorrectSelected: .btIncorrect
        }
    }

    private var accessibilityHint: String {
        switch state {
        case .idle, .selected: ""
        case .correct: "Correct answer"
        case .correctSelected: "Your answer, correct"
        case .incorrectSelected: "Your answer, incorrect"
        }
    }
}

#Preview {
    let answer = SampleData.quizzes[0].questions[0].answers[0]
    VStack(spacing: 12) {
        AnswerRow(answer: answer, letter: "A", state: .idle) {}
        AnswerRow(answer: answer, letter: "B", state: .selected) {}
        AnswerRow(answer: answer, letter: "C", state: .correct) {}
        AnswerRow(answer: answer, letter: "D", state: .correctSelected) {}
        AnswerRow(answer: answer, letter: "E", state: .incorrectSelected) {}
    }
    .applyViewPaddings()
}
