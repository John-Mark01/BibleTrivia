//
//  TopicViewRow.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 11.10.24.
//

import SwiftUI

struct QuizSquareView: View {
    @State var progress: Double = 0.6
    var body: some View {
        VStack(alignment: .leading) {
            Image("Book")
                .padding(.leading, 20)
                .padding()
            HStack {
                VStack {
                    Text("Gospel of John")
                        .modifier(CustomText(size: 16, font: .button))
                    Text("20 questions")
                        .modifier(CustomText(size: 10, font: .label))
                        .foregroundStyle(Color.BTLightGray)

                }
                Spacer()
                
                CircularProgressView(progress: progress)
                    .frame(width: 40, height: 40)
            }
            .padding(8)
        }
        .background(Color.BTBackground)
        .overlay(
            Rectangle()
                .stroke(Color.BTStroke, lineWidth: 1)
        )
    
    }
}

#Preview {
    QuizSquareView()
}
