//
//  PreviewEnvironment.swift
//  BibleTrivia
//

#if DEBUG
import SwiftUI
import Supabase

extension AppDependencies {
    /// Dependencies backed by `PreviewAPI` sample data. No network access.
    static func preview(api: BibleTriviaAPI = PreviewAPI(), loadData: Bool = true) -> AppDependencies {
        let client = SupabaseClient(
            supabaseURL: URL(string: "https://preview.invalid")!,
            supabaseKey: "preview"
        )
        let app = AppDependencies(client: client, api: api)
        if loadData {
            Task { await app.loadSignedInData() }
        }
        return app
    }
}

/// Wraps preview content in a navigation stack with all environment objects.
@MainActor
struct PreviewEnvironment<Content: View>: View {
    @State private var app: AppDependencies
    private let content: (AppDependencies) -> Content

    init(app: AppDependencies? = nil, @ViewBuilder content: @escaping (AppDependencies) -> Content) {
        _app = State(initialValue: app ?? .preview())
        self.content = content
    }

    init(app: AppDependencies? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.init(app: app) { _ in content() }
    }

    var body: some View {
        @Bindable var router = app.router
        NavigationStack(path: $router.path) {
            content(app)
                .navigationDestination(for: Router.Destination.self) { $0.view }
        }
        .applyAlertHandling()
        .inject(app)
    }
}
#endif
