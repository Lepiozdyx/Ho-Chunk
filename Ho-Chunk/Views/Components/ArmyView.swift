
import SwiftUI

struct ArmyView: View {
    let army: Army
    var scalingService: GameScalingService
    
    @State private var progress: Double = 0
    
    var body: some View {
        ZStack {
            Circle()
                .fill(army.owner.color)
                .frame(
                    width: scalingService.scaledSize(30),
                    height: scalingService.scaledSize(30)
                )
                .shadow(color: .black, radius: 2)
            
            Text("\(army.count)")
                .customFont(scalingService.scaledSize(16))
        }
        .position(calculatePosition())
        .onAppear {
            withAnimation(.linear(duration: army.travelDuration)) {
                progress = 1.0
            }
        }
    }
    
    private func calculatePosition() -> CGPoint {
        let startX = army.fromRegion.position.x
        let startY = army.fromRegion.position.y
        let endX = army.toRegion.position.x
        let endY = army.toRegion.position.y
        
        // Линейная интерполяция для текущего положения
        let currentX = startX + (endX - startX) * CGFloat(progress)
        let currentY = startY + (endY - startY) * CGFloat(progress)
        
        // Применяем масштабирование и смещение
        return scalingService.scaledPosition(CGPoint(x: currentX, y: currentY))
    }
}

#Preview {
    let region1 = Region(shape: .vector3, position: CGPoint(x: 200, y: 200), owner: .player)
    let region2 = Region(shape: .vector2, position: CGPoint(x: 400, y: 200), owner: .neutral)
    
    ArmyView(
        army: Army(owner: .player, count: 15, fromRegion: region1, toRegion: region2, startTime: Date()),
        scalingService: GameScalingService.shared
    )
}
