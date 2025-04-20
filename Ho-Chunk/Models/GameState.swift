
import Foundation

struct GameState: Codable {
    var regions: [UUID: RegionModel]
    var activeTransfers: [UUID: ArmyTransfer]
    var gameLevel: Int
    var isPaused: Bool
    var playerControlPercentage: Double
    var lastUpdateTime: Date
    
    // Добавим явные флаги условий победы/поражения
    var isPlayerVictory: Bool
    var isPlayerDefeat: Bool
    
    // Инициализатор по умолчанию
    init() {
        self.regions = [:]
        self.activeTransfers = [:]
        self.gameLevel = 1
        self.isPaused = false
        self.playerControlPercentage = 0.0
        self.lastUpdateTime = Date()
        self.isPlayerVictory = false
        self.isPlayerDefeat = false
    }
    
    // Вычисление процента областей под контролем игрока
    mutating func calculatePlayerControlPercentage() {
        let totalRegions = regions.count
        guard totalRegions > 0 else {
            playerControlPercentage = 0.0
            return
        }
        
        let playerRegions = regions.values.filter { $0.owner == .player }.count
        playerControlPercentage = Double(playerRegions) / Double(totalRegions)
    }
    
    // Проверка условия победы - все регионы принадлежат игроку
    var playerVictoryCondition: Bool {
        return regions.values.allSatisfy { $0.owner == .player }
    }
    
    // Проверка условия поражения - у игрока не осталось регионов
    var playerDefeatCondition: Bool {
        return !regions.values.contains { $0.owner == .player }
    }
}
