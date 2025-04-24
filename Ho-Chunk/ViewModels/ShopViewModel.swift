
import SwiftUI
import Combine

@MainActor class ShopViewModel: ObservableObject {
    @Published var purchasedThemeIds: [String] = []
    @Published var currentThemeId: String = "desert"
    @Published var availableThemes: [BackgroundTheme] = BackgroundTheme.availableThemes
    
    weak var appViewModel: AppViewModel?
    
    private let settingsManager = SettingsViewModel.shared
    
    init() {
        loadFromGameState()
    }
    
    private func loadFromGameState() {
        let gameState = GameState.load()
        purchasedThemeIds = gameState.purchasedThemes
        currentThemeId = gameState.currentThemeId
    }
    
    func isThemePurchased(_ themeId: String) -> Bool {
        return purchasedThemeIds.contains(themeId)
    }
    
    func isThemeSelected(_ themeId: String) -> Bool {
        return currentThemeId == themeId
    }
    
    func purchaseTheme(_ themeId: String) {
        guard !isThemePurchased(themeId),
              let theme = availableThemes.first(where: { $0.id == themeId }),
              let appViewModel = appViewModel,
              appViewModel.coins >= theme.price else {
            return
        }
        
        settingsManager.play()
        
        appViewModel.coins -= theme.price
        
        purchasedThemeIds.append(themeId)
        
        selectTheme(themeId)
        
        saveToGameState()
    }
    
    func selectTheme(_ themeId: String) {
        guard isThemePurchased(themeId) else {
            return
        }
        
        settingsManager.play()
        
        currentThemeId = themeId
        
        saveToGameState()
    }
    
    private func saveToGameState() {
        var gameState = GameState.load()
        
        gameState.purchasedThemes = purchasedThemeIds
        gameState.currentThemeId = currentThemeId
        
        if let appViewModel = appViewModel {
            gameState.coins = appViewModel.coins
        }
        
        gameState.save()
        
        appViewModel?.gameState = gameState
    }
    
    var currentTheme: BackgroundTheme {
        return BackgroundTheme.getTheme(id: currentThemeId)
    }
}
