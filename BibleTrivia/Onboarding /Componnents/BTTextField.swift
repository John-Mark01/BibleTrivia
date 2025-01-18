//
//  BTTextField.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 18.01.25.
//

import SwiftUI

struct NewBTTextField: View {
    @Binding var value: String
    var backgroundColor: Color = .BTStroke
    var placeholder: String = "Placeholder"
    
    
    var body: some View {
        
        TextField(placeholder, text: $value)
                .padding()
                .background(backgroundColor)
                .clipShape(.rect(cornerRadius: 12))
                .overlay {
                    HStack {
                        Spacer()
                        
                        Button("", image: .close, action: { value.removeAll() })
                       
                    }
                }
    }
}

#Preview {
    @Previewable @State var text = ""
    NewBTTextField(value: $text)
        .padding()
}
