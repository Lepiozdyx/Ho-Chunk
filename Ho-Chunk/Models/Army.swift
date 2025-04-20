import Foundation

struct Army: Identifiable {
    let id = UUID()
    let owner: Player
    let count: Int
    let fromRegion: Region
    let toRegion: Region
    let startTime: Date
    
    // Задаем более длительную анимацию для лучшей видимости
    var travelDuration: TimeInterval {
        return 1.5 // Увеличиваем с 1.0 до 1.5 секунд
    }
    
    // Этот метод больше не используется активно, но оставлен для обратной совместимости
    func currentPosition(at currentTime: Date) -> CGPoint {
        let elapsedTime = currentTime.timeIntervalSince(startTime)
        let progress = min(elapsedTime / travelDuration, 1.0)
        
        return CGPoint(
            x: fromRegion.position.x + (toRegion.position.x - fromRegion.position.x) * CGFloat(progress),
            y: fromRegion.position.y + (toRegion.position.y - fromRegion.position.y) * CGFloat(progress)
        )
    }
    
    // Проверяем, прибыла ли армия в пункт назначения
    func hasArrived(at currentTime: Date) -> Bool {
        return currentTime.timeIntervalSince(startTime) >= travelDuration
    }
}
