
import Foundation

struct PlayerProgress: Codable {
    var currentLevel: Int
    var coins: Int
    var achievements: [String: Bool] // Ключ - ID достижения, значение - разблокировано ли
    var purchasedItems: [String: Bool] // Ключ - ID товара, значение - куплен ли
    var totalRegionsConquered: Int
    var gamesWon: Int
    var lastLoginDate: Date?
    
    // Ключи для UserDefaults
    static let userDefaultsKey = "ho_chunk_player_progress"
    
    // Инициализатор по умолчанию
    init() {
        self.currentLevel = 1
        self.coins = 0
        self.achievements = [:]
        self.purchasedItems = [:]
        self.totalRegionsConquered = 0
        self.gamesWon = 0
        self.lastLoginDate = nil
        
        // Инициализация словаря достижений
        for achievement in Achievement.createAllAchievements() {
            self.achievements[achievement.id] = false
        }
    }
    
    // Загрузка из UserDefaults
    static func load() -> PlayerProgress {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let progress = try? JSONDecoder().decode(PlayerProgress.self, from: data) else {
            return PlayerProgress() // Создание нового прогресса, если загрузка не удалась
        }
        return progress
    }
    
    // Сохранение в UserDefaults
    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: PlayerProgress.userDefaultsKey)
        }
    }
    
    // Начисление монет за победу
    mutating func addCoinsForVictory() {
        coins += 50
        save()
    }
    
    // Начисление монет за ежедневный вход
    mutating func addCoinsForDailyLogin() {
        // Проверка, прошло ли 24 часа с последнего входа
        if let lastLogin = lastLoginDate {
            let now = Date()
            let timeSinceLastLogin = now.timeIntervalSince(lastLogin)
            if timeSinceLastLogin >= 24 * 60 * 60 { // 24 часа в секундах
                coins += 20
                lastLoginDate = now
                save()
            }
        } else {
            // Первый вход
            coins += 20
            lastLoginDate = Date()
            save()
        }
    }
    
    // Проверка, может ли игрок приобрести товар
    func canPurchaseItem(itemId: String, price: Int) -> Bool {
        // Проверка, не куплен ли уже этот товар
        if purchasedItems[itemId] == true {
            return false
        }
        
        return coins >= price
    }
    
    // Покупка товара
    mutating func purchaseItem(itemId: String, price: Int) -> Bool {
        if canPurchaseItem(itemId: itemId, price: price) {
            coins -= price
            purchasedItems[itemId] = true
            save()
            return true
        }
        return false
    }
    
    // Разблокировка достижения
    mutating func unlockAchievement(id: String) {
        if achievements[id] != true {
            achievements[id] = true
            save()
        }
    }
    
    // Регистрация захвата региона
    mutating func registerRegionConquest() {
        totalRegionsConquered += 1
        
        // Проверка на достижение "Первый шаг"
        if totalRegionsConquered == 1 {
            unlockAchievement(id: Achievement.firstStepKey)
        }
        
        // Проверка на достижение "Захватчик земель"
        if totalRegionsConquered >= 500 {
            unlockAchievement(id: Achievement.landConquerorKey)
        }
        
        save()
    }
    
    // Регистрация победы в игре
    mutating func registerGameWin(wasInMinority: Bool) {
        gamesWon += 1
        
        // Проверка на достижение "Первая победа"
        if gamesWon == 1 {
            unlockAchievement(id: Achievement.firstWinKey)
        }
        
        // Проверка на достижение "Уничтожитель"
        if gamesWon >= 10 {
            unlockAchievement(id: Achievement.destroyerKey)
        }
        
        // Проверка на достижение "Сражение до конца"
        if wasInMinority {
            unlockAchievement(id: Achievement.fightToTheEndKey)
        }
        
        save()
    }
    
    // Проверка, разблокировано ли достижение
    func isAchievementUnlocked(id: String) -> Bool {
        return achievements[id] == true
    }
}
