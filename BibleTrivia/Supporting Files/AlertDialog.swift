//
//  AlertDialog.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 20.10.24.
//

import SwiftUI

struct AlertDialog: View {
    @Binding var isPresented: Bool
    let title: LocalizedStringResource
    let message: LocalizedStringResource
    let buttonTitle: LocalizedStringResource
    let primaryAction: () -> ()
    @State private var offset: CGFloat = 1000
    
    var body: some View {
        
        ZStack {
            Color(.black)
                .opacity(0.5)
                .onTapGesture { close() }
            VStack {
                Text(title)
                    .applyFont(.semiBold, size: 23)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Text(message)
                    .applyFont(.regular, size: 17)
                    .multilineTextAlignment(.center)
                
                
                ZStack {
                    RoundedRectangle(cornerRadius: 40)
                        .foregroundStyle(.btPrimary)
                        .makeButton(action: runAction, addHapticFeedback: true)
                    
                    Text(buttonTitle)
                        .applyFont(.medium, size: 20, textColor: .white)
                        .padding()
                }
                .padding()
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding()
            .background(.btBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay {
                VStack {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            close()
                        }) {
                            Image("Close")
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .shadow(radius: 20)
            .padding(30)
            .offset(x: 0, y: offset)
            .onAppear {
                withAnimation() {
                    offset = 0
                }
            }
        }
        .ignoresSafeArea()
    }
    
   private func close() {
        withAnimation() {
            offset = -1000
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                isPresented = false
            }
        }
    }
    
    private func runAction() {
        primaryAction()
        close()
    }
}

#Preview {
    AlertDialog(
        isPresented: .constant(true),
        title: "Quit Quiz?",
        message: "You can still finish you quiz later.",
        buttonTitle: "Continue",
        primaryAction: { print("This is a preview alert Action.") })
}
