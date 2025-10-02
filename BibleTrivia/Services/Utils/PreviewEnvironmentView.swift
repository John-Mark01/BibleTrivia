//
//  PreviewEnvironmentView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 2.10.25.
//

import SwiftUI
import Supabase

#if DEBUG
struct PreviewEnvironmentView<Content: View>: View {
    @State private var router = Router.shared
    
    @ViewBuilder let content: Content
    
    var body: some View {
        NavigationStack(path: $router.path) {
            Group {
                content
            }
            .navigationDestination(for: Router.Destination.self) { destination in
                router.view(for: destination)
            }
        }
        .applyAlertHandling()
        .environment(QuizStore.mock)
        .environment(UserManager.mock)
        .environment(AlertManager.shared)
        .environment(OnboardingManager.mock)
        .environment(router)
    }
}
#endif


extension QuizStore {
    static var mock: QuizStore {
        QuizStore(supabase: MockSupabase())
    }
}

extension UserManager {
    static var mock: UserManager {
        UserManager(supabase: MockSupabase(), alertManager: .shared)
    }
}

extension OnboardingManager {
    static var mock: OnboardingManager {
        OnboardingManager(supabase: MockSupabase())
    }
}

class MockSupabase: Supabase {
    override init(supabaseClient: SupabaseClient = .init(supabaseURL: Secrets.supabaseURL, supabaseKey: Secrets.supabaseAPIKey)) {
        super.init(supabaseClient: supabaseClient)
    }
}
