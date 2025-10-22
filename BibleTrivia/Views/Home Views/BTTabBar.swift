//
//  BTTabBar.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on [Date]
//

import SwiftUI

struct BTTabBar: View {
    @Environment(\.tabBarManager) private var tabBarManager
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedTab: Int = 0
    
    private var shadowColor: Color {
        colorScheme == .light ? .black : .clear
    }
    
    var body: some View {
        ZStack {
            // Content area
            TabContentView(selectedTab: selectedTab)
            
            VStack {
                Spacer()
                
                // Custom TabBar positioned at bottom
                VStack {
                    Spacer()
                    HStack {
                        // Home Tab
                        TabBarItem(
                            icon: "home",
                            title: "Home",
                            isSelected: selectedTab == 0,
                            action: { selectedTab = 0 }
                        )
                        
                        Spacer()
                        
                        // Play Tab
                        TabBarItem(
                            icon: "play",
                            title: "Play",
                            isSelected: selectedTab == 1,
                            action: { selectedTab = 1 }
                        )
                        
                        Spacer()
                        
                        // Topics Tab
                        TabBarItem(
                            icon: "topic",
                            title: "Topics",
                            isSelected: selectedTab == 2,
                            action: { selectedTab = 2 }
                        )
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 16)
                    .padding(.bottom, 16)
                    .background(
                        // Enhanced background with gradient
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.btBackground, .btBackground.opacity(0.95)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    )
                    .cornerRadius(16)
                    .shadow(
                        color: shadowColor.opacity(0.1),
                        radius: 8,
                        x: 0,
                        y: -5
                    )
                    .overlay(
                        // Subtle top highlight
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [.btBackground.opacity(0.8), .clear]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 1
                            )
                    )
                }
                .blur(radius: tabBarManager.isBlurred ? 3 : 0)
                .disabled(tabBarManager.isBlurred)
                .animation(.easeInOut(duration: 0.3), value: tabBarManager.isBlurred)
            }
            .ignoresSafeArea(.all)
        }
    }
}

struct TabBarItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(icon)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(isSelected ? .btPrimary : .gray)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundStyle(isSelected ? .btPrimary : .gray)
                
                // Enhanced underline indicator
                RoundedRectangle(cornerRadius: 2)
                    .frame(width: isSelected ? 50 : 0, height: 3)
                    .foregroundStyle(.btPrimary)
                    .shadow(
                        color: isSelected ? .btPrimary.opacity(0.3) : .clear,
                        radius: 3,
                        x: 0,
                        y: 1
                    )
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .offset(y: isSelected ? -6 : 0)
        }
        .frame(width: 80)
        .buttonStyle(PlainButtonStyle())
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

struct TabContentView: View {
    let selectedTab: Int
    
    var body: some View {
        Group {
            switch selectedTab {
            case 0:
                HomeView()
            case 1:
                PlayView()
            case 2:
                TopicsView()
            default:
                HomeView()
            }
        }
    }
}

#Preview {
    PreviewEnvironmentView {
        BTTabBar()
    }
}
