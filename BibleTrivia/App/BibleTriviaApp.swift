//
//  BibleTriviaApp.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 8.10.24.
//

import SwiftUI

@main
struct BibleTriviaApp: App {
    @State private var app = AppDependencies.live()

    var body: some Scene {
        WindowGroup {
            RootView(app: app)
        }
    }
}
