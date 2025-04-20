
import Foundation

struct ArmyTransfer: Identifiable, Codable {
    let id: UUID
    let fromRegionId: UUID
    let toRegionId: UUID
    let count: Int
    var progress: Double // 0.0 to 1.0
    let startTime: Date
    let estimatedArrivalTime: Date
    
    // Время путешествия войск в секундах
    static let travelTimeSeconds: Double = 2.0
    
    // Инициализатор для новой передачи войск
    init(fromRegionId: UUID, toRegionId: UUID, count: Int) {
        self.id = UUID()
        self.fromRegionId = fromRegionId
        self.toRegionId = toRegionId
        self.count = count
        self.startTime = Date()
        self.estimatedArrivalTime = Date().addingTimeInterval(ArmyTransfer.travelTimeSeconds)
        self.progress = 0.0
    }
    
    // Обновление прогресса на основе текущего времени
    mutating func updateProgress(currentTime: Date = Date()) {
        let totalDuration = estimatedArrivalTime.timeIntervalSince(startTime)
        let elapsedDuration = currentTime.timeIntervalSince(startTime)
        progress = min(elapsedDuration / totalDuration, 1.0)
    }
    
    // Проверка, завершена ли передача
    var isCompleted: Bool {
        return progress >= 1.0
    }
}
