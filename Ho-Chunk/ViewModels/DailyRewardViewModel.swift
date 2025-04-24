
import SwiftUI
import Combine

@MainActor class DailyRewardViewModel: ObservableObject {
    
    @Published var remainingTime: String = ""
    @Published var isRewardAvailable: Bool = false
    @Published var isClaimingReward: Bool = false
    
    private var timer: AnyCancellable?
    weak var appViewModel: AppViewModel?
    private let dailyRewardAmount: Int = 20
    
    init() {
        startTimer()
    }
    
    deinit {
        timer?.cancel()
        timer = nil
    }
    
    func claimReward() -> Bool {
        guard let appViewModel = appViewModel else {
            print("[DailyReward] Не удалось получить награду: appViewModel = nil")
            return false
        }
        
        guard isRewardAvailable && !isClaimingReward else {
            print("[DailyReward] Не удалось получить награду: доступность=\(isRewardAvailable), получение=\(isClaimingReward)")
            return false
        }
        
        isClaimingReward = true
        print("[DailyReward] Начинаем получение награды")
        
        // Добавляем монеты к текущему значению
        appViewModel.coins += dailyRewardAmount
        print("[DailyReward] Добавлено \(dailyRewardAmount) монет, всего: \(appViewModel.coins)")
        
        // Устанавливаем текущую дату получения
        var gameState = appViewModel.gameState
        gameState.lastDailyRewardClaimDate = Date()
        gameState.coins = appViewModel.coins
        
        // Явно сохраняем в UserDefaults
        gameState.save()
        
        // Обновляем appViewModel
        appViewModel.gameState = gameState
        
        print("[DailyReward] Дата получения награды установлена: \(gameState.lastDailyRewardClaimDate!)")
        
        // Обновляем наше состояние
        updateState()
        
        return true
    }
    
    func updateState() {
        guard let appViewModel = appViewModel else {
            isRewardAvailable = false
            remainingTime = "Loading..."
            return
        }
        
        let lastClaimDate = appViewModel.gameState.lastDailyRewardClaimDate
        print("[DailyReward] Дата последнего получения: \(lastClaimDate?.description ?? "не установлена")")
        
        if let lastDate = lastClaimDate {
            // Проверяем, получена ли награда сегодня
            let isToday = Calendar.current.isDateInToday(lastDate)
            isRewardAvailable = !isToday
            
            if isToday {
                let remainingSeconds = calculateRemainingTime(from: lastDate)
                remainingTime = formatRemainingTime(remainingSeconds)
                print("[DailyReward] Награда недоступна. Осталось: \(remainingTime)")
            } else {
                remainingTime = "Available"
                print("[DailyReward] Награда доступна: дата не сегодня")
            }
        } else {
            isRewardAvailable = true
            remainingTime = "Available"
            print("[DailyReward] Награда доступна: дата не установлена")
        }
    }
    
    func startTimer() {
        timer?.cancel()
        timer = Timer.publish(every: 60.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateState()
            }
    }
    
    private func calculateRemainingTime(from date: Date) -> TimeInterval {
        let calendar = Calendar.current
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: date)) else {
            return 0
        }
        return max(0, tomorrow.timeIntervalSince(Date()))
    }
    
    private func formatRemainingTime(_ timeInterval: TimeInterval) -> String {
        if timeInterval <= 0 {
            return "Available"
        }
        
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        
        return String(format: "%02d:%02d", hours, minutes)
    }
}
