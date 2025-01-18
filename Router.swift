//
//  Router.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 8.10.24.
//

import SwiftUI

@MainActor
class Router: ObservableObject {
    
    static var shared = Router()
    
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
        guard path.count > 1 else { return }
        
        Router.stack.removeLast()
        path.removeLast()
        print("Navigated back. Routes stack: \(Router.stack.count)")
    }
    
    public func navigateToRoot() {
        Router.stack.removeAll()
        path.removeLast(path.count)
    }
    
    func navigateAndCalearBackStack(to destination: Destination) {
        if let index = Router.stack.lastIndex(of: destination) {
            while Router.stack.count != index {
                Router.stack.removeLast()
                path.removeLast()
            }
            Router.stack.append(destination)
            path.append(destination)
        } else {
            Router.stack.append(destination)
            path.append(destination)
            
            print("Navigated to \(destination) and cleared back stack. Routes stack: \(Router.stack.count)")
        }
    }
    
    private func handleBackNavigation(from oldPath: NavigationPath, to newPath: NavigationPath) {
        let removedCount = oldPath.count - path.count
        Router.stack.removeLast(removedCount)
        print("Navigated back. Routes stack: \(Router.stack.count)")
    }
}
