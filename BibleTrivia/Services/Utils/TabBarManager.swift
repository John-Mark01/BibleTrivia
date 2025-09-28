//
//  TabBarManager.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on [Date]
//

import Foundation
import SwiftUI


@Observable class TabBarManager {
    var isBlurred: Bool = false
}

// Environment key for TabBarManager
struct TabBarManagerKey: EnvironmentKey {
    static let defaultValue = TabBarManager()
}

extension EnvironmentValues {
    var tabBarManager: TabBarManager {
        get { self[TabBarManagerKey.self] }
        set { self[TabBarManagerKey.self] = newValue }
    }
}

// View modifier for TabBar blur control
struct TabBarBlurModifier: ViewModifier {
    let isBlurred: Bool
    @Environment(\.tabBarManager) private var tabBarManager
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                tabBarManager.isBlurred = isBlurred
            }
            .onChange(of: isBlurred) { _, newValue in
                tabBarManager.isBlurred = newValue
            }
    }
}

extension View {
    func blurTabBar(_ isBlurred: Bool) -> some View {
        modifier(TabBarBlurModifier(isBlurred: isBlurred))
    }
} 
