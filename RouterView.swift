//
//  RouterView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 9.10.24.
//

import SwiftUI

// MARK: - RouterView Implementation
struct RouterView<Content: View>: View {
    @State private var router = Router.shared
    
    private let content: Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        NavigationStack(path: $router.path) {
            content
                .navigationDestination(for: Router.Destination.self) { destination in
                    router.view(for: destination)
                }
        }
        .tint(Color.BTBlack)
        .applyAlertHandling()
    }
}
