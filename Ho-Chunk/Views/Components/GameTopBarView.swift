import SwiftUI

struct GameTopBarView: View {
    
    let playerControlPercentage: Double
    @State private var animatedPercentage: Double = 0.5
    
    var body: some View {
        HStack(spacing: 0) {
            // Область игрока (синяя)
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.6), Color.blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 300 * CGFloat(animatedPercentage))
            
            // Область CPU (красная)
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.red.opacity(0.6), Color.red],
                        startPoint: .trailing,
                        endPoint: .leading
                    )
                )
                .frame(width: 300 * CGFloat(1 - animatedPercentage))
        }
        .frame(height: 15)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.black.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.8), radius: 3, x: 0, y: 1)
        .padding(.top, 8)
        .onChange(of: playerControlPercentage) { newValue in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                animatedPercentage = newValue
            }
        }
        .onAppear {
            // Устанавливаем начальное значение при появлении
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                animatedPercentage = playerControlPercentage
            }
        }
    }
}

#Preview {
    GameTopBarView(playerControlPercentage: 0.7)
}
