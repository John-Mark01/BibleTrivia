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
                        .applyFont(.semiBold, size: 18, textColor: .white)
                }
                
                
                Text("Currently you don’t have any active Quiz")
                    .multilineTextAlignment(.leading)
                    .applyFont(.regular, size: 15, textColor: .white)
                
                Spacer()
                
                Text("Start Quiz")
                    .applyFont(.medium, size: 14, textColor: .btPrimary)
                    .foregroundStyle(.btPrimary)
                    .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.white)
                    }
                    .makeButton(action: {})
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
                .fill(.btSecondary.gradient)
        )
    }
}
