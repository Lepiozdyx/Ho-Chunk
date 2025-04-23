
import SwiftUI

@MainActor class AchievementViewModel: ObservableObject {
    @Published var achievements: [Achievement] = []
    
    weak var appViewModel: AppViewModel?
    
    private let settingsManager = SettingsViewModel.shared
    
    init() {
        loadAchievements()
    }
    
    private func loadAchievements() {
        // Start with all achievements
        achievements = Achievement.allAchievements
        
        // Load game state to update achievements
        let gameState = GameState.load()
        
        // Update claimed achievements
        for i in 0..<achievements.count {
            if gameState.completedAchievements.contains(achievements[i].id) {
                // This achievement has been completed and claimed
                achievements[i].progress = achievements[i].target
            }
        }
        
        // In a real implementation, we would update progress of each achievement
        // based on stored game statistics. For now, using placeholder logic.
        
        // Example for Land Invader achievement
        if let index = achievements.firstIndex(where: { $0.id == "landInvader" }) {
            achievements[index].progress = min(gameState.regionsCaptureDcount, 500)
        }
        
        // Example for Destroyer achievement
        if let index = achievements.firstIndex(where: { $0.id == "destroyer" }) {
            achievements[index].progress = min(gameState.gamesWonCount, 10)
        }
    }
    
    // Check if achievement is completed (based on progress)
    func isAchievementCompleted(id: String) -> Bool {
        if let achievement = achievements.first(where: { $0.id == id }) {
            return achievement.progress >= achievement.target
        }
        return false
    }
    
    // Check if achievement is claimed
    func isAchievementClaimed(id: String) -> Bool {
        let gameState = GameState.load()
        return gameState.completedAchievements.contains(id)
    }
    
    // Check if achievement can be claimed
    func canClaimAchievement(id: String) -> Bool {
        return isAchievementCompleted(id: id) && !isAchievementClaimed(id: id)
    }
    
    // Claim achievement reward
    func claimAchievement(id: String) {
        guard let achievement = achievements.first(where: { $0.id == id }),
              canClaimAchievement(id: id),
              let appViewModel = appViewModel else {
            return
        }
        
        // Play sound
        settingsManager.play()
        
        // Add coins
        appViewModel.coins += achievement.reward
        
        // Mark as claimed
        var gameState = GameState.load()
        gameState.completedAchievements.append(id)
        gameState.coins = appViewModel.coins
        gameState.save()
        
        // Update app view model state
        appViewModel.gameState = gameState
        
        // Reload achievements to reflect changes
        loadAchievements()
    }
}
