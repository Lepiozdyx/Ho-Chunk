
import SwiftUI
import Combine

class AppViewModel: ObservableObject {
    @Published var currentScreen: AppScreen = .menu
    @Published var gameLevel: Int = 1
    @Published var coins: Int = 0
    
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
        navigateTo(.game)
    }
    
    // Возврат в меню
    func goToMenu() {
        navigateTo(.menu)
    }
    
    // Показать паузу
    func pauseGame() {
        navigateTo(.pause)
    }
    
    // Продолжить после паузы
    func resumeGame() {
        navigateTo(.game)
    }
    
    // Показать экран победы
    func showVictory() {
        // Награда за победу
        coins += 50
        navigateTo(.victory)
    }
    
    // Показать экран поражения
    func showDefeat() {
        navigateTo(.defeat)
    }
    
    // Сохранение данных
    func saveGameState() {
        // Здесь будет код сохранения прогресса в UserDefaults
    }
}
