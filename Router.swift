//
//  Router.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 8.10.24.
//

import SwiftUI

@Observable
final class Router {
    
    // Singleton instance
    static let shared = Router()
    
    private init() {} // Prevents creating additional instances
    
    // Navigation destination views
    enum Destination: Codable, Hashable {
        //Home Views
        case home
        case play
        case quizView
        case topics
        
        case account
        case myProgress
        
        // Onboarding
        case welcome
        case registration
        case login
        case emailVerificationPending(email: String)
        case forgotPassword
        case resetPassword
        
//        //Register
//        case getEmail
//        case surveyView
//        case tryAQuizView
//        case createProfileView
//        case streakView
        // Add more destinations as needed
    }
    
    // The conxtext of view usage
    enum Context {
        case onboarding
        case login
        case settings
        case supabase
        case normal
    }
    
    // State variables
    var path = NavigationPath()
    
    // Internal navigation stack that mirrors the NavigationPath
    private var stack: [Destination] = []
    
    private var destinationContext: [Destination: Context] = [:]
    
    // Current view accessor with safety check
    var currentDestination: Destination? {
        stack.last
    }
    
    // MARK: - Navigation View Builder
    @ViewBuilder
    func view(for destination: Destination) -> some View {
        switch destination {
            //MARK: Onboarding - Registration & Login
        case .welcome:
            WelcomeView()
        case .login:
            LoginView()
        case .registration:
            RegistrationView()
        case .emailVerificationPending(email: let email):
            EmailVerificationPendingView(email: email)
        case .forgotPassword:
            ForgotPasswordView()
        case .resetPassword:
            ResetPasswordView()

    //TODO: For Advanced Onboarding...
//        case .getEmail:
//            GetEmailView()
//        case .surveyView:
//            SurveyView()
//        case .tryAQuizView:
//            LetsStartAQuizScreen()
//        case .createProfileView:
//            LetsCreateYourProfileScreen()
//            
//        case .streakView:
//            StreakView()
    //TODO: For Advanced Onboarding...
            
            //MARK: TabView Screens
        case .home:
            BTTabBar()
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
        case .myProgress:
            MyProgressView()
        }
    }
    
//    // MARK: - Navigation Path Change Handler
//    
//    /// Handle changes to the navigation path (such as from native back button)
//    /// This is critical for keeping our internal stack in sync
//    func handlePathChange() {
//        performOnMainThread {
//            // If the path is shorter than our stack, it means a back navigation occurred
//            if self.path.count < self.stack.count {
//                // Trim our stack to match the new path length
//                self.stack = Array(self.stack.prefix(self.path.count))
//                self.logNavigation("Native back navigation detected. Stack synced to path count: \(self.path.count)")
//            }
//        }
//    }
    
    // MARK: - Navigation Methods (Main Thread Safe)
    
    /// Navigate to a destination (main thread safe)
    /// - Parameter destination: The destination to navigate to
    /// - Parameter context: The context for that view. From where is the view opened from (what context)
    func navigateTo(_ destination: Destination, from context: Context = .normal) -> Void {
        performOnMainThread {
            self.destinationContext[destination] = context
            self.stack.append(destination)
            self.path.append(destination)
            self.logNavigation("✅ Navigated to \(destination), path count: \(self.path.count)")
        }
    }
    
    /// Navigate back one level (main thread safe)
    func popBackStack() {
        performOnMainThread {
            guard !self.stack.isEmpty, self.path.count > 0 else { return }
            
            let removedDestination = self.stack.removeLast()
            self.destinationContext.removeValue(forKey: removedDestination)
            self.path.removeLast()
            self.logNavigation("✅ Went back, path count: \(self.path.count)")
        }
    }
    
    /// Navigate back multiple levels (main thread safe)
    /// - Parameter count: Number of levels to go back
    func goBack(count: Int) {
        performOnMainThread {
            guard count > 0 else { return }
            
            let safeCount = min(count, self.stack.count)
            
            for _ in 0..<safeCount {
                
                let removedDestination = self.stack.removeLast()
                self.destinationContext.removeValue(forKey: removedDestination)
                
                if self.path.count > 0 {
                    self.path.removeLast()
                }
            }
            
            self.logNavigation("✅ Went back \(safeCount) levels, path count: \(self.path.count)")
        }
    }
    
    /// Navigate to root (main thread safe)
    func popToRoot() {
        performOnMainThread {
            guard !self.stack.isEmpty else { return }
            
            self.stack.removeAll()
            self.destinationContext.removeAll()
            if self.path.count > 0 {
                self.path.removeLast(self.path.count)
            }
            
            self.logNavigation("✅ Navigated to root, path count: \(self.path.count)")
        }
    }
    
    /// Navigate back to a specific destination (main thread safe)
    /// - Parameter destination: The destination to navigate back to
    func goBackTo(_ destination: Destination) {
        performOnMainThread {
            guard let index = self.stack.firstIndex(of: destination) else {
                self.logNavigation("❌Cannot go back to \(destination): not in stack")
                return
            }
            
            // Calculate how many items to remove
            let removeCount = self.stack.count - index - 1
            
            // Update the context
            if removeCount > 0 {
                let destinationsToRemove = Array(self.stack[(index + 1)...])
                
                for dest in destinationsToRemove {
                    self.destinationContext.removeValue(forKey: dest)
                }
            }
            
            // Update both stack and path
            self.stack = Array(self.stack.prefix(index + 1))
            
            if removeCount > 0 && self.path.count >= removeCount {
                for _ in 0..<removeCount {
                    self.path.removeLast()
                }
            }
            
            self.logNavigation("✅ Went back to \(destination), path count: \(self.path.count)")
        }
    }
    
    /// Navigate to a destination and clear the backstack (main thread safe)
    /// - Parameter destination: The destination to navigate to
    func navigateToAndClearBackstack(to destination: Destination, from context: Context = .normal) {
        performOnMainThread {
            // If we're already at this destination, do nothing
            guard self.currentDestination != destination else { return }
            
            // Check if the destination is already in the stack
            if let index = self.stack.firstIndex(of: destination) {
                
                // update the context
                let destinationsToRemove = Array(self.stack[(index + 1)...])
                for dest in destinationsToRemove {
                    self.destinationContext.removeValue(forKey: dest)
                }
                self.destinationContext[destination] = context
                
                
                
                // Keep only up to that destination
                self.stack = Array(self.stack.prefix(index + 1))
                
                // Sync the path
                let pathItemsToRemove = self.path.count - index - 1
                if pathItemsToRemove > 0 {
                    for _ in 0..<pathItemsToRemove {
                        self.path.removeLast()
                    }
                }
            } else {
                // If not in stack, add it
                self.destinationContext[destination] = context
                self.stack.append(destination)
                self.path.append(destination)
            }
            
            self.logNavigation("✅ Navigated to \(destination) and cleared backstack, path count: \(self.path.count)")
        }
    }
    
    /// Reset the navigation state (main thread safe)
    func reset() {
        performOnMainThread {
            self.destinationContext.removeAll()
            self.stack.removeAll()
            self.path = NavigationPath()
            self.logNavigation("Router reset")
        }
    }
    
    // Helpers for context
    func getContext(for destination: Destination) -> Context {
        return destinationContext[destination] ?? .normal
    }
    
    // Get source of current view
    func getCurrentContext() -> Context {
        guard let currentDestination = stack.last else {
            return .normal
        }
        return getContext(for: currentDestination)
    }
    
    // MARK: - Thread Safety
    
    /// Ensures the given block runs on the main thread
    /// - Parameter block: The code block to execute on the main thread
    private func performOnMainThread(_ block: @escaping () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            Task {
                await MainActor.run {
                    block()
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func logNavigation(_ message: String) {
        #if DEBUG
        print("🟠 Router: \(message)\n")
        #endif
    }
}


// MARK: - Router Access for NonViews
protocol RouterAccessible {
    var router: Router { get }
}

extension RouterAccessible {
    var router: Router {
        Router.shared
    }
}
