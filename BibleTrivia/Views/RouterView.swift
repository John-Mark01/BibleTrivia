//
//  RouterView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 9.10.24.
//

import SwiftUI

struct RouterView<Content: View>: View {
    @EnvironmentObject var router: Router
    // Our root view content
    private let content: Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        NavigationStack(path: $router.path) {
            content
                .navigationDestination(for: Router.Destination.self) { route in
                    router.view(for: route)
                }
        }
        .environmentObject(router)
    }
}
