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
    var keyboardType: UIKeyboardType = .default
    var contentType: UITextContentType = .name
    
    var body: some View {
        
        Group {
            TextField(placeholder, text: $value)
        }
                .padding()
                .background(backgroundColor)
                .clipShape(.rect(cornerRadius: 12))
                .overlay {
                    HStack {
                        Spacer()
                        
                        Image("Close")
                            .onTapGesture {
                                withAnimation {
                                    value.removeAll()
                                }
                            }
                            .padding()
                       
                    }
                }
                .keyboardType(keyboardType)
                .textContentType(contentType)
                .textInputAutocapitalization(.never)
    }
}
struct NewBTSecureField: View {
    @Binding var value: String
    var backgroundColor: Color = .BTStroke
    var placeholder: String = "Placeholder"
    
    @State private var imageIsTapped: Bool = false
    
    var body: some View {
        
        Group {
            if imageIsTapped {
                TextField(placeholder, text: $value)
            } else {
                SecureField(placeholder, text: $value)
            }
        }
        .padding()
        .background(backgroundColor)
        .clipShape(.rect(cornerRadius: 12))
        .overlay {
            HStack {
                Spacer()
                
                
                Image(systemName: imageIsTapped ? "eye" : "eye.slash")
                    .onTapGesture {
                        withAnimation {
                            imageIsTapped.toggle()
                        }
                    }
                    .padding()
            }
        }
    }
}

#Preview {
    @Previewable @State var text = ""
    NewBTSecureField(value: $text)
        .padding()
    
    NewBTTextField(value: $text)
        .padding()
}
