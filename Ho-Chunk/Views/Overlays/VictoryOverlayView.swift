import SwiftUI

struct VictoryOverlayView: View {
    
    @State private var showCoinAnimation: Bool = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("VICTORY!")
                    .customFont(60)
                    .foregroundColor(.yellow)
                    .shadow(color: .orange, radius: 10)
                
                Text("+50 COINS")
                    .customFont(36)
                    .foregroundColor(.yellow)
                    .scaleEffect(showCoinAnimation ? 1.2 : 1.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: showCoinAnimation)
                
                Spacer()
                    .frame(height: 30)
                
                Button {
                    // Обрабатываем победу и начинаем следующий уровень
                    
                } label: {
                    ActionView(width: 300, height: 150, text: "continue", textSize: 32)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button {
                    // Обрабатываем победу и возвращаемся в меню
                    
                } label: {
                    ActionView(width: 250, height: 120, text: "go to menu", textSize: 28)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .onAppear {
            // Анимации при появлении
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    showCoinAnimation = true
                }
            }
            
            // Через некоторое время возвращаем к исходному размеру
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    showCoinAnimation = false
                }
            }
        }
    }
}

#Preview {
    VictoryOverlayView()
}
