//
//  BTTabBar.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on [Date]
//

import SwiftUI

struct BTTabBar: View {
    @Environment(\.tabBarManager) private var tabBarManager
    @State private var selectedTab: Int = 0
    
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
                            action: {
                                withAnimation(.bouncy(duration: 0.7, extraBounce: 0.3)) {
                                    selectedTab = 0
                                }
                            }
                        )
                        
                        Spacer()
                        
                        // Play Tab
                        TabBarItem(
                            icon: "play",
                            title: "Play",
                            isSelected: selectedTab == 1,
                            action: { 
                                withAnimation(.bouncy(duration: 0.7, extraBounce: 0.3)) {
                                    selectedTab = 1
                                }
                            }
                        )
                        
                        Spacer()
                        
                        // Topics Tab
                        TabBarItem(
                            icon: "topic",
                            title: "Topics",
                            isSelected: selectedTab == 2,
                            action: { 
                                withAnimation(.bouncy(duration: 0.7, extraBounce: 0.3)) {
                                    selectedTab = 2
                                }
                            }
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
                                    gradient: Gradient(colors: [Color.white, Color.white.opacity(0.95)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    )
                    .cornerRadius(16)
                    .shadow(
                        color: Color.black.opacity(0.1),
                        radius: 8,
                        x: 0,
                        y: -5
                    )
                    .overlay(
                        // Subtle top highlight
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.white.opacity(0.8), Color.clear]),
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
                    .foregroundColor(isSelected ? Color.BTPrimary : Color.gray)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? Color.BTPrimary : Color.gray)
                
                // Enhanced underline indicator
                RoundedRectangle(cornerRadius: 2)
                    .frame(width: isSelected ? 50 : 0, height: 3)
                    .foregroundColor(Color.BTPrimary)
                    .shadow(
                        color: isSelected ? Color.BTPrimary.opacity(0.3) : Color.clear,
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
    RouterView {
        BTTabBar()
    }
    .environment(Router.shared)
    .environment(QuizStore(supabase: Supabase()))
    .environment(\.tabBarManager, TabBarManager())
}
