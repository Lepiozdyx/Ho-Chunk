import SwiftUI
import Combine

class Region: Identifiable, ObservableObject {
    let id = UUID()
    let shape: ImageResource
    let position: CGPoint
    let width: CGFloat
    let height: CGFloat
    
    @Published var owner: Player
    @Published var troopCount: Int
    
    var timer: AnyCancellable?
    
    init(shape: ImageResource, position: CGPoint, width: CGFloat = 180, height: CGFloat = 180, owner: Player, initialTroops: Int = 0) {
        self.shape = shape
        self.position = position
        self.width = width
        self.height = height
        self.owner = owner
        // Если регион нейтральный, устанавливаем 0 войск, иначе используем переданное значение
        self.troopCount = owner == .neutral ? 0 : initialTroops
        
        // Начинаем генерировать войска, если регион принадлежит игроку или CPU
        if owner != .neutral {
            startTroopGeneration()
        }
    }
    
    // Добавляем метод для очистки ресурсов при уничтожении объекта
    deinit {
        stopTroopGeneration()
    }
    
    func startTroopGeneration() {
        // Останавливаем существующий таймер, если есть
        stopTroopGeneration()
        
        // Генерируем 1 отряд в секунду для не-нейтральных регионов
        if owner != .neutral {
            timer = Timer.publish(every: 1.0, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in
                    guard let self = self else { return }
                    self.troopCount += 1
                    print("Регион \(self.owner): генерация войск, текущее количество: \(self.troopCount)")
                }
        }
    }
    
    func stopTroopGeneration() {
        timer?.cancel()
        timer = nil
    }
    
    func changeOwner(to newOwner: Player) {
        // Останавливаем текущую генерацию
        stopTroopGeneration()
        
        // Меняем владельца
        owner = newOwner
        print("Владелец региона изменился на \(newOwner)")
        
        // Запускаем или останавливаем генерацию войск в зависимости от нового владельца
        if newOwner != .neutral {
            startTroopGeneration()
        }
    }
}
