//
//  StoreFlowTests.swift
//  BibleTriviaTests
//

import Foundation
import Testing
@testable import BibleTrivia

/// End-to-end store behaviour against the in-memory `PreviewAPI`.
@MainActor
struct StoreFlowTests {
    let api = PreviewAPI()
    let app: AppDependencies

    init() {
        app = AppDependencies.preview(api: api, loadData: false)
    }

    @Test func initialLoadPopulatesStores() async {
        await app.loadSignedInData()
        #expect(app.userStore.profile != nil)
        #expect(!app.userStore.inProgress.isEmpty)
        #expect(!app.quizStore.available.items.isEmpty)
        #expect(!app.topicStore.topics.items.isEmpty)
    }

    @Test func startingAQuizMovesItToInProgress() async throws {
        await app.loadSignedInData()
        let quiz = try #require(app.quizStore.available.items.first)

        let started = await app.quizStore.start(quiz)

        #expect(started)
        #expect(app.quizStore.player?.quiz.id == quiz.id)
        #expect(!app.quizStore.available.items.contains { $0.id == quiz.id })
        #expect(app.userStore.inProgress.first?.quiz.id == quiz.id)
    }

    @Test func completingAQuizUpdatesProfileAndHistory() async throws {
        await app.loadSignedInData()
        let quiz = try #require(app.quizStore.available.items.first)
        _ = await app.quizStore.start(quiz)
        let player = try #require(app.quizStore.player)
        let pointsBefore = app.userStore.profile?.totalPoints ?? 0

        for question in quiz.questions {
            player.toggleSelection(answerId: question.answers[0].id) // all correct in sample data
            _ = player.submitCurrentAnswer()
        }
        await app.quizStore.complete()

        #expect(player.phase == .finished)
        #expect(player.passed)
        #expect(app.userStore.profile?.totalPoints == pointsBefore + quiz.totalPoints)
        #expect(!app.userStore.inProgress.contains { $0.quiz.id == quiz.id })
        #expect(app.userStore.completed.items.first?.quiz.id == quiz.id)
    }

    @Test func saveAndExitKeepsProgress() async throws {
        await app.loadSignedInData()
        let quiz = try #require(app.quizStore.available.items.first)
        _ = await app.quizStore.start(quiz)
        let player = try #require(app.quizStore.player)

        player.toggleSelection(answerId: quiz.questions[0].answers[1].id)
        _ = player.submitCurrentAnswer()
        let saved = await app.quizStore.saveAndExit()

        #expect(saved)
        let attempt = try #require(app.userStore.inProgress.first { $0.quiz.id == quiz.id })
        #expect(attempt.session.answers.count == 1)
        #expect(attempt.progress > 0)
    }

    @Test func failedStartShowsAlertAndKeepsQuiz() async throws {
        await app.loadSignedInData()
        let quiz = try #require(app.quizStore.available.items.first)
        await api.setFailNextCall(.network)

        let started = await app.quizStore.start(quiz)

        #expect(!started)
        #expect(app.quizStore.player == nil)
        #expect(app.alerts.current != nil)
        #expect(app.quizStore.available.items.contains { $0.id == quiz.id })
    }
}
