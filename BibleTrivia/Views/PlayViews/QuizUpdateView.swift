//
//  QuizUpdateView.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 23.10.24.
//

import SwiftUI

struct QuizUpdateView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack(alignment: .center) {
                    Image("bible_mini")
                    
                    Text("Quiz Update")
                        .modifier(CustomText(size: 18, font: .semiBold))
                        .foregroundStyle(Color.white)
                }
                
                
                Text("Currently you don’t have any active Quiz")
                    .multilineTextAlignment(.leading)
                    .modifier(CustomText(size: 15, font: .regular))
                    .foregroundStyle(Color.white)
                
                Spacer()
                
                Button(action: {
                    
                }) {
                    Text("Start Quiz")
                        .modifier(CustomText(size: 14, font: .medium))
                        .foregroundStyle(Color.BTPrimary)
                        .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .background {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white)
                            
                        }
                }
            }
            .padding()
            
            VStack {
                Image("bible-study")
                    .resizable()
                    .frame(width: 150, height: 130)
                
            }
            .padding()
            
            
            
            Spacer()
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.BTSecondary.gradient)
        )
    }
}
