//
//  ActionView.swift
//  Ho-Chunk
//
//  Created by Alex on 18.04.2025.
//

import SwiftUI

struct ActionView: View {
    let width: CGFloat
    let height: CGFloat
    let text: String
    let textSize: CGFloat
    var isQuill: Bool = false
    
    var body: some View {
        ZStack(alignment: .trailing) {
            Image(.button)
                .resizable()
                .frame(maxWidth: width, maxHeight: height)
                .overlay {
                    Text(text)
                        .customFont(textSize)
                        .offset(y: -7)
                }
            
            if isQuill {
                Image(.quill)
                    .resizable()
                    .frame(width: 100, height: 100)
                    .offset(x: 25)
            }
        }
            
    }
}

#Preview {
    ActionView(width: 250, height: 120, text: "start", textSize: 32)
}
