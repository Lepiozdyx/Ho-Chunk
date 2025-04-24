
import SwiftUI

extension Text {
    func customFont(_ size: CGFloat, color: Color = .coffemilk) -> some View {
        self
            .font(.system(size: size, weight: .heavy, design: .rounded))
            .foregroundStyle(color)
            .shadow(color: .black, radius: 0.5)
            .multilineTextAlignment(.center)
            .textCase(.uppercase)
    }
}
