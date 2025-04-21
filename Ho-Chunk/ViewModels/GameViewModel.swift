import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    @Published var regions: [Region] = []
    @Published var armies: [Army] = []
    @Published var dragInfo: (from: Region, to: CGPoint)? = nil
    @Published var currentLevel: Int = 1
    
    @Published var isGameOver: Bool = false
    @Published var isVictory: Bool = false
    
    // AI настройки
    private var aiTimer: AnyCancellable?
    private var aiMoveInterval: TimeInterval = 3.0 // Интервал хода AI (в секундах)
    
    // Основной игровой таймер
    private var gameTimer: AnyCancellable?
    
    private var isPaused: Bool = false
    
    init(level: Int = 1) {
        self.currentLevel = level
        setupLevel(level)
    }
    
    deinit {
        print("GameViewModel deinit - очищаем ресурсы")
        cleanupResources()
    }
    
    // Метод для очистки ресурсов
    func cleanupResources() {
        gameTimer?.cancel()
        gameTimer = nil
        
        aiTimer?.cancel()
        aiTimer = nil
        
        regions.forEach { $0.stopTroopGeneration() }
    }
    
    // Настройка уровня
    func setupLevel(_ levelId: Int) {
        // Очищаем старые данные
        cleanupResources()
        regions = []
        armies = []
        isGameOver = false
        isVictory = false
        
        // Получаем определение уровня
        let level = GameLevel.getLevel(levelId)
        
        // Создаем регионы на основе определений
        for regionDef in level.regions {
            let region = Region(
                shape: regionDef.shape,
                position: regionDef.position,
                width: regionDef.width,
                height: regionDef.height,
                owner: regionDef.owner,
                initialTroops: regionDef.initialTroops
            )
            regions.append(region)
        }
        
        // Настраиваем сложность AI в зависимости от уровня
        aiMoveInterval = max(3.0 - Double(levelId) * 0.5, 1.0) // Сложнее с ростом уровня
        
        // Запускаем игровой цикл и AI
        startGameLoop()
        startAI()
    }
    
    // Запуск игрового цикла
    private func startGameLoop() {
        gameTimer = Timer.publish(every: 0.05, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, !self.isPaused else { return }
                
                self.processArmyMovements()
                self.checkGameState()
            }
    }
    
    // Запуск AI
    private func startAI() {
        aiTimer = Timer.publish(every: aiMoveInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, !self.isPaused && !self.isGameOver else { return }
                
                self.performAIMove()
            }
    }
    
    // Пауза/возобновление игры
    func togglePause(_ paused: Bool) {
        isPaused = paused
        
        // Приостанавливаем/возобновляем генерацию войск
        regions.forEach { region in
            if paused {
                region.stopTroopGeneration()
            } else if region.owner != .neutral {
                region.startTroopGeneration()
            }
        }
    }
    
    // Проверка состояния игры (победа/поражение)
    private func checkGameState() {
        // Подсчет регионов
        let playerRegions = regions.filter { $0.owner == .player }.count
        let cpuRegions = regions.filter { $0.owner == .cpu }.count
        let neutralRegions = regions.filter { $0.owner == .neutral }.count
        
        // Проверка условий победы/поражения
        if playerRegions == 0 {
            // Поражение - у игрока не осталось регионов
            isGameOver = true
            isVictory = false
        } else if cpuRegions == 0 && neutralRegions == 0 {
            // Победа - у игрока все регионы
            isGameOver = true
            isVictory = true
        }
    }
    
    // Логика ходов AI
    private func performAIMove() {
        // Получаем все регионы CPU
        let cpuRegions = regions.filter { $0.owner == .cpu }
        
        // Если у CPU нет регионов, то ничего не делаем
        if cpuRegions.isEmpty {
            return
        }
        
        // Получаем регионы игрока и нейтральные
        let playerRegions = regions.filter { $0.owner == .player }
        let neutralRegions = regions.filter { $0.owner == .neutral }
        
        // Для каждого региона CPU пытаемся сделать ход
        for cpuRegion in cpuRegions {
            // Если в регионе мало войск, пропускаем
            if cpuRegion.troopCount < 5 {
                continue
            }
            
            // Сначала атакуем соседние нейтральные регионы
            if !neutralRegions.isEmpty {
                // Находим ближайший нейтральный регион
                if let targetRegion = findClosestRegion(from: cpuRegion, targets: neutralRegions) {
                    // Атакуем
                    sendArmy(from: cpuRegion, to: targetRegion, count: cpuRegion.troopCount)
                    break // Выходим после одного хода
                }
            }
            
            // Затем атакуем регионы игрока
            if !playerRegions.isEmpty {
                // Находим регион игрока с наименьшим количеством войск
                if let weakestPlayerRegion = playerRegions.min(by: { $0.troopCount < $1.troopCount }) {
                    // Атакуем только если наших войск достаточно
                    if cpuRegion.troopCount > weakestPlayerRegion.troopCount + 2 {
                        sendArmy(from: cpuRegion, to: weakestPlayerRegion, count: cpuRegion.troopCount)
                        break // Выходим после одного хода
                    }
                }
            }
        }
    }
    
    // Находим ближайший регион из списка целей
    private func findClosestRegion(from source: Region, targets: [Region]) -> Region? {
        return targets.min { a, b in
            let distanceToA = distance(from: source.position, to: a.position)
            let distanceToB = distance(from: source.position, to: b.position)
            return distanceToA < distanceToB
        }
    }
    
    // Расчет расстояния между точками
    private func distance(from a: CGPoint, to b: CGPoint) -> CGFloat {
        let dx = b.x - a.x
        let dy = b.y - a.y
        return sqrt(dx*dx + dy*dy)
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
