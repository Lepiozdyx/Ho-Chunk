//
//  Text+Extension.swift
//  Ho-Chunk
//
//  Created by Alex on 18.04.2025.
//

import SwiftUI

struct Text_Extension: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .customFont(24)
    }
}

#Preview {
    Text_Extension()
}

extension Text {
    func customFont(_ size: CGFloat) -> some View {
        self
            .font(.system(size: size, weight: .heavy, design: .rounded))
            .foregroundStyle(.coffemilk)
            .shadow(color: .black, radius: 0.5)
            .multilineTextAlignment(.center)
            .textCase(.uppercase)
    }
}
