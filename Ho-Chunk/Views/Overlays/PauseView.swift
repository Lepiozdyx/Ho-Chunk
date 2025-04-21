
import SwiftUI

struct PauseView: View {
    @EnvironmentObject private var appViewModel: AppViewModel

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("PAUSED")
                    .customFont(40)
                
                Button {
                    appViewModel.resumeGame()
                } label: {
                    ActionView(width: 250, height: 120, text: "resume", textSize: 28)
                }
                
                Button {
                    appViewModel.goToMenu()
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
