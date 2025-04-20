import SwiftUI

struct ArrowView: View {
    let start: CGPoint
    let end: CGPoint
    let color: Color
    
    var body: some View {
        Canvas { context, size in
            // Вычисляем вектор направления
            let dx = end.x - start.x
            let dy = end.y - start.y
            let length = sqrt(dx*dx + dy*dy)
            
            guard length > 0 else { return }
            
            // Нормализуем направление
            let dirX = dx / length
            let dirY = dy / length
            
            // Свойства наконечника стрелки
            let headLength: CGFloat = 20
            let headAngle: CGFloat = .pi / 4
            
            // Рисуем линию
            var path = Path()
            path.move(to: start)
            path.addLine(to: end)
            
            // Рисуем наконечник стрелки
            let headPt1 = CGPoint(
                x: end.x - headLength * cos(atan2(dirY, dirX) + headAngle),
                y: end.y - headLength * sin(atan2(dirY, dirX) + headAngle)
            )
            let headPt2 = CGPoint(
                x: end.x - headLength * cos(atan2(dirY, dirX) - headAngle),
                y: end.y - headLength * sin(atan2(dirY, dirX) - headAngle)
            )
            
            path.move(to: end)
            path.addLine(to: headPt1)
            path.move(to: end)
            path.addLine(to: headPt2)
            
            // Рисуем стрелку с цветом
            context.stroke(path, with: .color(color), lineWidth: 4)
        }
    }
}

#Preview {
    ArrowView(start: CGPoint(x: 100, y: 100), end: CGPoint(x: 200, y: 200), color: .blue)
}
