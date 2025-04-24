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
        self.troopCount = owner == .neutral ? 0 : initialTroops
        
        if owner != .neutral {
            startTroopGeneration()
        }
    }
    
    deinit {
        stopTroopGeneration()
    }
    
    func startTroopGeneration() {
        stopTroopGeneration()
        
        if owner != .neutral {
            timer = Timer.publish(every: 1.0, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in
                    guard let self = self else { return }
                    self.troopCount += 1
                }
        }
    }
    
    func stopTroopGeneration() {
        timer?.cancel()
        timer = nil
    }
    
    func changeOwner(to newOwner: Player) {
        stopTroopGeneration()
        
        owner = newOwner
        
        if newOwner != .neutral {
            startTroopGeneration()
        }
    }
}
