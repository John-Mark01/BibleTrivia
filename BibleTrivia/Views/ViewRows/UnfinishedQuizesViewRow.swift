//
//  UnfinishedQuizesViewRow.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 11.10.24.
//

import SwiftUI

struct UnfinishedQuizesViewRow: View {
    @State var quizes = []
    var body: some View {
        VStack(alignment: .leading) {
            Text("Unfinished Quizes")
                .modifier(CustomText(size: 16, font: .heading))
            
            ScrollView(.horizontal) {
                HStack(spacing: 20) {
                    ForEach(1..<5) { _ in
                        QuizSquareView()
                    }
                }
            }
            .padding()
        }
        .padding(.vertical, Constants.vPadding)
    }
}

#Preview {
    UnfinishedQuizesViewRow()
}
