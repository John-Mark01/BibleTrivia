//
//  QuizPlayerTests.swift
//  BibleTriviaTests
//

import Testing
@testable import BibleTrivia

@MainActor
struct QuizPlayerTests {
    let quiz = SampleData.quiz(id: 1, name: "Test")

    private func freshSession(answers: [SavedAnswer] = []) -> QuizSession {
        SampleData.session(id: 1, quiz: quiz, status: .inProgress, answers: answers)
    }

    @Test func startsAtFirstQuestionWhenNothingAnswered() {
        let player = QuizPlayer(quiz: quiz, session: freshSession())
        #expect(player.currentIndex == 0)
        #expect(player.progress == 0)
        #expect(player.phase == .playing)
    }

    @Test func resumesAtFirstUnansweredQuestion() {
        let q1 = quiz.questions[0]
        let saved = [SavedAnswer(questionId: q1.id, answerId: q1.answers[1].id, isCorrect: false)]
        let player = QuizPlayer(quiz: quiz, session: freshSession(answers: saved))

        #expect(player.currentIndex == 1)
        #expect(player.answeredCount == 1)
        #expect(player.selectedAnswerId(for: q1) == q1.answers[1].id)
    }

    @Test func submitWithoutSelectionIsRejected() {
        let player = QuizPlayer(quiz: quiz, session: freshSession())
        #expect(player.submitCurrentAnswer() == .noSelection)
        #expect(player.currentIndex == 0)
    }

    @Test func togglingTheSameAnswerClearsIt() {
        let player = QuizPlayer(quiz: quiz, session: freshSession())
        let answer = quiz.questions[0].answers[0]
        player.toggleSelection(answerId: answer.id)
        #expect(player.pendingAnswerId == answer.id)
        player.toggleSelection(answerId: answer.id)
        #expect(player.pendingAnswerId == nil)
    }

    @Test func selectingAnotherAnswerReplacesSelection() {
        let player = QuizPlayer(quiz: quiz, session: freshSession())
        let answers = quiz.questions[0].answers
        player.toggleSelection(answerId: answers[0].id)
        player.toggleSelection(answerId: answers[2].id)
        #expect(player.pendingAnswerId == answers[2].id)
    }

    @Test func playsThroughToTheEnd() {
        let player = QuizPlayer(quiz: quiz, session: freshSession())

        for (index, question) in quiz.questions.enumerated() {
            player.toggleSelection(answerId: question.answers[0].id)
            let outcome = player.submitCurrentAnswer()
            #expect(outcome == (index == quiz.questions.count - 1 ? .reachedEnd : .advanced))
        }

        #expect(player.progress == 1)
        #expect(player.selections.count == quiz.questions.count)
        #expect(quiz.questions.allSatisfy(player.isAnsweredCorrectly))
    }

    @Test func selectionsAreSentWithoutCorrectness() {
        let player = QuizPlayer(quiz: quiz, session: freshSession())
        let question = quiz.questions[0]
        player.toggleSelection(answerId: question.answers[3].id)
        _ = player.submitCurrentAnswer()

        #expect(player.selections == [AnswerSelection(questionId: question.id, answerId: question.answers[3].id)])
        #expect(!player.isAnsweredCorrectly(question))
    }

    @Test func reviewModeNavigatesAndReturnsToResults() {
        let player = QuizPlayer(quiz: quiz, session: freshSession())
        player.startReview() // ignored while playing
        #expect(player.phase == .playing)

        let completion = QuizCompletion(
            session: SampleData.session(id: 1, quiz: quiz, status: .completed, answers: []),
            totalPoints: 10, level: .newBorn, leveledUp: false
        )
        player.markCompleted(completion)
        #expect(player.phase == .finished)

        player.startReview()
        #expect(player.phase == .reviewing)
        #expect(player.currentIndex == 0)
        #expect(!player.goToPreviousQuestion())
        #expect(player.goToNextQuestion())
        #expect(player.goToNextQuestion())
        #expect(!player.goToNextQuestion())
        #expect(player.isLastQuestion)

        player.showResults()
        #expect(player.phase == .finished)
    }

    @Test func selectionIsLockedOutsidePlaying() {
        let player = QuizPlayer(quiz: quiz, session: freshSession())
        player.markCompleted(QuizCompletion(
            session: SampleData.session(id: 1, quiz: quiz, status: .completed, answers: []),
            totalPoints: 0, level: .newBorn, leveledUp: false
        ))
        player.toggleSelection(answerId: quiz.questions[0].answers[0].id)
        #expect(player.pendingAnswerId == nil)
    }
}
