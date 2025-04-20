import SwiftUI
import Combine

class MapViewModel: ObservableObject {
    // Опубликованные свойства для UI
    @Published var regions: [RegionModel] = []
    @Published var activeTransfers: [ArmyTransfer] = []
    @Published var selectedRegionId: UUID?
    @Published var dragOrigin: CGPoint?
    @Published var dragDestination: CGPoint?
    
    // Ссылка на игровой движок
    private let gameEngine: GameEngine
    
    // Отслеживаемые подписки для реактивности
    private var cancellables = Set<AnyCancellable>()
    
    // Флаг для предотвращения циклических обновлений
    private var isUpdatingFromEngine = false
    
    // Инициализатор
    init(gameEngine: GameEngine) {
        print("🗺️ MapViewModel: Initializing")
        self.gameEngine = gameEngine
        
        // Подписка на изменения в GameEngine
        setupSubscriptions()
    }
    
    // MARK: - Настройка подписок
    
    private func setupSubscriptions() {
        print("🗺️ MapViewModel: Setting up subscriptions")
        
        // Единственная подписка на изменения в обертке состояния игры
        gameEngine.$gameStateWrapper
            .receive(on: RunLoop.main)
            .sink { [weak self] wrapper in
                guard let self = self, !self.isUpdatingFromEngine else { return }
                
                self.isUpdatingFromEngine = true
                self.updateFromGameState(wrapper.state)
                self.isUpdatingFromEngine = false
            }
            .store(in: &cancellables)
    }
    
    // Метод обновления из состояния игры
    private func updateFromGameState(_ state: GameState) {
        // Сравниваем текущие войска с новыми
        let currentRegions = Dictionary(uniqueKeysWithValues:
            self.regions.map { ($0.id, $0) })
        
        let newRegions = Array(state.regions.values)
        
        // Проверяем, изменилось ли что-то существенно
        var regionsChanged = false
        var transfersChanged = false
        
        // Проверка изменений в регионах
        if newRegions.count != self.regions.count {
            regionsChanged = true
        } else {
            for region in newRegions {
                if let currentRegion = currentRegions[region.id] {
                    if currentRegion.troopCount != region.troopCount ||
                       currentRegion.owner != region.owner {
                        regionsChanged = true
                        break
                    }
                } else {
                    regionsChanged = true
                    break
                }
            }
        }
        
        // Проверка изменений в перемещениях войск
        let newTransfers = Array(state.activeTransfers.values)
        if newTransfers.count != self.activeTransfers.count {
            transfersChanged = true
        }
        
        // Обновляем только при реальных изменениях
        if regionsChanged {
            print("🔄 MapViewModel: Updating regions from game state")
            self.regions = newRegions
        }
        
        if transfersChanged {
            print("🔄 MapViewModel: Updating transfers from game state")
            self.activeTransfers = newTransfers
        }
        
        // Обновляем UI только если были изменения
        if regionsChanged || transfersChanged {
            self.objectWillChange.send()
        }
    }
    
    // MARK: - Методы для взаимодействия с регионами
    
    // Выбор региона (по тапу)
    func selectRegion(regionId: UUID) {
        print("👆 MapViewModel: Region selected: \(regionId)")
        
        // Проверяем, принадлежит ли регион игроку
        guard let region = regions.first(where: { $0.id == regionId }),
              region.owner == .player else {
            print("❌ MapViewModel: Region \(regionId) not owned by player, deselecting")
            selectedRegionId = nil
            return
        }
        
        // Устанавливаем выбранный регион
        selectedRegionId = regionId
        print("✅ MapViewModel: Player region selected: \(regionId), troops: \(region.troopCount)")
    }
    
    // Начало перетаскивания (для отправки войск)
    func startDrag(from position: CGPoint, regionId: UUID) {
        print("✋ MapViewModel: Drag started from region \(regionId) at position: \(position)")
        
        guard let region = regions.first(where: { $0.id == regionId }),
              region.owner == .player,
              region.troopCount > 0 else {
            print("❌ MapViewModel: Cannot drag from region \(regionId) - not owned by player or no troops")
            return
        }
        
        selectedRegionId = regionId
        dragOrigin = position
        dragDestination = position // Изначально совпадает с началом
    }
    
    // Обновление точки назначения при перетаскивании
    func updateDragDestination(to position: CGPoint) {
        dragDestination = position
    }
    
    // Завершение перетаскивания и отправка войск
    func endDrag(at position: CGPoint, screenSize: CGSize) -> Bool {
        print("👋 MapViewModel: Drag ended at position: \(position)")
        
        // Проверяем все необходимые условия перед отправкой
        guard let selectedId = selectedRegionId,
              let fromRegion = regions.first(where: { $0.id == selectedId }),
              fromRegion.owner == .player,
              fromRegion.troopCount > 0,
              let origin = dragOrigin,
              let destination = dragDestination else {
            print("❌ MapViewModel: Drag end failed: basic conditions not met")
            resetDragState()
            return false
        }
        
        // Проверяем, что перетаскивание было достаточно длинным
        let dx = destination.x - origin.x
        let dy = destination.y - origin.y
        let distanceSquared = dx * dx + dy * dy
        let minDistance: CGFloat = 100 // Минимальное квадратичное расстояние для валидного перетаскивания
        
        if distanceSquared < minDistance {
            print("❌ MapViewModel: Drag too short, distance²: \(distanceSquared) < min(\(minDistance))")
            resetDragState()
            return false
        }
        
        // Находим регион-назначение на основе позиции отпускания
        if let toRegion = findRegionAt(position: position, screenSize: screenSize) {
            if toRegion.id == selectedId {
                print("❌ MapViewModel: Cannot send troops to the same region")
                resetDragState()
                return false
            }
            
            print("🎯 MapViewModel: Target region found: \(toRegion.id), owner: \(toRegion.owner)")
            
            // Определяем количество войск для отправки (половина имеющихся)
            let troopsToSend = max(1, fromRegion.troopCount / 2)
            
            // Используем GameEngine для отправки войск
            let success = gameEngine.sendTroops(from: fromRegion.id, to: toRegion.id, count: troopsToSend)
            
            print(success ? "✅ MapViewModel: Troops sent successfully" : "❌ MapViewModel: Failed to send troops")
            
            // Сбрасываем состояние перетаскивания
            resetDragState()
            return success
        } else {
            print("❌ MapViewModel: No target region found at position: \(position)")
            resetDragState()
            return false
        }
    }
    
    // Сброс состояния перетаскивания
    func resetDragState() {
        print("🔄 MapViewModel: Resetting drag state")
        selectedRegionId = nil
        dragOrigin = nil
        dragDestination = nil
    }
    
    // MARK: - Вспомогательные методы
    
    // Нахождение региона по позиции на экране с учетом масштабирования
    func findRegionAt(position: CGPoint, screenSize: CGSize) -> RegionModel? {
        // Проверяем каждый регион
        for region in regions {
            let scaledPosition = CoordinateSpaceHelper.scalePosition(region.position, for: screenSize)
            let scaledSize = CoordinateSpaceHelper.scaleSize(region.size, for: screenSize)
            
            // Расчет расстояния от точки до центра региона
            let dx = position.x - scaledPosition.x
            let dy = position.y - scaledPosition.y
            let distanceSquared = dx * dx + dy * dy
            
            // Радиус региона (половина размера)
            let radiusSquared = (scaledSize / 2) * (scaledSize / 2)
            
            // Увеличиваем радиус захвата для лучшего обнаружения
            let extendedRadiusSquared = radiusSquared * 1.5
            
            // Если точка внутри региона, возвращаем его
            if distanceSquared <= extendedRadiusSquared {
                print("🔍 MapViewModel: Found region \(region.id) at position \(position), distance²: \(distanceSquared), radius²: \(extendedRadiusSquared)")
                return region
            }
        }
        
        // Если точного попадания нет, ищем ближайший регион в пределах разумного расстояния
        print("🔍 MapViewModel: No direct region hit, looking for closest")
        let maxSelectionDistance: CGFloat = 80.0 // Увеличенное значение для лучшего захвата
        var closestRegion: RegionModel? = nil
        var closestDistanceSquared: CGFloat = maxSelectionDistance * maxSelectionDistance
        
        for region in regions {
            let scaledPosition = CoordinateSpaceHelper.scalePosition(region.position, for: screenSize)
            let dx = position.x - scaledPosition.x
            let dy = position.y - scaledPosition.y
            let distanceSquared = dx * dx + dy * dy
            
            if distanceSquared < closestDistanceSquared {
                closestRegion = region
                closestDistanceSquared = distanceSquared
                print("🔍 MapViewModel: New closest region: \(region.id), distance²: \(distanceSquared)")
            }
        }
        
        if let region = closestRegion {
            print("🔍 MapViewModel: Found closest region \(region.id), distance²: \(closestDistanceSquared)")
            return region
        }
        
        print("❌ MapViewModel: No region found near position \(position)")
        return nil
    }
    
    // Получение позиции региона по его ID
    func getRegionPosition(regionId: UUID) -> CGPoint? {
        return regions.first(where: { $0.id == regionId })?.position
    }
}
