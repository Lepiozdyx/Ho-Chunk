import SwiftUI

struct ArmyView: View {
    let army: Army
    
    // Используем более надежный способ анимации через состояние
    @State private var progress: Double = 0
    
    var body: some View {
        Text("\(army.count)")
            .customFont(24)
            .padding(10)
            .background(
                Circle()
                    .fill(army.owner.color)
                    .shadow(radius: 3)
            )
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
        
        // Добавляем дугу для более естественного движения
        let midX = (startX + endX) / 2
        let midY = (startY + endY) / 2 - 40 // Смещаем вверх для создания дуги
        
        // Квадратичная интерполяция для создания кривой Безье
        if progress <= 0.5 {
            // Первая половина пути: от начала к средней точке
            let t = progress * 2
            return CGPoint(
                x: (1-t) * (1-t) * startX + 2 * (1-t) * t * midX + t * t * endX,
                y: (1-t) * (1-t) * startY + 2 * (1-t) * t * midY + t * t * endY
            )
        } else {
            // Вторая половина пути: от средней точки к концу
            let t = (progress - 0.5) * 2
            return CGPoint(
                x: (1-t) * (1-t) * midX + 2 * (1-t) * t * endX + t * t * endX,
                y: (1-t) * (1-t) * midY + 2 * (1-t) * t * endY + t * t * endY
            )
        }
    }
}

#Preview {
    let region1 = Region(shape: .vector3, position: CGPoint(x: 200, y: 200), owner: .player)
    let region2 = Region(shape: .vector2, position: CGPoint(x: 400, y: 200), owner: .neutral)
    
    ArmyView(army: Army(owner: .player, count: 15, fromRegion: region1, toRegion: region2, startTime: Date()))
}
