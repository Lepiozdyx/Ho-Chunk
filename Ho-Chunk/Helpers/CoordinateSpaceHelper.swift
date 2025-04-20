
import SwiftUI

struct CoordinateSpaceHelper {
    // Константы для масштабирования
    static let designWidth: CGFloat = 800  // Ширина макета дизайна
    static let designHeight: CGFloat = 600 // Высота макета дизайна
    
    // Преобразование позиции из пространства дизайна в реальное пространство экрана
    static func scalePosition(_ position: CGPoint, for screenSize: CGSize) -> CGPoint {
        let scaleX = screenSize.width / designWidth
        let scaleY = screenSize.height / designHeight
        
        return CGPoint(
            x: position.x * scaleX,
            y: position.y * scaleY
        )
    }
    
    // Преобразование размера из пространства дизайна в реальное пространство экрана
    static func scaleSize(_ size: CGFloat, for screenSize: CGSize) -> CGFloat {
        // Используем среднее между масштабом по X и Y для сохранения пропорций
        let scaleX = screenSize.width / designWidth
        let scaleY = screenSize.height / designHeight
        let scale = min(scaleX, scaleY) // Используем min для предотвращения обрезки
        
        return size * scale
    }
    
    // Преобразование позиции из реального пространства экрана в пространство дизайна
    static func unscalePosition(_ position: CGPoint, for screenSize: CGSize) -> CGPoint {
        let scaleX = designWidth / screenSize.width
        let scaleY = designHeight / screenSize.height
        
        return CGPoint(
            x: position.x * scaleX,
            y: position.y * scaleY
        )
    }
    
    // Проверка, находится ли точка внутри региона
    // Это простая проверка по расстоянию, для продвинутой проверки нужно использовать
    // более сложную логику с учетом формы региона
    static func isPointInRegion(point: CGPoint, region: RegionModel, screenSize: CGSize) -> Bool {
        let scaledPosition = scalePosition(region.position, for: screenSize)
        let scaledSize = scaleSize(region.size, for: screenSize)
        
        // Расчет квадрата расстояния между точкой и центром региона
        let dx = point.x - scaledPosition.x
        let dy = point.y - scaledPosition.y
        let distanceSquared = dx * dx + dy * dy
        
        // Радиус региона (половина размера)
        let radiusSquared = (scaledSize / 2) * (scaledSize / 2)
        
        // Если квадрат расстояния меньше квадрата радиуса, точка внутри региона
        return distanceSquared <= radiusSquared
    }
}
