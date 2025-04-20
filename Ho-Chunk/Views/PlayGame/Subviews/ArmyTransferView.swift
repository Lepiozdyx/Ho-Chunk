
import SwiftUI

struct ArmyTransferView: View {
    let from: CGPoint
    let to: CGPoint
    let progress: Double
    let count: Int
    let fromRegionId: UUID
    let regions: [RegionModel]
    
    private var color: Color {
        if let fromRegion = regions.first(where: { $0.id == fromRegionId }) {
            return fromRegion.owner.color
        }
        return .gray
    }
    
    private var bezierPath: (start: CGPoint, control: CGPoint, end: CGPoint) {
        let midX = (from.x + to.x) / 2
        let midY = (from.y + to.y) / 2
        
        let distance = sqrt(pow(to.x - from.x, 2) + pow(to.y - from.y, 2))
        let offsetMagnitude = distance / 4
        
        let dx = to.x - from.x
        let dy = to.y - from.y
        
        let length = sqrt(dx * dx + dy * dy)
        let normalizedPerpendicular = CGPoint(x: -dy / length, y: dx / length)
        
        let controlPoint = CGPoint(
            x: midX + normalizedPerpendicular.x * offsetMagnitude,
            y: midY + normalizedPerpendicular.y * offsetMagnitude
        )
        
        return (from, controlPoint, to)
    }
    
    private var position: CGPoint {
        let path = bezierPath
        let t = CGFloat(progress)
        
        // Формула квадратичной кривой Безье: B(t) = (1-t)²P₀ + 2(1-t)tP₁ + t²P₂
        let x = pow(1-t, 2) * path.start.x + 2 * (1-t) * t * path.control.x + pow(t, 2) * path.end.x
        let y = pow(1-t, 2) * path.start.y + 2 * (1-t) * t * path.control.y + pow(t, 2) * path.end.y
        
        return CGPoint(x: x, y: y)
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: 30, height: 30)
            
            Text("\(count)")
                .customFont(14)
        }
        .position(position)
    }
}

#Preview {
    let previewRegions: [RegionModel] = [
        // Имитируем регионы для превью
        RegionModel(
            id: UUID(),
            position: CGPoint(x: 150, y: 150),
            size: 120,
            shape: .vector1,
            owner: .player,
            troopCount: 15
        ),
        RegionModel(
            id: UUID(),
            position: CGPoint(x: 350, y: 250),
            size: 110,
            shape: .vector2,
            owner: .neutral,
            troopCount: 5
        )
    ]
    
    // Создаем идентификатор для использования в ArmyTransferView
    let fromRegionId = previewRegions[0].id
    
    return ZStack {
        // Точки начала и конца трансфера для превью
        Circle()
            .fill(Color.blue.opacity(0.5))
            .frame(width: 20, height: 20)
            .position(CGPoint(x: 150, y: 150))
        
        Circle()
            .fill(Color.red.opacity(0.5))
            .frame(width: 20, height: 20)
            .position(CGPoint(x: 350, y: 250))
            
        // Демонстрация трёх состояний перемещения войск
        ArmyTransferView(
            from: CGPoint(x: 150, y: 150),
            to: CGPoint(x: 350, y: 250),
            progress: 0.2, // В начале пути
            count: 8,
            fromRegionId: fromRegionId,
            regions: previewRegions
        )
        
        ArmyTransferView(
            from: CGPoint(x: 150, y: 150),
            to: CGPoint(x: 350, y: 250),
            progress: 0.5, // В середине пути
            count: 12,
            fromRegionId: fromRegionId,
            regions: previewRegions
        )
        
        ArmyTransferView(
            from: CGPoint(x: 150, y: 150),
            to: CGPoint(x: 350, y: 250),
            progress: 0.8, // Приближается к цели
            count: 6,
            fromRegionId: fromRegionId,
            regions: previewRegions
        )
    }
    .frame(width: 500, height: 400)
}
