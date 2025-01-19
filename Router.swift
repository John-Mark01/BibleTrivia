//
//  Router.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 8.10.24.
//

import SwiftUI

@MainActor
class Router: ObservableObject {
    
    @Published var path = NavigationPath()
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
        case welcome
        case login
    }
    
    // View builders for each destination
    @ViewBuilder
    func view(for destination: Destination) -> some View {
        switch destination {
            
            //MARK: Onboarding - Registration & Login
        case .welcome:
            WelcomeView()
        case .login:
            LoginView()
            
            //MARK: TabView Screens
        case .home:
            HomeViewTabBar()
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
        guard path.count >= 1 else { return }
        
        Router.stack.removeLast()
        path.removeLast()
        print("Navigated back. Routes stack: \(Router.stack.count)")
    }
    
    public func navigateToRoot() {
        Router.stack.removeAll()
        path.removeLast(path.count)
    }
    
    func navigateAndClearBackStack(to destination: Destination) {
        if let index = Router.stack.firstIndex(of: destination) {
            // Calculate how many items we need to remove
            let itemsToRemove = Router.stack.count - index
            
            // Remove all items after the found destination
            for _ in 0..<itemsToRemove {
                Router.stack.removeLast()
                path.removeLast()
            }
            
            // Add the destination
            Router.stack.append(destination)
            path.append(destination)
        } else {
            // If destination isn't in the stack, simply append it
            Router.stack.append(destination)
            path.append(destination)
        }
        
        print("Navigated to \(destination). Routes stack: \(Router.stack.count)")
    }
    
    func createNewRoot(with destination: Destination) {
        // First append the destination for immediate navigation
        Router.stack.append(destination)
        path.append(destination)
        
        // Calculate how many items we need to remove
        let itemsToRemove = Router.stack.count - 1
        
        print("Router BEFORE new root:\n \(Router.stack)\n\(path)\n")
        // Remove all items between the old instance and the new one
        for _ in 0..<itemsToRemove {
            Router.stack.removeLast()
            path.removeLast()
        }
        print("Router AFTER new root:\n \(Router.stack)\n\(path)\n")
//        print("New root ccreated: \(destination).\nRoutes stack: \(Router.stack.count)\n ")
    }
    
}
