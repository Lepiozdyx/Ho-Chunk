
import SwiftUI

struct PauseView: View {
    @ObservedObject var gameViewModel: GameViewModel
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Text("PAUSED")
                    .customFont(40)
                
                Button {
                    gameViewModel.resumeGame()
                } label: {
                    ActionView(width: 250, height: 120, text: "resume", textSize: 28)
                }
                
                Button {
                    gameViewModel.navigateToMenu()
                } label: {
                    ActionView(width: 250, height: 120, text: "go to menu", textSize: 28)
                }
            }
        }
    }
}

#Preview {
    PauseView(gameViewModel: GameViewModel())
}
