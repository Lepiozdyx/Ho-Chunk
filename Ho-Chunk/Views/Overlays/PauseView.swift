
import SwiftUI

struct PauseView: View {
    @EnvironmentObject private var appViewModel: AppViewModel

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 10) {
                Image(.textUnderlay)
                    .resizable()
                    .frame(width: 300, height: 80)
                    .overlay {
                        Text("PAUSED")
                            .customFont(42)
                    }
                
                Button {
                    appViewModel.resumeGame()
                } label: {
                    ActionView(width: 250, height: 150, text: "resume", textSize: 28)
                }
                
                Button {
                    appViewModel.goToMenu()
                } label: {
                    ActionView(width: 250, height: 150, text: "menu", textSize: 28)
                }
            }
            .padding()
        }
    }
}

#Preview {
    PauseView()
}
