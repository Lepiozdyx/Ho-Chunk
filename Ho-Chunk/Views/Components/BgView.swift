
import SwiftUI

struct BgView: View {
    let name: ImageResource
    var isBlur: Bool = false
    var isMenu: Bool = false
    
    var body: some View {
        Image(name)
            .resizable()
            .ignoresSafeArea()
            .blur(radius: isBlur ? 10 : 0, opaque: true)
            .overlay {
                if isMenu {
                    HStack {
                        Image(.indian)
                            .resizable()
                            .scaledToFit()
                            .offset(y: 16)
                        
                        Spacer()
                    }
                }
            }
    }
}

#Preview {
    BgView(name: .desertBg)
}
