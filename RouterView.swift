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
        // This is the key - detect when the path changes due to native back gestures
        .onChange(of: router.path) { oldPath, newPath in
            if oldPath.count != newPath.count {
                router.handlePathChange()
            }
        }
    }
}



struct BTBackground: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.BTBackground)
    }
}
struct BTViewPadding: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, Constants.hPadding)
            .padding(.vertical, Constants.vPadding)
    }
}

struct BTEdgesPadding: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .padding(EdgeInsets(top: 16, leading: 8, bottom: 16, trailing: 8))
    }
}

extension View {
    func addBackground() -> some View {
        self.modifier(BTBackground())
    }
    
    func addViewPaddings() -> some View {
        self.modifier(BTViewPadding())
    }
    
    func addInsideaddings() -> some View {
        self.modifier(BTEdgesPadding())
    }
}


struct BaseStack: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .padding(EdgeInsets(top: 16, leading: 8, bottom: 16, trailing: 8))
    }
}
