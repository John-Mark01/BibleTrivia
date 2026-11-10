//
//  AppDependencies.swift
//  BibleTrivia
//

import SwiftUI
import Supabase

/// Composition root: builds every long-lived object once and wires their
/// dependencies. Views receive them through the environment (`inject(_:)`).
@MainActor
final class AppDependencies {
    let router = Router()
    let alerts = AlertManager()
    let loading = LoadingManager()
    let auth: AuthManager
    let userStore: UserStore
    let topicStore: TopicStore
    let quizStore: QuizStore
    let api: BibleTriviaAPI

    init(client: SupabaseClient, api: BibleTriviaAPI) {
        self.api = api
        auth = AuthManager(client: client, api: api, alerts: alerts, loading: loading)
        userStore = UserStore(api: api, alerts: alerts)
        topicStore = TopicStore(api: api, alerts: alerts)
        quizStore = QuizStore(api: api, alerts: alerts, loading: loading, userStore: userStore, topicStore: topicStore)
    }

    static func live() -> AppDependencies {
        let client = SupabaseClient(supabaseURL: AppConfig.supabaseURL, supabaseKey: AppConfig.supabaseKey)
        return AppDependencies(client: client, api: SupabaseAPI(client: client))
    }

    /// Loads everything the signed-in screens need, in parallel.
    func loadSignedInData() async {
        async let user: Void = userStore.loadInitialData()
        async let quizzes: Void = quizStore.loadAvailable(reset: true)
        async let topics: Void = topicStore.loadTopics(reset: true)
        _ = await (user, quizzes, topics)
    }

    func resetSignedInData() {
        userStore.reset()
        quizStore.reset()
        topicStore.reset()
    }
}

extension View {
    func inject(_ app: AppDependencies) -> some View {
        self
            .environment(app.router)
            .environment(app.alerts)
            .environment(app.loading)
            .environment(app.auth)
            .environment(app.userStore)
            .environment(app.topicStore)
            .environment(app.quizStore)
    }
}
