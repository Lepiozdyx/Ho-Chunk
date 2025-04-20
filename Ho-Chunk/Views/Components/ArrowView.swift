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
            
            // Ширина основания треугольника
            let baseWidth: CGFloat = 40
            
            // Вычисляем точки треугольника
            // Вершина треугольника - это конечная точка
            let tip = end
            
            // Вычисляем направление, перпендикулярное вектору движения (поворот на 90 градусов)
            let perpX = -dirY
            let perpY = dirX
            
            // Две точки, формирующие основание треугольника
            // Они расположены в начальной точке, смещены перпендикулярно на половину baseWidth
            let base1 = CGPoint(
                x: start.x + perpX * baseWidth / 2,
                y: start.y + perpY * baseWidth / 2
            )
            
            let base2 = CGPoint(
                x: start.x - perpX * baseWidth / 2,
                y: start.y - perpY * baseWidth / 2
            )
            
            // Рисуем треугольник
            var path = Path()
            path.move(to: base1)
            path.addLine(to: tip)
            path.addLine(to: base2)
            path.closeSubpath()
            
            // Заливаем треугольник цветом
            context.fill(path, with: .color(color))
            
            // Добавляем обводку для более четкого вида
            context.stroke(path, with: .color(color.opacity(0.8)), lineWidth: 1.5)
        }
    }
}

#Preview {
    ArrowView(start: CGPoint(x: 100, y: 100), end: CGPoint(x: 200, y: 200), color: .blue)
}
