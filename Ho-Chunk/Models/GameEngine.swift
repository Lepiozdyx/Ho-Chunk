import Foundation
import Combine

class GameEngine: ObservableObject {
    // Класс-обертка для GameState
    class GameStateWrapper: ObservableObject {
        private var shouldNotifyObservers = true
        
        @Published var state: GameState
        
        init(state: GameState = GameState()) {
            self.state = state
        }
        
        // Метод для установки состояния без уведомления наблюдателей
        func setStateSilently(_ newState: GameState) {
            shouldNotifyObservers = false
            state = newState
            shouldNotifyObservers = true
        }
    }
    
    // Оборачиваем состояние в класс-обертку
    @Published var gameStateWrapper: GameStateWrapper
    
    // Таймер для игровых обновлений
    private var gameTimer: AnyCancellable?
    private let updateInterval: TimeInterval = 0.1 // 100ms для плавного обновления
    
    // AI контроллер
    private var aiController: AIViewModel?
    private var lastAIUpdateTime: Date = Date()
    private var aiUpdateInterval: TimeInterval = 5.0
    
    // Флаг, указывающий, запущена ли уже игра
    private var isGameRunning: Bool = false
    
    // Счетчик для отслеживания обновлений (для отладки)
    private var updateCounter = 0
    
    // Вычисляемое свойство для удобства доступа к state
    var gameState: GameState {
        get { return gameStateWrapper.state }
        set {
            updateCounter += 1
            print("🔄 GameEngine: Setting new game state (#\(updateCounter))")
            gameStateWrapper.setStateSilently(newValue) // Устанавливаем без уведомления о непосредственном изменении
            // Явно уведомляем об изменении
            objectWillChange.send()
        }
    }
    
    // Инициализатор
    init(initialState: GameState = GameState()) {
        print("🏁 GameEngine: Initializing with default state")
        self.gameStateWrapper = GameStateWrapper(state: initialState)
    }
    
    // MARK: - Управление игровым циклом
    
    func startGame(level: Int) {
        // Проверяем, не запущена ли уже игра
        if isGameRunning {
            print("⚠️ GameEngine: Game already running, stopping first")
            stopGameLoop()
            isGameRunning = false
        }
        
        print("🎮 GameEngine: Starting game at level \(level)")
        
        // Создание конфигурации уровня
        let levelConfiguration = createLevelConfiguration(for: level)
        
        // Инициализация состояния игры из конфигурации
        let newGameState = levelConfiguration.createGameState()
        gameState = newGameState
        
        // Устанавливаем интервал обновления AI
        aiUpdateInterval = levelConfiguration.aiUpdateIntervalSeconds
        
        // Создание AI контроллера
        aiController = AIViewModel(gameState: gameState, aiUpdateInterval: aiUpdateInterval)
        
        // Начальное вычисление процента контроля
        var updatedState = gameState
        updatedState.calculatePlayerControlPercentage()
        gameState = updatedState
        
        // Запуск игрового цикла
        startGameLoop()
        
        isGameRunning = true
        
        // Выводим отладочную информацию
        print("✅ GameEngine: Game started: \(gameState.regions.count) regions, AI interval: \(aiUpdateInterval)s")
    }
    
    func pauseGame() {
        print("⏸️ GameEngine: Pausing game")
        stopGameLoop()
        
        var newState = gameState
        newState.isPaused = true
        gameState = newState
        
        isGameRunning = false
    }
    
    func resumeGame() {
        print("▶️ GameEngine: Resuming game")
        
        var newState = gameState
        newState.isPaused = false
        gameState = newState
        
        startGameLoop()
        isGameRunning = true
    }
    
    func stopGame() {
        print("🛑 GameEngine: Stopping game")
        stopGameLoop()
        gameState = GameState()
        isGameRunning = false
    }
    
    private func startGameLoop() {
        stopGameLoop() // Останавливаем предыдущий таймер, если есть
        
        print("⏱️ GameEngine: Starting game loop...")
        gameTimer = Timer.publish(every: updateInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateGame()
            }
    }
    
    private func stopGameLoop() {
        if gameTimer != nil {
            print("⏱️ GameEngine: Stopping game loop")
            gameTimer?.cancel()
            gameTimer = nil
        }
    }
    
    // MARK: - Обновление игрового состояния
    
    // Счетчик для отладки, чтобы не спамить логи на каждом обновлении
    private var loopCounter: Int = 0
    
    private func updateGame() {
        // Проверяем, не на паузе ли игра
        if gameState.isPaused {
            return
        }
        
        loopCounter += 1
        
        // Логируем только каждое 50-е обновление чтобы не спамить консоль
        let shouldLog = loopCounter % 50 == 0
        
        if shouldLog {
            print("🔄 GameEngine: Loop update #\(loopCounter)")
        }
        
        // Копируем текущее состояние
        var updatedState = gameState
        
        // Обновляем время последнего изменения
        let currentTime = Date()
        let elapsedTime = currentTime.timeIntervalSince(updatedState.lastUpdateTime)
        
        // Пропускаем обновление, если прошло слишком мало времени
        if elapsedTime < 0.01 {
            return
        }
        
        // Обновляем генерацию войск
        updateTroopGeneration(elapsedTime: elapsedTime, state: &updatedState, shouldLog: shouldLog)
        
        // Обновляем перемещения войск
        updateArmyTransfers(state: &updatedState, shouldLog: shouldLog)
        
        // Обновляем процент контроля территорий
        updatedState.calculatePlayerControlPercentage()
        
        // Проверяем, не пора ли обновить AI
        updateAI(currentTime: currentTime, state: &updatedState, shouldLog: shouldLog)
        
        // Проверяем условия победы/поражения
        checkGameEndConditions(state: &updatedState)
        
        // Обновляем время последнего обновления
        updatedState.lastUpdateTime = currentTime
        
        // Применяем обновленное состояние, только если оно изменилось
        if didStateChange(updatedState, fromState: gameState) {
            gameState = updatedState
        }
    }
    
    // Проверка, изменилось ли состояние существенно
    private func didStateChange(_ newState: GameState, fromState oldState: GameState) -> Bool {
        // Проверяем изменение количества войск
        let oldTroops = Dictionary(uniqueKeysWithValues: oldState.regions.map { ($0.key, $0.value.troopCount) })
        
        for (regionId, region) in newState.regions {
            if let oldCount = oldTroops[regionId], oldCount != region.troopCount {
                return true
            }
        }
        
        // Проверяем изменение владельцев регионов
        let oldOwners = Dictionary(uniqueKeysWithValues: oldState.regions.map { ($0.key, $0.value.owner) })
        
        for (regionId, region) in newState.regions {
            if let oldOwner = oldOwners[regionId], oldOwner != region.owner {
                return true
            }
        }
        
        // Проверяем изменение активных перемещений
        if oldState.activeTransfers.count != newState.activeTransfers.count {
            return true
        }
        
        // Проверяем прогресс активных перемещений
        for (transferId, transfer) in newState.activeTransfers {
            if let oldTransfer = oldState.activeTransfers[transferId],
               abs(oldTransfer.progress - transfer.progress) > 0.05 {
                return true
            }
        }
        
        // Проверяем изменение процента контроля
        if abs(oldState.playerControlPercentage - newState.playerControlPercentage) > 0.01 {
            return true
        }
        
        // Проверяем изменение условий победы/поражения
        if oldState.isPlayerVictory != newState.isPlayerVictory ||
           oldState.isPlayerDefeat != newState.isPlayerDefeat {
            return true
        }
        
        return false
    }
    
    private func updateTroopGeneration(elapsedTime: TimeInterval, state: inout GameState, shouldLog: Bool) {
        // Копируем словарь регионов
        var updatedRegions = state.regions
        var updatedAnyRegion = false
        
        for (regionId, region) in state.regions {
            if region.owner != .neutral {
                // Генерация войск: 1 войско в секунду
                let additionalTroops = Int(elapsedTime)
                if additionalTroops > 0 {
                    var updatedRegion = region
                    updatedRegion.troopCount += additionalTroops
                    updatedRegions[regionId] = updatedRegion
                    updatedAnyRegion = true
                    
                    if shouldLog {
                        print("👥 GameEngine: Region \(regionId) generated \(additionalTroops) troops, now has \(updatedRegion.troopCount)")
                    }
                }
            }
        }
        
        if updatedAnyRegion {
            // Присваиваем обновленный словарь только если были изменения
            state.regions = updatedRegions
        }
    }
    
    private func updateArmyTransfers(state: inout GameState, shouldLog: Bool) {
        if state.activeTransfers.isEmpty {
            return
        }
        
        var updatedTransfers = state.activeTransfers
        var transfersToRemove: [UUID] = []
        
        for (transferId, transfer) in state.activeTransfers {
            var updatedTransfer = transfer
            updatedTransfer.updateProgress()
            
            if shouldLog {
                print("🚶 GameEngine: Transfer \(transferId) progress: \(updatedTransfer.progress)")
            }
            
            if updatedTransfer.isCompleted {
                // Обработка завершенного перемещения
                print("✅ GameEngine: Transfer \(transferId) completed")
                processCompletedTransfer(updatedTransfer, state: &state)
                transfersToRemove.append(transferId)
            } else {
                updatedTransfers[transferId] = updatedTransfer
            }
        }
        
        // Удаление завершенных перемещений
        for transferId in transfersToRemove {
            updatedTransfers.removeValue(forKey: transferId)
        }
        
        state.activeTransfers = updatedTransfers
    }
    
    private func updateAI(currentTime: Date, state: inout GameState, shouldLog: Bool) {
        guard let aiController = aiController else { return }
        
        let timeElapsed = currentTime.timeIntervalSince(lastAIUpdateTime)
        if timeElapsed >= aiUpdateInterval {
            if shouldLog {
                print("🤖 GameEngine: AI making move")
            }
            
            aiController.makeMove { [weak self] updatedState in
                guard let self = self else { return }
                
                // Копируем текущее состояние
                var newState = self.gameState
                
                // Обновляем только активные перемещения, не трогая остальное состояние
                for (transferId, transfer) in updatedState.activeTransfers {
                    if newState.activeTransfers[transferId] == nil {
                        newState.activeTransfers[transferId] = transfer
                        print("🤖 GameEngine: AI created new transfer \(transferId)")
                    }
                }
                
                // Обновляем количество войск в регионах, откуда AI отправил войска
                for (regionId, region) in updatedState.regions {
                    if let existingRegion = newState.regions[regionId],
                       existingRegion.owner == .cpu && region.troopCount < existingRegion.troopCount {
                        newState.regions[regionId] = region
                    }
                }
                
                // Применяем обновления
                self.gameState = newState
                
                // Обновляем время последнего хода AI
                self.lastAIUpdateTime = currentTime
            }
        }
    }
    
    // MARK: - Бизнес-логика игры
    
    private func processCompletedTransfer(_ transfer: ArmyTransfer, state: inout GameState) {
        guard var toRegion = state.regions[transfer.toRegionId] else { return }
        
        print("⚔️ GameEngine: Processing transfer to region \(transfer.toRegionId) with \(transfer.count) troops")
        
        // Если регион принадлежит тому же игроку, просто добавляем войска
        if let fromRegion = state.regions[transfer.fromRegionId], fromRegion.owner == toRegion.owner {
            toRegion.troopCount += transfer.count
            state.regions[transfer.toRegionId] = toRegion
            print("➕ GameEngine: Added \(transfer.count) troops to owned region, now has \(toRegion.troopCount)")
            return
        }
        
        // Иначе происходит бой
        let attackingTroops = transfer.count
        let defendingTroops = toRegion.troopCount
        let previousOwner = toRegion.owner
        
        if attackingTroops > defendingTroops {
            // Атакующий победил
            let remainingTroops = attackingTroops - defendingTroops
            // Определяем владельца атакующих войск
            if let fromRegion = state.regions[transfer.fromRegionId] {
                toRegion.owner = fromRegion.owner
            }
            toRegion.troopCount = remainingTroops
            print("🏆 GameEngine: Battle won! Region \(transfer.toRegionId) captured from \(previousOwner) to \(toRegion.owner) with \(remainingTroops) troops remaining")
        } else {
            // Защитник победил или ничья
            let remainingTroops = defendingTroops - attackingTroops
            toRegion.troopCount = remainingTroops
            print("💔 GameEngine: Battle lost! Region \(transfer.toRegionId) defended by \(toRegion.owner) with \(remainingTroops) troops remaining")
        }
        
        state.regions[transfer.toRegionId] = toRegion
    }
    
    private func checkGameEndConditions(state: inout GameState) {
        // Логика проверки условий победы/поражения
        let wasVictory = state.isPlayerVictory
        let wasDefeat = state.isPlayerDefeat
        
        state.isPlayerVictory = state.regions.values.allSatisfy { $0.owner == .player }
        state.isPlayerDefeat = !state.regions.values.contains { $0.owner == .player }
        
        if !wasVictory && state.isPlayerVictory {
            print("🏆 GameEngine: PLAYER VICTORY DETECTED!")
        }
        
        if !wasDefeat && state.isPlayerDefeat {
            print("💀 GameEngine: PLAYER DEFEAT DETECTED!")
        }
    }
    
    // MARK: - Команды игрока
    
    func sendTroops(from fromRegionId: UUID, to toRegionId: UUID, count: Int) -> Bool {
        print("⚔️ GameEngine: Attempting to send \(count) troops from \(fromRegionId) to \(toRegionId)")
        
        // Проверка валидности операции
        guard let fromRegion = gameState.regions[fromRegionId],
              gameState.regions[toRegionId] != nil,
              fromRegion.owner == .player,
              fromRegion.troopCount >= count,
              count > 0
        else {
            print("❌ GameEngine: Send troops failed: conditions not met")
            if let fromRegion = gameState.regions[fromRegionId] {
                print("ℹ️ GameEngine: From region details - owner: \(fromRegion.owner), troops: \(fromRegion.troopCount)")
            } else {
                print("ℹ️ GameEngine: From region not found")
            }
            
            if let toRegion = gameState.regions[toRegionId] {
                print("ℹ️ GameEngine: To region details - owner: \(toRegion.owner), troops: \(toRegion.troopCount)")
            } else {
                print("ℹ️ GameEngine: To region not found")
            }
            return false
        }
        
        // Копируем текущее состояние
        var updatedState = gameState
        
        // Создание нового перемещения войск
        let transfer = ArmyTransfer(fromRegionId: fromRegionId, toRegionId: toRegionId, count: count)
        
        // Уменьшение количества войск в исходном регионе
        var updatedFromRegion = fromRegion
        updatedFromRegion.troopCount -= count
        
        // Обновляем словари в состоянии
        updatedState.regions[fromRegionId] = updatedFromRegion
        updatedState.activeTransfers[transfer.id] = transfer
        
        // Применяем обновленное состояние
        gameState = updatedState
        
        print("✅ GameEngine: Successfully sent \(count) troops from \(fromRegionId) to \(toRegionId), remaining in source: \(updatedFromRegion.troopCount)")
        return true
    }
    
    // MARK: - Вспомогательные методы
    
    private func createLevelConfiguration(for level: Int) -> LevelConfiguration {
        switch level {
        case 1:
            return LevelConfiguration.createLevel1()
        default:
            return LevelConfiguration.createLevel1()
        }
    }
    
    // Метод для превью и отладки
    func loadState(_ state: GameState) {
        print("🧪 GameEngine: Loading test state")
        self.gameState = state
        self.lastAIUpdateTime = Date()
    }
}
