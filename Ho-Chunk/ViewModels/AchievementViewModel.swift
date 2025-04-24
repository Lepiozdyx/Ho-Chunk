
import SwiftUI

@MainActor class AchievementViewModel: ObservableObject {
    @Published var achievements: [Achievement] = []
    
    weak var appViewModel: AppViewModel?
    
    private let settingsManager = SettingsViewModel.shared
    
    init() {
        loadAchievements()
    }
    
    private func loadAchievements() {
        achievements = Achievement.allAchievements
        
        let gameState = GameState.load()
        
        for i in 0..<achievements.count {
            if gameState.completedAchievements.contains(achievements[i].id) {
                achievements[i].progress = achievements[i].target
            }
        }
        
        /// Update progress for achievements based on game statistics
        
        if let index = achievements.firstIndex(where: { $0.id == "firstStep" }) {
            achievements[index].progress = gameState.regionsCaptureDcount > 0 ? 1 : 0
        }
        
        if let index = achievements.firstIndex(where: { $0.id == "firstVictory" }) {
            achievements[index].progress = gameState.gamesWonCount > 0 ? 1 : 0
        }
        
        if let index = achievements.firstIndex(where: { $0.id == "landInvader" }) {
            achievements[index].progress = min(gameState.regionsCaptureDcount, 500)
        }
        
        if let index = achievements.firstIndex(where: { $0.id == "destroyer" }) {
            achievements[index].progress = min(gameState.gamesWonCount, 10)
        }
    }
    
    func isAchievementCompleted(id: String) -> Bool {
        if let achievement = achievements.first(where: { $0.id == id }) {
            return achievement.progress >= achievement.target
        }
        return false
    }
    
    func isAchievementClaimed(id: String) -> Bool {
        let gameState = GameState.load()
        return gameState.completedAchievements.contains(id)
    }
    
    func canClaimAchievement(id: String) -> Bool {
        return isAchievementCompleted(id: id) && !isAchievementClaimed(id: id)
    }
    
    func claimAchievement(id: String) {
        guard let achievement = achievements.first(where: { $0.id == id }),
              canClaimAchievement(id: id),
              let appViewModel = appViewModel else {
            return
        }
        
        settingsManager.play()
        
        appViewModel.coins += achievement.reward
        
        var gameState = GameState.load()
        gameState.completedAchievements.append(id)
        gameState.coins = appViewModel.coins
        gameState.save()
        
        appViewModel.gameState = gameState
        
        loadAchievements()
    }
}
