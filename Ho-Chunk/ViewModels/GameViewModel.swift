
import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    @Published var regions: [Region] = []
    @Published var armies: [Army] = []
    @Published var dragInfo: (from: Region, to: CGPoint)? = nil
    @Published var currentLevel: Int = 1
    
    @Published var isGameOver: Bool = false
    @Published var isVictory: Bool = false
    @Published var isPaused: Bool = false
    
    @Published var showVictoryOverlay: Bool = false
    @Published var showDefeatOverlay: Bool = false
    
    @Published var isTutorialLevel: Bool = false
    @Published var showTutorialTips: Bool = false
    
    weak var appViewModel: AppViewModel?
    
    private var aiTimer: AnyCancellable?
    private var aiMoveInterval: TimeInterval = 3.0
    
    private var gameTimer: AnyCancellable?
    
    init(level: Int = 1) {
        self.currentLevel = level
        setupLevel(level)
    }
    
    deinit {
        cleanupResources()
    }
    
    func cleanupResources() {
        gameTimer?.cancel()
        gameTimer = nil
        
        aiTimer?.cancel()
        aiTimer = nil
        
        regions.forEach { $0.stopTroopGeneration() }
    }
    
    func setupLevel(_ levelId: Int) {
        cleanupResources()
        regions = []
        armies = []
        isGameOver = false
        isVictory = false
        isPaused = false
        showVictoryOverlay = false
        showDefeatOverlay = false
        
        isTutorialLevel = (levelId == 1)
        showTutorialTips = isTutorialLevel
        
        let level = GameLevel.getLevel(levelId)
        
        for regionDef in level.regions {
            var owner = regionDef.owner
            if isTutorialLevel && owner == .cpu {
                owner = .neutral
            }
            
            let region = Region(
                shape: regionDef.shape,
                position: regionDef.position,
                width: regionDef.width,
                height: regionDef.height,
                owner: owner,
                initialTroops: regionDef.initialTroops
            )
            regions.append(region)
        }
        
        aiMoveInterval = max(3.0 - Double(levelId) * 0.5, 1.0)
        
        startGameLoop()
        if !isTutorialLevel {
            startAI()
        }
    }
    
    func resetOverlays() {
        showVictoryOverlay = false
        showDefeatOverlay = false
    }
    
    private func startGameLoop() {
        gameTimer = Timer.publish(every: 0.05, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, !self.isPaused else { return }
                
                self.processArmyMovements()
                self.checkGameState()
            }
    }
    
    private func startAI() {
        aiTimer?.cancel()
        
        if isTutorialLevel {
            return
        }
        
        aiTimer = Timer.publish(every: aiMoveInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, !self.isPaused && !self.isGameOver else { return }
                
                self.performAIMove()
            }
    }
    
    func togglePause(_ paused: Bool) {
        isPaused = paused
    }
    
    private func checkGameState() {
        let playerRegions = regions.filter { $0.owner == .player }.count
        let cpuRegions = regions.filter { $0.owner == .cpu }.count
        let neutralRegions = regions.filter { $0.owner == .neutral }.count
        
        if playerRegions == 0 && !isGameOver {
            isGameOver = true
            isVictory = false
            showDefeatOverlay = true
            isPaused = true
            
            DispatchQueue.main.async {
                self.appViewModel?.showDefeat()
            }
        } else if cpuRegions == 0 && neutralRegions == 0 && !isGameOver {
            isGameOver = true
            isVictory = true
            showVictoryOverlay = true
            isPaused = true
            
            DispatchQueue.main.async {
                self.appViewModel?.showVictory()
            }
        }
    }
    
    private func performAIMove() {
        let cpuRegions = regions.filter { $0.owner == .cpu }
        
        if cpuRegions.isEmpty {
            return
        }
        
        let playerRegions = regions.filter { $0.owner == .player }
        let neutralRegions = regions.filter { $0.owner == .neutral }
        
        for cpuRegion in cpuRegions {
            if cpuRegion.troopCount < 5 {
                continue
            }
            
            if !neutralRegions.isEmpty {
                if let targetRegion = findClosestRegion(from: cpuRegion, targets: neutralRegions) {
                    sendArmy(from: cpuRegion, to: targetRegion, count: cpuRegion.troopCount)
                    break
                }
            }
            
            if !playerRegions.isEmpty {
                if let weakestPlayerRegion = playerRegions.min(by: { $0.troopCount < $1.troopCount }) {
                    if cpuRegion.troopCount > weakestPlayerRegion.troopCount + 2 {
                        sendArmy(from: cpuRegion, to: weakestPlayerRegion, count: cpuRegion.troopCount)
                        break
                    }
                }
            }
        }
    }
    
    private func findClosestRegion(from source: Region, targets: [Region]) -> Region? {
        return targets.min { a, b in
            let distanceToA = distance(from: source.position, to: a.position)
            let distanceToB = distance(from: source.position, to: b.position)
            return distanceToA < distanceToB
        }
    }
    
    private func distance(from a: CGPoint, to b: CGPoint) -> CGFloat {
        let dx = b.x - a.x
        let dy = b.y - a.y
        return sqrt(dx*dx + dy*dy)
    }
    
    private func processArmyMovements() {
        let currentTime = Date()
        var arrivedArmies: [Army] = []
        
        for army in armies {
            if army.hasArrived(at: currentTime) {
                arrivedArmies.append(army)
                processCombat(army: army)
            }
        }
        
        if !arrivedArmies.isEmpty {
            DispatchQueue.main.async {
                self.armies.removeAll { army in
                    arrivedArmies.contains { $0.id == army.id }
                }
            }
        }
    }
    
    // Achievement Tracking
    
    private func updateAchievementsAfterCapture(from previousOwner: Player, to newOwner: Player) {
        guard let appViewModel = appViewModel else { return }
        
        if newOwner == .player && previousOwner != .player {
            var gameState = GameState.load()
            
            gameState.regionsCaptureDcount += 1
            
            if gameState.regionsCaptureDcount == 1 &&
               !gameState.completedAchievements.contains("firstStep") {
                //
            }
            
            gameState.save()
            
            appViewModel.gameState = gameState
        }
    }
    
    private func processCombat(army: Army) {
        let targetRegion = army.toRegion
        
        if targetRegion.owner == army.owner {
            targetRegion.troopCount += army.count
        } else {
            if army.count > targetRegion.troopCount {
                
                let remainingTroops = army.count - targetRegion.troopCount
                
                let previousOwner = targetRegion.owner
                
                DispatchQueue.main.async {
                    targetRegion.changeOwner(to: army.owner)
                    targetRegion.troopCount = remainingTroops
                    
                    if army.owner == .player {
                        self.updateAchievementsAfterCapture(from: previousOwner, to: army.owner)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    targetRegion.troopCount -= army.count
                }
            }
        }
    }
    
    func sendArmy(from: Region, to: Region, count: Int) {
        if count <= 0 || count > from.troopCount {
            return
        }
        
        from.troopCount -= count
        
        let army = Army(
            owner: from.owner,
            count: count,
            fromRegion: from,
            toRegion: to,
            startTime: Date()
        )
        
        armies.append(army)
    }
    
    func calculatePlayerControlPercentage() -> Double {
        let totalRegions = regions.count
        guard totalRegions > 0 else { return 0.5 }
        
        let playerRegions = regions.filter { $0.owner == .player }.count
        return Double(playerRegions) / Double(totalRegions)
    }
}
