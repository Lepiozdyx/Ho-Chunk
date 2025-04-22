import SwiftUI
import Combine

class AppViewModel: ObservableObject {
    @Published var currentScreen: AppScreen = .menu
    @Published var gameLevel: Int = 1
    @Published var coins: Int = 0
    
    @Published var gameViewModel: GameViewModel?
    
    // Инициализация
    init() {
        // Здесь можно загрузить сохраненные данные из UserDefaults
    }
    
    // Методы навигации
    func navigateTo(_ screen: AppScreen) {
        currentScreen = screen
    }
    
    // Запуск игры с указанным уровнем
    func startGame(level: Int = 1) {
        gameLevel = level
        gameViewModel = GameViewModel(level: level)
        navigateTo(.game)
    }
    
    // Возврат в меню
    func goToMenu() {
        gameViewModel?.cleanupResources()
        gameViewModel = nil
        navigateTo(.menu)
    }
    
    // Показать паузу - теперь просто устанавливает флаг в GameViewModel
    func pauseGame() {
        gameViewModel?.togglePause(true)
    }
    
    // Продолжить после паузы - снимает флаг
    func resumeGame() {
        gameViewModel?.togglePause(false)
    }
    
    // Показать экран победы
    func showVictory() {
        // Начисляем награду
        coins += 50
        
        // Устанавливаем флаг оверлея победы
        gameViewModel?.showVictoryOverlay = true
        gameViewModel?.isPaused = true
    }
    
    // Показать экран поражения
    func showDefeat() {
        // Устанавливаем флаг оверлея поражения
        gameViewModel?.showDefeatOverlay = true
        gameViewModel?.isPaused = true
    }
    
    // Метод для перезапуска уровня
    func restartLevel() {
        gameViewModel?.resetOverlays()
        gameViewModel?.setupLevel(gameLevel)
    }
    
    // Метод для перехода к следующему уровню
    func goToNextLevel() {
        gameLevel += 1
        gameViewModel?.resetOverlays()
        gameViewModel?.setupLevel(gameLevel)
    }
    
    // Сохранение данных
    func saveGameState() {
        // Здесь будет код сохранения прогресса в UserDefaults
    }
}
