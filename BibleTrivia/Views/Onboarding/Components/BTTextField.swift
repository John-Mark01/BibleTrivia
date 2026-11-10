//
//  BTTextField.swift
//  BibleTrivia
//

import SwiftUI

struct BTTextField: View {
    @Binding var value: String
    var isFocused: FocusState<Bool>.Binding
    var placeholder: LocalizedStringKey = ""
    var keyboardType: UIKeyboardType = .default
    var contentType: UITextContentType? = nil
    var autocapitalization: TextInputAutocapitalization = .never
    var backgroundColor: Color = .btStroke

    var body: some View {
        TextField(placeholder, text: $value)
            .keyboardType(keyboardType)
            .textContentType(contentType)
            .textInputAutocapitalization(autocapitalization)
            .autocorrectionDisabled()
            .focused(isFocused)
            .padding()
            .padding(.trailing, 32)
            .background(backgroundColor)
            .clipShape(.rect(cornerRadius: 12))
            .overlay(alignment: .trailing) {
                if !value.isEmpty {
                    Button {
                        withAnimation { value.removeAll() }
                    } label: {
                        Image("Icon/close")
                    }
                    .padding()
                    .accessibilityLabel("Clear text")
                }
            }
    }
}

struct BTSecureField: View {
    @Binding var value: String
    var isFocused: FocusState<Bool>.Binding
    var placeholder: LocalizedStringKey = ""
    var contentType: UITextContentType = .password
    var backgroundColor: Color = .btStroke

    @State private var isRevealed = false

    var body: some View {
        Group {
            if isRevealed {
                TextField(placeholder, text: $value)
            } else {
                SecureField(placeholder, text: $value)
            }
        }
        .textContentType(contentType)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .focused(isFocused)
        .padding()
        .padding(.trailing, 32)
        .background(backgroundColor)
        .clipShape(.rect(cornerRadius: 12))
        .overlay(alignment: .trailing) {
            Button {
                withAnimation { isRevealed.toggle() }
            } label: {
                Image(systemName: isRevealed ? "eye" : "eye.slash")
                    .foregroundStyle(.btBlack)
            }
            .padding()
            .accessibilityLabel(isRevealed ? "Hide password" : "Show password")
        }
    }
}

#Preview {
    @Previewable @State var text = ""
    @Previewable @FocusState var focused: Bool
    VStack {
        BTTextField(value: $text, isFocused: $focused, placeholder: "email")
        BTSecureField(value: $text, isFocused: $focused, placeholder: "password")
    }
    .padding()
}
