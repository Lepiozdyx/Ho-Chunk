//
//  RegionView.swift
//  Ho-Chunk
//
//  Created by Alex on 18.04.2025.
//

import SwiftUI

struct RegionView: View {
    let name: ImageResource
    let size: CGFloat
    let fractionLogo: ImageResource
    let fractionColor: Color
    let amount: Int
    
    var body: some View {
        Image(name)
            .resizable()
            .scaledToFit()
            .colorMultiply(fractionColor)
            .frame(width: size)
            .shadow(color: .black, radius: 2)
            .overlay {
                VStack {
                    Image(fractionLogo)
                        .resizable()
                        .frame(width: 20, height: 20)
                    
                    Text("\(amount)")
                        .customFont(16)
                }
            }
    }
}

#Preview {
    RegionView(name: .vector1, size: 250, fractionLogo: .targetLogo, fractionColor: .gray, amount: 45)
}
