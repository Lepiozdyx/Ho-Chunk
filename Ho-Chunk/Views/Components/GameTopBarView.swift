
import SwiftUI

struct GameTopBarView: View {
    let playerControlPercentage: Double
    
    var body: some View {
        // Двухцветная шкала противоборства
        HStack(spacing: 0) {
            Rectangle()
                .fill(Color.blue)
                .frame(width: 300 * CGFloat(playerControlPercentage))
            
            Rectangle()
                .fill(Color.red)
                .frame(width: 300 * CGFloat(1 - playerControlPercentage))
        }
        .frame(height: 15)
        .clipShape(Capsule())
        .padding(.top, 8)
    }
}

#Preview {
    GameTopBarView(playerControlPercentage: 0.6)
}
