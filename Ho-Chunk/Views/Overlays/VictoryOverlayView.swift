
import SwiftUI

struct VictoryOverlayView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @State private var showCoinAnimation: Bool = false
    @State private var showNextButton: Bool = false
    @State private var showMenuButton: Bool = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            HStack {
                Image(.indian)
                    .resizable()
                    .scaledToFit()
                    .offset(y: 16)
                
                Spacer()
            }
            
            VStack(spacing: 10) {
                Image(.textUnderlay)
                    .resizable()
                    .frame(width: 300, height: 80)
                    .overlay {
                        Text("VICTORY")
                            .customFont(42)
                    }
                
                Image(.coinCounter)
                    .resizable()
                    .frame(width: 170, height: 55)
                    .overlay {
                        Text("+50")
                            .customFont(22)
                            .scaleEffect(showCoinAnimation ? 1.1 : 0.9)
                            .animation(.spring(response: 0.4, dampingFraction: 0.3), value: showCoinAnimation)
                            .offset(x: 10, y: 3)
                    }
                
                Button {
                    appViewModel.goToNextLevel()
                } label: {
                    ActionView(width: 250, height: 150, text: "continue", textSize: 28)
                }
                .opacity(showNextButton ? 1 : 0)
                .offset(y: showNextButton ? 0 : 20)
                .buttonStyle(.plain)
                
                Button {
                    appViewModel.goToMenu()
                } label: {
                    ActionView(width: 250, height: 150, text: "menu", textSize: 28)
                }
                .opacity(showMenuButton ? 1 : 0)
                .offset(y: showMenuButton ? 0 : 20)
                .buttonStyle(.plain)
            }
            .padding()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    showCoinAnimation = true
                    showNextButton = true
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation {
                    showCoinAnimation = false
                    showMenuButton = true
                }
            }
        }
    }
}

#Preview {
    VictoryOverlayView()
}
