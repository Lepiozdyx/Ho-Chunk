
import SwiftUI

struct LoadingView: View {
    @State private var isPulsing = false
    
    var body: some View {
        ZStack {
            BgView(name: .desertBg)
            
            VStack {
                Spacer()
                
                Text("Loading...")
                    .customFont(40, color: .white)
                    .scaleEffect(isPulsing ? 1.04 : 0.9)
                    .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: isPulsing)
                    .onAppear {
                        isPulsing = true
                    }
            }
            .padding(.bottom)
        }
    }
}

#Preview {
    LoadingView()
}
