
import SwiftUI

struct DefeatOverlayView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @State private var showRetryButton: Bool = false
    @State private var showMenuButton: Bool = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("DEFEAT!")
                    .customFont(60)
                    .foregroundColor(.red)
                    .shadow(color: .black, radius: 5)
                
                Spacer()
                    .frame(height: 40)
                
                Button {
                    // Перезапускаем текущий уровень
                    appViewModel.startGame(level: appViewModel.gameLevel)
                } label: {
                    ActionView(width: 300, height: 150, text: "try again", textSize: 32)
                }
                .buttonStyle(PlainButtonStyle())
                .opacity(showRetryButton ? 1 : 0)
                .offset(y: showRetryButton ? 0 : 20)
                
                Button {
                    appViewModel.goToMenu()
                } label: {
                    ActionView(width: 250, height: 120, text: "go to menu", textSize: 28)
                }
                .buttonStyle(PlainButtonStyle())
                .opacity(showMenuButton ? 1 : 0)
                .offset(y: showMenuButton ? 0 : 20)
            }
        }
        .onAppear {
            // Анимированное появление кнопок
            withAnimation(.easeOut(duration: 0.4).delay(0.5)) {
                showRetryButton = true
            }
            
            withAnimation(.easeOut(duration: 0.4).delay(0.8)) {
                showMenuButton = true
            }
        }
    }
}

#Preview {
    DefeatOverlayView()
}
