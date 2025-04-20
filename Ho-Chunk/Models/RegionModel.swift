
import SwiftUI

struct RegionModel: Identifiable, Codable {
    let id: UUID
    let position: CGPoint
    let size: CGFloat
    let shape: RegionShape
    var owner: FractionType
    var troopCount: Int
    var lastUpdateTime: Date
    
    // Вычисляемое свойство для получения ImageResource
    var imageResource: ImageResource {
        return shape.imageResource
    }
    
    // Инициализатор
    init(id: UUID = UUID(), position: CGPoint, size: CGFloat, shape: RegionShape, owner: FractionType = .neutral, troopCount: Int = 0) {
        self.id = id
        self.position = position
        self.size = size
        self.shape = shape
        self.owner = owner
        self.troopCount = troopCount
        self.lastUpdateTime = Date()
    }
}
