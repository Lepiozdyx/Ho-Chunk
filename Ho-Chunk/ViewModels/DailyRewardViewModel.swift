
import SwiftUI
import Combine

@MainActor class DailyRewardViewModel: ObservableObject {
    
    @Published var remainingTime: String = ""
    @Published var isRewardAvailable: Bool = false
    @Published var isClaimingReward: Bool = false
    
    
    private var timer: AnyCancellable?
    weak var appViewModel: AppViewModel?
    private let dailyRewardAmount: Int = 20
    
    init(appViewModel: AppViewModel) {
        self.appViewModel = appViewModel
        updateState()
        startTimer()
    }
    
    deinit {
        cleanupTimer()
    }
    
    func claimReward() {
        guard isRewardAvailable, !isClaimingReward, let appViewModel = appViewModel else { return }
        
        isClaimingReward = true
        
        appViewModel.coins += dailyRewardAmount
        
        var gameState = appViewModel.gameState
        gameState.lastDailyRewardClaimDate = Date()
        gameState.coins = appViewModel.coins
        gameState.save()
        appViewModel.gameState = gameState
        
        updateState()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.isClaimingReward = false
        }
    }
    
    func updateState() {
        guard let appViewModel = appViewModel else { return }
        
        let lastClaimDate = appViewModel.gameState.lastDailyRewardClaimDate
        isRewardAvailable = lastClaimDate == nil ||
                            !Calendar.current.isDateInToday(lastClaimDate!)
        
        if let lastDate = lastClaimDate {
            let remainingSeconds = calculateRemainingTime(from: lastDate)
            remainingTime = formatRemainingTime(remainingSeconds)
        } else {
            remainingTime = "Available"
        }
    }
    
    private func startTimer() {
        stopTimer()

        timer = Timer.publish(every: 60.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateState()
            }
    }
    
    private func stopTimer() {
        timer?.cancel()
        timer = nil
    }
    
    nonisolated private func cleanupTimer() {
        DispatchQueue.main.async { [weak self] in
            self?.timer?.cancel()
            self?.timer = nil
        }
    }
    
    private func calculateRemainingTime(from date: Date) -> TimeInterval {
        let calendar = Calendar.current
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: date)) {
            return max(0, tomorrow.timeIntervalSince(Date()))
        }
        return 0
    }
    
    private func formatRemainingTime(_ timeInterval: TimeInterval) -> String {
        if timeInterval <= 0 {
            return "Available"
        }
        
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        let formattedMinutes = minutes < 10 ? "0\(minutes)" : "\(minutes)"
        
        return "\(hours):\(formattedMinutes)"
    }
}
