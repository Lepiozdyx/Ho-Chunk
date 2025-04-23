
import Foundation

struct GameState: Codable {
    var currentLevel: Int = 1
    var maxCompletedLevel: Int = 0
    var coins: Int = 0
    var lastLoginDate: Date?
    var completedAchievements: [String] = []
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
        guard let data = UserDefaults.standard.data(forKey: gameStateKey),
              let gameState = try? JSONDecoder().decode(GameState.self, from: data) else {
            return GameState()
        }
        return gameState
    }
    
    func save() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: GameState.gameStateKey)
        }
    }
    
    static func resetProgress() {
        UserDefaults.standard.removeObject(forKey: gameStateKey)
    }
}
