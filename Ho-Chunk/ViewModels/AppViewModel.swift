
import SwiftUI
import Combine

class AppViewModel: ObservableObject {
    @Published var currentScreen: AppScreen = .menu
    @Published var gameLevel: Int = 1
    @Published var coins: Int = 0
    @Published var gameState: GameState
    
    @Published var gameViewModel: GameViewModel?
    
    init() {
        self.gameState = GameState.load()
        self.coins = gameState.coins
        self.gameLevel = gameState.currentLevel
        
        checkDailyBonus()
    }
    
    var currentTheme: BackgroundTheme {
        return BackgroundTheme.getTheme(id: gameState.currentThemeId)
    }
    
    func navigateTo(_ screen: AppScreen) {
        currentScreen = screen
    }
    
    func startGame(level: Int? = nil) {
        let levelToStart = level ?? gameState.currentLevel
        gameLevel = levelToStart
        gameState.currentLevel = levelToStart
        gameViewModel = GameViewModel(level: levelToStart)
        gameViewModel?.appViewModel = self
        navigateTo(.game)
        saveGameState()
    }
    
    func goToMenu() {
        gameViewModel?.cleanupResources()
        gameViewModel = nil
        navigateTo(.menu)
    }
    
    func pauseGame() {
        gameViewModel?.togglePause(true)
    }
    
    func resumeGame() {
        gameViewModel?.togglePause(false)
    }
    
    func showVictory() {
        if gameLevel > gameState.maxCompletedLevel {
            gameState.maxCompletedLevel = gameLevel
        }
        
        gameState.gamesWonCount += 1
        
        if gameState.gamesWonCount == 1 &&
           !gameState.completedAchievements.contains("firstVictory") {
            print("Achievement 'First Victory' unlocked!")
        }
        
        coins += 50
        gameState.coins = coins
        
        if gameLevel == 1 {
            gameState.tutorialCompleted = true
        }
        
        saveGameState()
        
        gameViewModel?.showVictoryOverlay = true
        gameViewModel?.isPaused = true
    }
    
    func showDefeat() {
        gameViewModel?.showDefeatOverlay = true
        gameViewModel?.isPaused = true
    }
    
    func restartLevel() {
        gameViewModel?.resetOverlays()
        gameViewModel?.setupLevel(gameLevel)
    }
    
    func goToNextLevel() {
        gameLevel += 1
        gameState.currentLevel = gameLevel
        saveGameState()
        
        gameViewModel?.resetOverlays()
        gameViewModel?.setupLevel(gameLevel)
    }
    
    func saveGameState() {
        gameState.coins = coins
        gameState.currentLevel = gameLevel
        gameState.save()
    }
    
    func checkDailyBonus() {
        let calendar = Calendar.current
        
        if let lastLoginDate = gameState.lastLoginDate {
            if !calendar.isDateInToday(lastLoginDate) {
                coins += 20
                gameState.coins = coins
            }
        }
        
        gameState.lastLoginDate = Date()
        saveGameState()
    }
    
    func resetAllProgress() {
        GameState.resetProgress()
        gameState = GameState.load()
        coins = 0
        gameLevel = 1
    }
}
