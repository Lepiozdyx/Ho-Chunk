
import Foundation

struct GameState: Codable {
    var currentLevel: Int = 1
    var maxCompletedLevel: Int = 0
    var coins: Int = 0
    var lastLoginDate: Date?
    var completedAchievements: [String] = []
    var notifiedAchievements: [String] = []
    var purchasedThemes: [String] = ["desert"]
    var currentThemeId: String = "desert"
    var tutorialCompleted: Bool = false
    
    var regionsCaptureDcount: Int = 0
    var gamesWonCount: Int = 0
    var wasWinningWhileOutnumbered: Bool = false
    
    var lastDailyRewardClaimDate: Date?
    
    var maxAvailableLevel: Int {
        return min(maxCompletedLevel + 1, GameLevel.levels.count)
    }
}

extension GameState {
    private static let gameStateKey = "hochunkGameState"
    
    static func load() -> GameState {
        guard let data = UserDefaults.standard.data(forKey: gameStateKey) else {
            return GameState()
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let gameState = try decoder.decode(GameState.self, from: data)
            return gameState
        } catch {
            return GameState()
        }
    }
    
    func save() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            
            let encoded = try encoder.encode(self)
            UserDefaults.standard.set(encoded, forKey: GameState.gameStateKey)
            UserDefaults.standard.synchronize() // Принудительная синхронизация
        } catch {
            print("[GameState] ОШИБКА при кодировании: \(error)")
        }
    }
    
    static func resetProgress() {
        UserDefaults.standard.removeObject(forKey: gameStateKey)
        UserDefaults.standard.synchronize()
    }
}
