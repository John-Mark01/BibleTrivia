//
//  StreakView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 19.04.25.
//

import SwiftUI

struct StreakView: View {
    @Environment(Router.self) private var router
    @State private var currentDayIndex: Int = 0
    
    @State private var weekdays: [(week: String, completed: Bool)] = [
        ("M", true),
        ("T", false),
        ("W", false),
        ("Th", false),
        ("F", false),
        ("Sa", false),
        ("Su", false)
    ]
    
    var body: some View {
        
        VStack(spacing: 30) {
            
            Spacer()
            
            // Flame icon with number
            VStack(spacing: 0) {
                ZStack {
                    // Flame
                    Image(systemName: "flame.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 100)
                        .foregroundColor(Color(hex: "FF9C21"))
                        .overlay(
                            Image(systemName: "flame.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 50)
                                .foregroundColor(Color(hex: "FFCC33"))
                                .offset(y: -10)
                        )
                        .animation(.bouncy, value: currentDayIndex)
                    
                    // Number 1
                    Text("1")
                        .font(.system(size: 70, weight: .bold))
                        .foregroundColor(Color(hex: "1C2834"))
                        .offset(y: 35)
                }
                
                // Day streak text
                Text("day streak!")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(Color(hex: "FF9C21"))
                    .padding(.top, 20)
            }
            
            
            // Weekly calendar view
            VStack(spacing: 20) {
                HStack(spacing: 25) {
                    ForEach(0..<7) { index in
                        VStack(alignment: .center, spacing: 20) {
                            Text(weekdays[index].week)
                                .font(.system(size: 16))
                                .foregroundColor(index == currentDayIndex ? Color(hex: "FF9C21") : Color(hex: "5C6982"))
                            
                            DayCircleView(
                                isCompleted: weekdays[index].completed,
                                isCurrentDay: index == currentDayIndex
                            )
                            .animation(.bouncy, value: currentDayIndex)
                        }
                    }
                }
                
                Text("Your streak will reset if you don't come\n back the next day. Watch out!")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(hex: "1C2834"))
            )
            
            Spacer()
            
            // Bottom buttons
            OnboardButton(text: "Continue",
                          action: {
                router.navigateTo(.createProfileView)
            })
            
        }
        .navigationBarBackButtonHidden()
        .applyBackground()
        .applyViewPaddings()
        .onAppear(perform: updateTodayStatus)
    }
    
    func updateTodayStatus() {
        let calendar = Calendar.current
        let today = calendar.component(.weekday, from: Date())
        
        let mappedIndex: Int
        
        if today == 1 { // Sunday
            mappedIndex = 6  // Sunday is the last day in a Monday-first week
        } else {
            mappedIndex = today - 2  // Adjust for Monday being index 0
        }
        
        currentDayIndex = mappedIndex
   
        if mappedIndex >= 0 && mappedIndex < weekdays.count {
            weekdays[mappedIndex].completed = true
        }
    }
}

#Preview {
    PreviewEnvironmentView {
        StreakView()
    }
    .environment(Router.shared)
}


struct DayCircleView: View {
    
    var isCompleted: Bool
    var isCurrentDay: Bool
    
    var body: some View {
        ZStack {
            // Base circle
            Circle()
                .fill(isCompleted ? Color(hex: "FF9C21") : Color(hex: "2A3543"))
                .frame(width: 25, height: 25)
                .overlay(
                    Circle()
                        .stroke(isCurrentDay ? Color(hex: "FF9C21") : Color.clear, lineWidth: isCurrentDay ? 2 : 0)
                        .frame(width: 30, height: 30)
                )
            
            // Checkmark
            if isCompleted {
                Image(systemName: "checkmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
            }
        }
    }
}
