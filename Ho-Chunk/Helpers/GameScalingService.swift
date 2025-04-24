
import SwiftUI

class GameScalingService: ObservableObject {
    static let shared = GameScalingService()
    
    let baseWidth: CGFloat = 844
    let baseHeight: CGFloat = 390
    
    @Published var scaleMultiplier: CGFloat = 1.0
    @Published var offsetX: CGFloat = 0
    @Published var offsetY: CGFloat = 0
    
    func calculateScaling(for size: CGSize) {
        let widthScale = size.width / baseWidth
        let heightScale = size.height / baseHeight
        
        scaleMultiplier = min(widthScale, heightScale)
        
        offsetX = (size.width - baseWidth * scaleMultiplier) / 2
        offsetY = (size.height - baseHeight * scaleMultiplier) / 2
    }
    
    func scaledPosition(_ originalPosition: CGPoint) -> CGPoint {
        return CGPoint(
            x: originalPosition.x * scaleMultiplier + offsetX,
            y: originalPosition.y * scaleMultiplier + offsetY
        )
    }
    
    func scaledSize(_ originalSize: CGFloat) -> CGFloat {
        return originalSize * scaleMultiplier
    }
}
