
import SwiftUI

struct GameView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var viewModel = GameViewModel()
    @State private var dragStartRegion: Region? = nil
    @State private var dragEndPoint: CGPoint? = nil
    
    @State private var showingAchievementNotification: Bool = false
    @State private var unlockedAchievement: Achievement? = nil
    
    @StateObject private var scalingService = GameScalingService.shared
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                BgView(name: appViewModel.currentTheme.imageResource, isBlur: true)
                
                VStack {
                    GameTopBarView(playerControlPercentage: viewModel.calculatePlayerControlPercentage())
                    Spacer()
                    
                    Text("lvl \(appViewModel.gameLevel)")
                        .customFont(18)
                        .padding(.bottom, 4)
                }
                
                VStack {
                    HStack {
                        Button {
                            viewModel.togglePause(true)
                        } label: {
                            Image(.buttonCircle)
                                .resizable()
                                .frame(width: 50, height: 50)
                                .overlay {
                                    Image(.menu)
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                }
                        }
                        
                        Spacer()
                    }
                    Spacer()
                }
                .padding([.top, .horizontal])
                
                ZStack {
                    ForEach(viewModel.regions) { region in
                        RegionView(region: region, scalingService: scalingService)
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        if region.owner == .player && region.troopCount > 0 {
                                            if dragStartRegion == nil || dragStartRegion?.id == region.id {
                                                dragStartRegion = region
                                                
                                                let locationInGameSpace = CGPoint(
                                                    x: (value.location.x - scalingService.offsetX) / scalingService.scaleMultiplier,
                                                    y: (value.location.y - scalingService.offsetY) / scalingService.scaleMultiplier
                                                )
                                                dragEndPoint = locationInGameSpace
                                            }
                                        }
                                    }
                                    .onEnded { value in
                                        if let dragStartRegion = dragStartRegion {
                                            let locationInGameSpace = CGPoint(
                                                x: (value.location.x - scalingService.offsetX) / scalingService.scaleMultiplier,
                                                y: (value.location.y - scalingService.offsetY) / scalingService.scaleMultiplier
                                            )
                                            
                                            if let targetRegion = viewModel.regions.first(where: { region in
                                                let dx = locationInGameSpace.x - region.position.x
                                                let dy = locationInGameSpace.y - region.position.y
                                                let distance = sqrt(dx*dx + dy*dy)
                                                return distance < 90
                                            }), targetRegion.id != dragStartRegion.id {
                                                if dragStartRegion.troopCount > 0 {
                                                    let troopsToSend = dragStartRegion.troopCount
                                                    viewModel.sendArmy(from: dragStartRegion, to: targetRegion, count: troopsToSend)
                                                    
                                                    checkFirstStepAchievement()
                                                }
                                            }
                                        }
                                        
                                        dragStartRegion = nil
                                        dragEndPoint = nil
                                    }
                            )
                    }
                    
                    if let start = dragStartRegion?.position, let end = dragEndPoint {
                        ArrowView(start: start, end: end, color: .blue, scalingService: scalingService)
                    }
                    
                    ForEach(viewModel.armies) { army in
                        ArmyView(army: army, scalingService: scalingService)
                    }
                }
                
                if viewModel.showTutorialTips {
                    TipsView(showTips: $viewModel.showTutorialTips)
                        .transition(.opacity)
                        .animation(.easeInOut, value: viewModel.showTutorialTips)
                        .zIndex(100)
                }
                
                if viewModel.isPaused && !viewModel.showVictoryOverlay && !viewModel.showDefeatOverlay {
                    PauseView()
                        .environmentObject(appViewModel)
                        .zIndex(90)
                }
                
                if viewModel.showVictoryOverlay {
                    VictoryOverlayView()
                        .environmentObject(appViewModel)
                        .zIndex(90)
                        .onAppear {
                            checkFirstVictoryAchievement()
                        }
                }
                
                if viewModel.showDefeatOverlay {
                    DefeatOverlayView()
                        .environmentObject(appViewModel)
                        .zIndex(90)
                }
                
                if showingAchievementNotification, let achievement = unlockedAchievement {
                    AchiUnlockedView(achievement: achievement, isShowing: $showingAchievementNotification)
                        .zIndex(80)
                }
            }
            .onAppear {
                scalingService.calculateScaling(for: geometry.size)
                
                appViewModel.gameViewModel = viewModel
                viewModel.appViewModel = appViewModel
                
                viewModel.setupLevel(appViewModel.gameLevel)
            }
            .onChange(of: geometry.size) { newSize in
                scalingService.calculateScaling(for: newSize)
            }
            .onDisappear {
                viewModel.cleanupResources()
            }
        }
    }
    
    private func checkFirstStepAchievement() {
        var gameState = GameState.load()
        
        if gameState.regionsCaptureDcount > 0 &&
            !gameState.completedAchievements.contains("firstStep") &&
            !gameState.notifiedAchievements.contains("firstStep") {
            
            gameState.notifiedAchievements.append("firstStep")
            gameState.save()
            
            if let achievement = Achievement.allAchievements.first(where: { $0.id == "firstStep" }) {
                showAchievementNotification(achievement)
            }
        }
    }
    
    private func checkFirstVictoryAchievement() {
        var gameState = GameState.load()
        
        if gameState.gamesWonCount > 0 &&
            !gameState.completedAchievements.contains("firstVictory") &&
            !gameState.notifiedAchievements.contains("firstVictory") {
            
            gameState.notifiedAchievements.append("firstVictory")
            gameState.save()
            
            if let achievement = Achievement.allAchievements.first(where: { $0.id == "firstVictory" }) {
                showAchievementNotification(achievement)
            }
        }
    }
    
    private func showAchievementNotification(_ achievement: Achievement) {
        unlockedAchievement = achievement
        showingAchievementNotification = true
    }
}

#Preview {
    GameView()
        .environmentObject(AppViewModel())
}
