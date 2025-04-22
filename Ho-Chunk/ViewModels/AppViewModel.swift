import SwiftUI
import Combine

class AppViewModel: ObservableObject {
    @Published var currentScreen: AppScreen = .menu
    @Published var gameLevel: Int = 1
    @Published var coins: Int = 0
    @Published var gameState: GameState
    
    @Published var gameViewModel: GameViewModel?
    
    init() {
        // Загружаем сохраненные данные из UserDefaults
        self.gameState = GameState.load()
        self.coins = gameState.coins
        self.gameLevel = gameState.currentLevel
        
        // Проверяем ежедневный бонус при запуске
        checkDailyBonus()
    }
    
    // Методы навигации
    func navigateTo(_ screen: AppScreen) {
        currentScreen = screen
    }
    
    // Запуск игры с указанным уровнем
    func startGame(level: Int? = nil) {
        // Если уровень не указан, используем текущий уровень из gameState
        let levelToStart = level ?? gameState.currentLevel
        gameLevel = levelToStart
        gameState.currentLevel = levelToStart
        gameViewModel = GameViewModel(level: levelToStart)
        gameViewModel?.appViewModel = self  // Устанавливаем ссылку на AppViewModel
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
        // Обновляем прогресс
        if gameLevel > gameState.maxCompletedLevel {
            gameState.maxCompletedLevel = gameLevel
        }
        
        // Начисляем награду
        coins += 50
        gameState.coins = coins
        
        // Если это первый уровень, отмечаем обучение как пройденное
        if gameLevel == 1 {
            gameState.tutorialCompleted = true
        }
        
        // Сохраняем прогресс
        saveGameState()
        
        // Устанавливаем флаг оверлея победы
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
    
    // Метод для проверки ежедневного входа и получения бонуса
    func checkDailyBonus() {
        let calendar = Calendar.current
        
        if let lastLoginDate = gameState.lastLoginDate {
            // Проверяем, прошло ли более 24 часов с последнего входа
            if !calendar.isDateInToday(lastLoginDate) {
                coins += 20
                gameState.coins = coins
            }
        }
        
        gameState.lastLoginDate = Date()
        saveGameState()
    }
    
    // Метод для сброса всего прогресса
    func resetAllProgress() {
        GameState.resetProgress()
        gameState = GameState.load()
        coins = 0
        gameLevel = 1
    }
}
