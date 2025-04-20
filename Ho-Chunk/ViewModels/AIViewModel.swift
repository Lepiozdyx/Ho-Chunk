
import Foundation

class AIViewModel {
    private var gameState: GameState
    private let aiUpdateInterval: TimeInterval
    
    init(gameState: GameState, aiUpdateInterval: TimeInterval) {
        self.gameState = gameState
        self.aiUpdateInterval = aiUpdateInterval
    }
    
    // Основной метод, который вызывается для совершения хода AI
    func makeMove(completion: @escaping (GameState) -> Void) {
        // Копируем текущее состояние игры
        var updatedState = gameState
        
        // Если у CPU нет регионов, прекращаем выполнение
        guard !getCpuRegions().isEmpty else {
            completion(updatedState)
            return
        }
        
        // Выбор стратегии в зависимости от уровня
        switch updatedState.gameLevel {
        case 1:
            // Для первого уровня (обучающий) - простая стратегия
            applyBasicStrategy(to: &updatedState)
        case 2:
            // Для второго уровня - чуть более агрессивная стратегия
            applyIntermediateStrategy(to: &updatedState)
        case 3, 4:
            // Для третьего и четвертого уровней - продвинутая стратегия
            applyAdvancedStrategy(to: &updatedState)
        default:
            // По умолчанию используем базовую стратегию
            applyBasicStrategy(to: &updatedState)
        }
        
        // Обновляем локальное состояние и возвращаем обновленное состояние
        gameState = updatedState
        completion(updatedState)
    }
    
    // MARK: - Стратегии AI
    
    // Базовая стратегия - атаковать ближайший регион с наименьшим количеством войск
    private func applyBasicStrategy(to state: inout GameState) {
        // Получаем все регионы CPU и потенциальные цели
        let cpuRegions = getCpuRegions(from: state)
        let targetRegions = getPotentialTargets(from: state)
        
        guard !cpuRegions.isEmpty, !targetRegions.isEmpty else { return }
        
        // Находим регион CPU с наибольшим количеством войск
        guard let strongestCpuRegion = cpuRegions.max(by: { $0.troopCount < $1.troopCount }) else { return }
        
        // Находим ближайший регион-цель с наименьшим количеством войск
        guard let weakestTargetRegion = targetRegions.min(by: { $0.troopCount < $1.troopCount }) else { return }
        
        // Определяем, сколько войск отправить
        // Для базовой стратегии отправляем 70% имеющихся войск, если их достаточно для захвата
        let troopsNeeded = weakestTargetRegion.troopCount + 1 // Минимум нужно для захвата
        let maxTroopsToSend = Int(Double(strongestCpuRegion.troopCount) * 0.7)
        let troopsToSend = min(max(troopsNeeded, maxTroopsToSend), strongestCpuRegion.troopCount)
        
        // Если у нас достаточно войск для отправки, создаем перемещение
        if troopsToSend > 0 && troopsToSend <= strongestCpuRegion.troopCount {
            let transfer = ArmyTransfer(
                fromRegionId: strongestCpuRegion.id,
                toRegionId: weakestTargetRegion.id,
                count: troopsToSend
            )
            
            // Уменьшаем количество войск в исходном регионе
            state.regions[strongestCpuRegion.id]?.troopCount -= troopsToSend
            
            // Добавляем перемещение в активные
            state.activeTransfers[transfer.id] = transfer
        }
    }
    
    // Промежуточная стратегия - более агрессивная, с учетом соседних регионов
    private func applyIntermediateStrategy(to state: inout GameState) {
        // Промежуточная стратегия будет реализована позже
        // Пока используем базовую стратегию
        applyBasicStrategy(to: &state)
    }
    
    // Продвинутая стратегия - использует накопление войск и массовые атаки
    private func applyAdvancedStrategy(to state: inout GameState) {
        // Продвинутая стратегия будет реализована позже
        // Пока используем базовую стратегию
        applyBasicStrategy(to: &state)
    }
    
    // MARK: - Вспомогательные методы
    
    // Получение всех регионов CPU
    private func getCpuRegions(from state: GameState = GameState()) -> [RegionModel] {
        let stateToUse = state.regions.isEmpty ? gameState : state
        return stateToUse.regions.values.filter { $0.owner == .cpu }
    }
    
    // Получение всех потенциальных целей (не CPU регионы)
    private func getPotentialTargets(from state: GameState = GameState()) -> [RegionModel] {
        let stateToUse = state.regions.isEmpty ? gameState : state
        return stateToUse.regions.values.filter { $0.owner != .cpu }
    }
    
    // Расчет расстояния между двумя регионами (для определения "соседства")
    private func distance(from region1: RegionModel, to region2: RegionModel) -> CGFloat {
        let dx = region1.position.x - region2.position.x
        let dy = region1.position.y - region2.position.y
        return sqrt(dx * dx + dy * dy)
    }
    
    // Определение, является ли регион соседним
    private func isNeighboring(region1: RegionModel, region2: RegionModel) -> Bool {
        // Для простоты считаем регионы соседними, если расстояние между их центрами
        // не превышает определенного порога (например, сумму их размеров)
        let threshold = (region1.size + region2.size) * 0.8
        return distance(from: region1, to: region2) <= threshold
    }
}
