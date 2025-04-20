import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    // Опубликованные свойства для реактивного обновления UI
    @Published var navigationState: NavigationState = .menu
    @Published var playerProgress: PlayerProgress
    
    // Игровой движок
    @Published var gameEngine: GameEngine
    
    // Отслеживание подписок
    private var cancellables = Set<AnyCancellable>()
    
    // Инициализатор
    init() {
        // Загрузка прогресса игрока
        self.playerProgress = PlayerProgress.load()
        
        // Инициализация игрового движка
        self.gameEngine = GameEngine()
        
        // Проверка на ежедневный вход
        checkDailyLogin()
        
        // Настройка подписок для мониторинга состояния игры
        setupSubscriptions()
    }
    
    // Настройка подписок на изменения игрового состояния
    private func setupSubscriptions() {
        // Мониторинг условий победы/поражения через обертку gameStateWrapper
        gameEngine.$gameStateWrapper
            .receive(on: RunLoop.main)
            .sink { [weak self] wrapper in
                guard let self = self else { return }
                let state = wrapper.state
                
                // Реагирование на победу
                if state.isPlayerVictory {
                    self.handlePlayerVictory()
                }
                
                // Реагирование на поражение
                if state.isPlayerDefeat {
                    self.handlePlayerDefeat()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Методы навигации
    
    func navigateToGame() {
        startGame(level: playerProgress.currentLevel)
        navigationState = .game
    }
    
    func navigateToMenu() {
        stopGame()
        navigationState = .menu
    }
    
    func navigateToPause() {
        pauseGame()
        navigationState = .pause
    }
    
    func navigateToSettings() {
        navigationState = .settings
    }
    
    func navigateToShop() {
        navigationState = .shop
    }
    
    func navigateToAchievements() {
        navigationState = .achievements
    }
    
    func navigateToTutorial() {
        startGame(level: 1) // Обучающий уровень
        navigationState = .tutorial
    }
    
    func resumeGame() {
        gameEngine.resumeGame()
        navigationState = .game
    }
    
    // MARK: - Методы управления игрой
    
    func startGame(level: Int) {
        print("Starting game at level \(level)")
        gameEngine.startGame(level: level)
    }
    
    func pauseGame() {
        gameEngine.pauseGame()
    }
    
    func stopGame() {
        gameEngine.stopGame()
    }
    
    func handlePlayerVictory() {
        print("Handling player victory")
        
        // Переходим в состояние паузы чтобы показать оверлей победы
        pauseGame()
        
        // Проверяем, было ли это состояние меньшинства
        let wasInMinority = gameEngine.gameState.playerControlPercentage < 0.5
        
        // Обновляем прогресс игрока
        playerProgress.registerGameWin(wasInMinority: wasInMinority)
        
        // Начисление монет за победу
        playerProgress.addCoinsForVictory()
        
        // Разблокировка следующего уровня
        if playerProgress.currentLevel == gameEngine.gameState.gameLevel {
            playerProgress.currentLevel += 1
        }
        
        // Сохранение прогресса
        playerProgress.save()
    }
    
    func handlePlayerDefeat() {
        print("Handling player defeat")
        
        // Переходим в состояние паузы чтобы показать оверлей поражения
        pauseGame()
        
        // Дополнительная логика при поражении, если потребуется
    }
    
    func continueAfterVictory() {
        // Начинаем следующий уровень
        startGame(level: playerProgress.currentLevel)
        navigationState = .game
    }
    
    func retryAfterDefeat() {
        // Перезапускаем текущий уровень
        startGame(level: gameEngine.gameState.gameLevel)
        navigationState = .game
    }
    
    private func checkDailyLogin() {
        playerProgress.addCoinsForDailyLogin()
    }
    
    // Метод для форсирования обновления UI
    func forceUIUpdate() {
        // Явно вызываем обновление UI для GameViewModel
        objectWillChange.send()
    }
}
