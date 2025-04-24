
import Foundation

class AchievementHelper {
    static let shared = AchievementHelper()
    
    private init() {}
    
    func checkFirstStepAchievement() {
        checkGenericAchievement(id: "firstStep")
    }
    
    func checkFirstVictoryAchievement() {
        checkGenericAchievement(id: "firstVictory")
    }
    
    func updateRegionCaptureCount() {
        var gameState = GameState.load()
        gameState.regionsCaptureDcount += 1
        
        if gameState.regionsCaptureDcount == 1 {
            checkFirstStepAchievement()
        }
        
        gameState.save()
    }
    
    func updateGamesWonCount() {
        var gameState = GameState.load()
        gameState.gamesWonCount += 1
        
        if gameState.gamesWonCount == 1 {
            checkFirstVictoryAchievement()
        }
        
        gameState.save()
    }
    
    private func checkGenericAchievement(id: String) {
        let gameState = GameState.load()
        
//        if !gameState.completedAchievements.contains(id) {
//            print("Achievement '\(id)' is now available to claim!")
//        }
        
        gameState.save()
    }
    
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
            return false
            
        default:
            return false
        }
    }
}
