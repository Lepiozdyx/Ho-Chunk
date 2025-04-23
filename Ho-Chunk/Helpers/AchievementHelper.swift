
import Foundation

class AchievementHelper {
    static let shared = AchievementHelper()
    
    private init() {}
    
    // Проверяет и обновляет статус достижения "First Step"
    func checkFirstStepAchievement() {
        checkGenericAchievement(id: "firstStep")
    }
    
    // Проверяет и обновляет статус достижения "First Victory"
    func checkFirstVictoryAchievement() {
        checkGenericAchievement(id: "firstVictory")
    }
    
    // Обновляет прогресс захваченных регионов
    func updateRegionCaptureCount() {
        var gameState = GameState.load()
        gameState.regionsCaptureDcount += 1
        
        if gameState.regionsCaptureDcount == 1 {
            checkFirstStepAchievement()
        }
        
        gameState.save()
    }
    
    // Обновляет счетчик выигранных игр
    func updateGamesWonCount() {
        var gameState = GameState.load()
        gameState.gamesWonCount += 1
        
        if gameState.gamesWonCount == 1 {
            checkFirstVictoryAchievement()
        }
        
        gameState.save()
    }
    
    // Общий метод для проверки достижения с одним условием
    private func checkGenericAchievement(id: String) {
        let gameState = GameState.load()
        
        // Если достижение еще не отмечено как выполненное
        if !gameState.completedAchievements.contains(id) {
            print("Achievement '\(id)' is now available to claim!")
        }
        
        gameState.save()
    }
    
    // Проверяет, выполнены ли условия для достижения
    func isAchievementCompleted(id: String) -> Bool {
        let gameState = GameState.load()
        
        switch id {
        case "firstStep":
            return gameState.regionsCaptureDcount > 0
            
        case "firstVictory":
            return gameState.gamesWonCount > 0
            
        case "landInvader":
            return gameState.regionsCaptureDcount >= 500
            
        case "destroyer":
            return gameState.gamesWonCount >= 10
            
        case "hardBattle":
            // Это достижение не реализовано, поэтому всегда возвращает false
            return false
            
        default:
            return false
        }
    }
}
