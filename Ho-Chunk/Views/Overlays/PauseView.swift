
import SwiftUI

struct PauseView: View {

    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Text("PAUSED")
                    .customFont(40)
                
                Button {
                    
                } label: {
                    ActionView(width: 250, height: 120, text: "resume", textSize: 28)
                }
                
                Button {
                    
                } label: {
                    ActionView(width: 250, height: 120, text: "go to menu", textSize: 28)
                }
            }
        }
    }
}

#Preview {
    PauseView()
}
