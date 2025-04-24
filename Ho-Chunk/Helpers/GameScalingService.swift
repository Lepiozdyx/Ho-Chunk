
import SwiftUI

class GameScalingService: ObservableObject {
    static let shared = GameScalingService()
    
    // Базовый размер дизайна (iPhone 13 Pro в ландшафтном режиме)
    let baseWidth: CGFloat = 844
    let baseHeight: CGFloat = 390
    
    // Текущие настройки масштабирования
    @Published var scaleMultiplier: CGFloat = 1.0
    @Published var offsetX: CGFloat = 0
    @Published var offsetY: CGFloat = 0
    
    // Рассчитываем масштаб и смещение для текущего размера экрана
    func calculateScaling(for size: CGSize) {
        // Определяем коэффициенты масштабирования по ширине и высоте
        let widthScale = size.width / baseWidth
        let heightScale = size.height / baseHeight
        
        // Используем меньший коэффициент для сохранения пропорций
        scaleMultiplier = min(widthScale, heightScale)
        
        // Рассчитываем смещение для центрирования
        offsetX = (size.width - baseWidth * scaleMultiplier) / 2
        offsetY = (size.height - baseHeight * scaleMultiplier) / 2
    }
    
    // Преобразуем исходную позицию с учетом масштаба и смещения
    func scaledPosition(_ originalPosition: CGPoint) -> CGPoint {
        return CGPoint(
            x: originalPosition.x * scaleMultiplier + offsetX,
            y: originalPosition.y * scaleMultiplier + offsetY
        )
    }
    
    // Масштабирует размер
    func scaledSize(_ originalSize: CGFloat) -> CGFloat {
        return originalSize * scaleMultiplier
    }
}
