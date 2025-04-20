import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    @Published var regions: [Region] = []
    @Published var armies: [Army] = []
    @Published var dragInfo: (from: Region, to: CGPoint)? = nil
    
    private var timer: AnyCancellable?
    
    init() {
        setupRegions()
        startGameLoop()
    }
    
    deinit {
        // Очищаем ресурсы при уничтожении ViewModel
        timer?.cancel()
        regions.forEach { $0.stopTroopGeneration() }
    }
    
    private func setupRegions() {
        // Создаем три региона в ряд с разными формами
        let screenWidth = UIScreen.main.bounds.width
        let spacing: CGFloat = 200
        let centerY: CGFloat = 200
        
        // CPU регион (левый) - используем vector3
        let cpuRegion = Region(
            shape: .vector3,
            position: CGPoint(x: screenWidth/2 - spacing, y: centerY),
            owner: .cpu,
            initialTroops: 5
        )
        
        // Нейтральный регион (средний) - используем vector2
        let neutralRegion = Region(
            shape: .vector2,
            position: CGPoint(x: screenWidth/2, y: centerY),
            owner: .neutral,
            initialTroops: 0  // 0 войск в нейтральных регионах
        )
        
        // Регион игрока (правый) - используем vector1
        let playerRegion = Region(
            shape: .vector1,
            position: CGPoint(x: screenWidth/2 + spacing, y: centerY),
            owner: .player,
            initialTroops: 5
        )
        
        regions = [cpuRegion, neutralRegion, playerRegion]
    }
    
    private func startGameLoop() {
        // Обрабатываем движения армий и бои
        timer = Timer.publish(every: 0.05, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.processArmyMovements()
            }
    }
    
    private func processArmyMovements() {
        let currentTime = Date()
        var arrivedArmies: [Army] = []
        
        // Проверяем прибывшие армии
        for army in armies {
            if army.hasArrived(at: currentTime) {
                arrivedArmies.append(army)
                print("Армия \(army.owner) прибыла с \(army.count) войсками")
                processCombat(army: army)
            }
        }
        
        // Удаляем прибывшие армии
        if !arrivedArmies.isEmpty {
            DispatchQueue.main.async {
                self.armies.removeAll { army in
                    arrivedArmies.contains { $0.id == army.id }
                }
            }
        }
    }
    
    private func processCombat(army: Army) {
        let targetRegion = army.toRegion
        
        if targetRegion.owner == army.owner {
            // Подкрепление: просто добавляем войска
            targetRegion.troopCount += army.count
            print("Подкрепление: добавлено \(army.count) войск к региону \(targetRegion.owner)")
        } else {
            // Бой: сравниваем количество войск
            print("Битва: \(army.count) атакующих против \(targetRegion.troopCount) защитников")
            
            if army.count > targetRegion.troopCount {
                // Атакующий побеждает
                let remainingTroops = army.count - targetRegion.troopCount
                
                // Важно: сначала меняем владельца, потом устанавливаем количество войск
                let previousOwner = targetRegion.owner
                
                // Используем DispatchQueue.main.async для обновления UI
                DispatchQueue.main.async {
                    targetRegion.changeOwner(to: army.owner)
                    targetRegion.troopCount = remainingTroops
                }
                
                print("Победа атакующего! Регион перешел от \(previousOwner) к \(army.owner)")
            } else {
                // Защитник побеждает
                DispatchQueue.main.async {
                    targetRegion.troopCount -= army.count
                }
                print("Победа защитника! Осталось \(targetRegion.troopCount) войск")
            }
        }
    }
    
    func sendArmy(from: Region, to: Region, count: Int) {
        // Не отправляем, если количество равно 0 или превышает доступные войска
        if count <= 0 || count > from.troopCount {
            print("Невозможно отправить \(count) войск из региона с \(from.troopCount) войсками")
            return
        }
        
        // Уменьшаем количество войск в исходном регионе
        from.troopCount -= count
        print("Отправка \(count) войск от \(from.owner) к региону \(to.owner)")
        
        // Создаем и добавляем армию
        let army = Army(
            owner: from.owner,
            count: count,
            fromRegion: from,
            toRegion: to,
            startTime: Date()
        )
        
        armies.append(army)
    }
    
    // Вычисляем процент контроля игрока для индикатора прогресса
    func calculatePlayerControlPercentage() -> Double {
        let totalRegions = regions.count
        guard totalRegions > 0 else { return 0.5 }
        
        let playerRegions = regions.filter { $0.owner == .player }.count
        return Double(playerRegions) / Double(totalRegions)
    }
}
