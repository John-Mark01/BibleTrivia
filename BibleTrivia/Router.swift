//
//  Router.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 8.10.24.
//

import SwiftUI

class Router: ObservableObject {
    
    @Published var path = NavigationPath() {
        didSet {
            if path.count < oldValue.count {
                
            }
        }
    }
    @Published var currentView: Destination = .home
    
    private static var stack: [Destination] = [.home]
    
    enum Destination: Codable, Hashable {
        //MARK: TabView
        case home
        case play
        case quizView
        case topics
        case account
        //MARK: Other Views
        // Onboarding
        
        // Registration
        
        // Login
        
    }
    
    // View builders for each destination
    @ViewBuilder
    func view(for destination: Destination) -> some View {
        switch destination {
            //MARK: Main Screens
        case .home:
            HomeView()
        case .play:
            PlayView()
        case .topics:
            TopicsView()
            
            //MARK: Quiz Screens
        case .quizView:
            QuizView()
            
            //MARK: Account
        case .account:
            AccountView()
        }
    }
    
    public func navigate(to destination: Destination) {
        Router.stack.append(destination)
        path.append(destination)
        print("Navigate to: \(destination)")
    }
    
    public func navigateBack() {
        Router.stack.removeLast()
        path.removeLast()
        print("Navigated back. Routes stack: \(Router.stack.count)")
    }
    
    public func navigateToRoot() {
        Router.stack.removeAll()
        path.removeLast(path.count)
    }
    private func handleBackNavigation(from oldPath: NavigationPath, to newPath: NavigationPath) {
        let removedCount = oldPath.count - path.count
        Router.stack.removeLast(removedCount)
        print("Navigated back. Routes stack: \(Router.stack.count)")
    }
}
