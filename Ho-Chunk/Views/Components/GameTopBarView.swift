
import SwiftUI

struct GameTopBarView: View {
    let playerControlPercentage: Double
    
    var body: some View {
        HStack {
            Spacer()
            
            // Индикатор прогресса контроля территорий
            ZStack(alignment: .leading) {
                // Фон
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 300, height: 20)
                    .clipShape(Capsule())
                
                // Двухцветная шкала противоборства
                HStack(spacing: 0) {
                    // Часть игрока (синяя)
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: 300 * CGFloat(playerControlPercentage))
                    
                    // Часть CPU (красная)
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: 300 * CGFloat(1 - playerControlPercentage))
                }
                .frame(height: 20)
                .clipShape(Capsule())
            }
            
            Spacer()
        }
        .padding(.top)
    }
}

#Preview {
    GameTopBarView(playerControlPercentage: 0.6)
}
