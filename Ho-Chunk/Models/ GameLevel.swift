import Foundation
import SwiftUI

struct GameLevel {
    let id: Int
    let regions: [RegionDefinition]
    
    // Определение региона для создания объекта Region
    struct RegionDefinition {
        let shape: ImageResource
        let position: CGPoint
        let width: CGFloat
        let height: CGFloat
        let owner: Player
        let initialTroops: Int
        
        // Конструктор с поддержкой обратной совместимости
        init(shape: ImageResource, position: CGPoint, width: CGFloat = 180, height: CGFloat = 180, owner: Player, initialTroops: Int) {
            self.shape = shape
            self.position = position
            self.width = width
            self.height = height
            self.owner = owner
            self.initialTroops = initialTroops
        }
    }
    
    // Предопределенные уровни
    static let levels: [GameLevel] = [
        // Уровень (обучающий)
        GameLevel(id: 1, regions: [
            // Регионы игрока (1)
            RegionDefinition(shape: .vector2, position: CGPoint(x: 256, y: 215), width: 180, height: 180, owner: .player, initialTroops: 0),

            // Нейтральные регионы (4)
            RegionDefinition(shape: .vector3, position: CGPoint(x: 345, y: 299), width: 160, height: 150, owner: .neutral, initialTroops: 0),
            RegionDefinition(shape: .vector4, position: CGPoint(x: 315, y: 138), width: 180, height: 170, owner: .neutral, initialTroops: 0),
            RegionDefinition(shape: .vector6, position: CGPoint(x: 439, y: 249), width: 150, height: 170, owner: .neutral, initialTroops: 0),
            RegionDefinition(shape: .vector7, position: CGPoint(x: 410, y: 125), width: 160, height: 160, owner: .neutral, initialTroops: 0),
        ]),
        
        // Уровень с 2 регионами
        GameLevel(id: 2, regions: [
            // Регионы CPU (1)
            RegionDefinition(shape: .vector1, position: CGPoint(x: 168, y: 326), width: 180, height: 180, owner: .cpu, initialTroops: 0),

            // Нейтральные регионы (9)
            RegionDefinition(shape: .vector2, position: CGPoint(x: 161, y: 197), width: 180, height: 180, owner: .neutral, initialTroops: 0),
            RegionDefinition(shape: .vector3, position: CGPoint(x: 268, y: 270), width: 150, height: 180, owner: .neutral, initialTroops: 0),
            RegionDefinition(shape: .vector4, position: CGPoint(x: 242, y: 117), width: 160, height: 160, owner: .neutral, initialTroops: 0),
            RegionDefinition(shape: .vector5, position: CGPoint(x: 387, y: 295), width: 180, height: 130, owner: .neutral, initialTroops: 0),
            RegionDefinition(shape: .vector6, position: CGPoint(x: 372, y: 209), width: 140, height: 150, owner: .neutral, initialTroops: 0),
            RegionDefinition(shape: .vector7, position: CGPoint(x: 343, y: 95), width: 140, height: 140, owner: .neutral, initialTroops: 0),
            RegionDefinition(shape: .vector9, position: CGPoint(x: 523, y: 216), width: 160, height: 120, owner: .neutral, initialTroops: 0),
            RegionDefinition(shape: .vector10, position: CGPoint(x: 481, y: 96), width: 110, height: 160, owner: .neutral, initialTroops: 0),
            
            // Регионы игрока (1)
            RegionDefinition(shape: .vector8, position: CGPoint(x: 526, y: 294), width: 170, height: 160, owner: .player, initialTroops: 0)
        ]),
        
        // Уровень 3
    ]
    
    // Получение уровня по ID
    static func getLevel(_ id: Int) -> GameLevel {
        return levels.first { $0.id == id } ?? levels[0]
    }
}
