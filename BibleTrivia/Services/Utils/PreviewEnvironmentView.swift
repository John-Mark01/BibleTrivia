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
        .environment(UserStore.mock)
        .environment(AuthManager.mock)
        .environment(AlertManager.shared)
//        .environment(OnboardingManager.mock)
        .environment(router)
    }
}
#endif


extension QuizStore {
    static var mock: QuizStore {
        QuizStore(supabase: MockSupabase())
    }
}

extension UserStore {
    static var mock: UserStore {
        UserStore(supabase: MockSupabase(), alertManager: .shared)
    }
}
extension AuthManager {
    static var mock: AuthManager {
        AuthManager(supabaseClient: MockSupabase().supabaseClient)
    }
}

//extension OnboardingManager {
//    static var mock: OnboardingManager {
//        OnboardingManager(supabase: MockSupabase())
//    }
//}

class MockSupabase: Supabase {
    override init(supabaseClient: SupabaseClient = .init(supabaseURL: Secrets.supabaseURL, supabaseKey: Secrets.supabaseAPIKey)) {
        super.init(supabaseClient: supabaseClient)
    }
}
