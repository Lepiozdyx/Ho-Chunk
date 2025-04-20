
import SwiftUI

struct LevelConfiguration: Codable {
    let levelNumber: Int
    let regions: [RegionModel]
    let aiUpdateIntervalSeconds: Double
    
    // Фабричный метод для создания уровня 1 (обучающий)
    static func createLevel1() -> LevelConfiguration {
        let regions: [RegionModel] = [
            // Регион игрока
            RegionModel(
                position: CGPoint(x: 100, y: 300),
                size: 120,
                shape: .vector1,
                owner: .player,
                troopCount: 0
            ),
            
            // Регион CPU
            RegionModel(
                position: CGPoint(x: 600, y: 300),
                size: 120,
                shape: .vector10,
                owner: .cpu,
                troopCount: 0
            ),
            
            // Нейтральные регионы (8 штук)
            RegionModel(
                position: CGPoint(x: 200, y: 150),
                size: 100,
                shape: .vector2
            ),
            RegionModel(
                position: CGPoint(x: 300, y: 200),
                size: 110,
                shape: .vector3
            ),
            RegionModel(
                position: CGPoint(x: 350, y: 300),
                size: 100,
                shape: .vector4
            ),
            RegionModel(
                position: CGPoint(x: 300, y: 400),
                size: 100,
                shape: .vector5
            ),
            RegionModel(
                position: CGPoint(x: 200, y: 450),
                size: 100,
                shape: .vector6
            ),
            RegionModel(
                position: CGPoint(x: 450, y: 150),
                size: 100,
                shape: .vector7
            ),
            RegionModel(
                position: CGPoint(x: 500, y: 400),
                size: 100,
                shape: .vector8
            ),
            RegionModel(
                position: CGPoint(x: 450, y: 450),
                size: 100,
                shape: .vector9
            )
        ]
        
        return LevelConfiguration(
            levelNumber: 1,
            regions: regions,
            aiUpdateIntervalSeconds: 5.0 // AI делает ход каждые 5 секунд на уровне 1
        )
    }
    
    // Метод инициализации GameState из конфигурации уровня
    func createGameState() -> GameState {
        var gameState = GameState()
        gameState.gameLevel = levelNumber
        
        // Преобразование массива регионов в словарь с UUID в качестве ключа
        for region in regions {
            gameState.regions[region.id] = region
        }
        
        return gameState
    }
}
