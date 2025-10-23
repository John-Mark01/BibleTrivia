//
//  SectionTitle.swift
//  BibleTrivia
//
//  Created by John-Mark Iliev on 23.10.25.
//

import SwiftUI

struct SectionTitle: View {
    var title: LocalizedStringResource

    var buttonTitle: LocalizedStringResource?
    var buttonForeground: Color?
    
    var buttonImage: Image?
    var buttonImageDimentions: CGSize?
    var buttonAction: (() -> Void)?
    
    var body: some View {
        HStack {
            Text(title)
                .applyFont(.medium, size: 20)
            
            Spacer()
            
            if let action = buttonAction {
                Group {
                    if let buttonImage {
                        buttonImage
                            .resizable()
                            .frame(width: buttonImageDimentions?.width,
                                   height: buttonImageDimentions?.height)
                    }
                    
                    if let buttonTitle {
                        Text(buttonTitle)
                            .applyFont(.regular, size: 17, textColor: buttonForeground ?? .btBlack)
                    }
                }
                .makeButton(
                    action: action,
                    addHapticFeedback: true,
                    feedbackStyle: .selection
                )
            }
        }
    }
    
    func setTextButton(_ title: LocalizedStringResource, foregroundColor: Color = .btBlack, action: @escaping () -> Void) -> Self {
        var view = self
        view.buttonTitle = title
        view.buttonAction = action
        view.buttonForeground = foregroundColor
        
        return view
    }
    
    func setImageButton(_ image: Image, dimentions: CGSize, action: @escaping () -> Void) -> Self {
        var view = self
        view.buttonImage = image
        view.buttonImageDimentions = dimentions
        view.buttonAction = action
        
        return view
    }
}
