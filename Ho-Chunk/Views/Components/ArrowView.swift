
import SwiftUI

struct ArrowView: View {
    let start: CGPoint
    let end: CGPoint
    let color: Color
    var scalingService: GameScalingService
    
    var body: some View {
        Canvas { context, size in
            // Масштабируем точки начала и конца
            let scaledStart = scalingService.scaledPosition(start)
            let scaledEnd = scalingService.scaledPosition(end)
            
            // Вычисляем вектор направления
            let dx = scaledEnd.x - scaledStart.x
            let dy = scaledEnd.y - scaledStart.y
            let length = sqrt(dx*dx + dy*dy)
            
            guard length > 0 else { return }
            
            // Нормализуем направление
            let dirX = dx / length
            let dirY = dy / length
            
            // Ширина основания треугольника (также масштабируем)
            let baseWidth: CGFloat = scalingService.scaledSize(40)
            
            // Вычисляем точки треугольника
            let tip = scaledEnd
            
            // Вычисляем направление, перпендикулярное вектору движения
            let perpX = -dirY
            let perpY = dirX
            
            // Две точки, формирующие основание треугольника
            let base1 = CGPoint(
                x: scaledStart.x + perpX * baseWidth / 2,
                y: scaledStart.y + perpY * baseWidth / 2
            )
            
            let base2 = CGPoint(
                x: scaledStart.x - perpX * baseWidth / 2,
                y: scaledStart.y - perpY * baseWidth / 2
            )
            
            // Треугольник
            var path = Path()
            path.move(to: base1)
            path.addLine(to: tip)
            path.addLine(to: base2)
            path.closeSubpath()
            
            context.fill(path, with: .color(color))
            context.stroke(path, with: .color(color.opacity(0.5)), lineWidth: 3)
        }
    }
}

#Preview {
    ArrowView(
        start: CGPoint(x: 100, y: 100),
        end: CGPoint(x: 200, y: 200),
        color: .blue,
        scalingService: GameScalingService.shared
    )
}
