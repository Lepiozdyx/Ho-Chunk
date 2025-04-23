
import SwiftUI
import Combine

@MainActor class ShopViewModel: ObservableObject {
    @Published var purchasedThemeIds: [String] = []
    @Published var currentThemeId: String = "desert"
    @Published var availableThemes: [BackgroundTheme] = BackgroundTheme.availableThemes
    
    // Ссылка на основную модель представления
    weak var appViewModel: AppViewModel?
    
    private let settingsManager = SettingsViewModel.shared
    
    init() {
        loadFromGameState()
    }
    
    // Загрузить данные из GameState
    private func loadFromGameState() {
        let gameState = GameState.load()
        purchasedThemeIds = gameState.purchasedThemes
        currentThemeId = gameState.currentThemeId
    }
    
    // Проверить, куплена ли тема
    func isThemePurchased(_ themeId: String) -> Bool {
        return purchasedThemeIds.contains(themeId)
    }
    
    // Проверить, является ли тема текущей выбранной
    func isThemeSelected(_ themeId: String) -> Bool {
        return currentThemeId == themeId
    }
    
    // Купить тему
    func purchaseTheme(_ themeId: String) {
        guard !isThemePurchased(themeId),
              let theme = availableThemes.first(where: { $0.id == themeId }),
              let appViewModel = appViewModel,
              appViewModel.coins >= theme.price else {
            return
        }
        
        // Проигрываем звук
        settingsManager.play()
        
        // Вычитаем монеты
        appViewModel.coins -= theme.price
        
        // Добавляем тему в список купленных
        purchasedThemeIds.append(themeId)
        
        // Выбираем купленную тему
        selectTheme(themeId)
        
        // Сохраняем изменения
        saveToGameState()
    }
    
    // Выбрать тему
    func selectTheme(_ themeId: String) {
        guard isThemePurchased(themeId) else {
            return
        }
        
        // Проигрываем звук
        settingsManager.play()
        
        // Устанавливаем выбранную тему
        currentThemeId = themeId
        
        // Сохраняем изменения
        saveToGameState()
    }
    
    // Сохранить данные в GameState
    private func saveToGameState() {
        var gameState = GameState.load()
        
        // Обновляем информацию о темах
        gameState.purchasedThemes = purchasedThemeIds
        gameState.currentThemeId = currentThemeId
        
        // Обновляем монеты, если appViewModel доступен
        if let appViewModel = appViewModel {
            gameState.coins = appViewModel.coins
        }
        
        // Сохраняем изменения
        gameState.save()
        
        // Обновляем состояние appViewModel
        appViewModel?.gameState = gameState
    }
    
    // Получить текущую выбранную тему
    var currentTheme: BackgroundTheme {
        return BackgroundTheme.getTheme(id: currentThemeId)
    }
}
