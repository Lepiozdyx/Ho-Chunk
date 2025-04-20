import SwiftUI

struct ArmyView: View {
    let army: Army
    
    @State private var progress: Double = 0
    
    var body: some View {
        ZStack {
            // Перемещаем весь ZStack как единое целое
            Circle()
                .fill(army.owner.color)
                .frame(width: 50, height: 50)
                .shadow(radius: 3)
            
            Text("\(army.count)")
                .customFont(24)
        }
        .position(calculatePosition())
        .onAppear {
            // Запускаем анимацию сразу при появлении
            withAnimation(.linear(duration: army.travelDuration)) {
                progress = 1.0
            }
        }
    }
    
    // Рассчитываем текущую позицию на основе прогресса анимации
    private func calculatePosition() -> CGPoint {
        let startX = army.fromRegion.position.x
        let startY = army.fromRegion.position.y
        let endX = army.toRegion.position.x
        let endY = army.toRegion.position.y
        
        // Линейная интерполяция для упрощения
        return CGPoint(
            x: startX + (endX - startX) * CGFloat(progress),
            y: startY + (endY - startY) * CGFloat(progress)
        )
    }
}

#Preview {
    let region1 = Region(shape: .vector3, position: CGPoint(x: 200, y: 200), owner: .player)
    let region2 = Region(shape: .vector2, position: CGPoint(x: 400, y: 200), owner: .neutral)
    
    ArmyView(army: Army(owner: .player, count: 15, fromRegion: region1, toRegion: region2, startTime: Date()))
}
