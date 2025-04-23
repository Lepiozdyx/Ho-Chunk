
import SwiftUI

struct GameView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var viewModel = GameViewModel()
    @State private var dragStartRegion: Region? = nil
    @State private var dragEndPoint: CGPoint? = nil
    
    // Состояние для отображения уведомлений о достижениях
    @State private var showingAchievementNotification: Bool = false
    @State private var unlockedAchievement: Achievement? = nil
    
    var body: some View {
        ZStack {
            // Фон - используем текущую выбранную тему
            BgView(name: appViewModel.currentTheme.imageResource, isBlur: true)
            
            // Верхний индикатор прогресса
            VStack {
                GameTopBarView(playerControlPercentage: viewModel.calculatePlayerControlPercentage())
                Spacer()
                
                Text("lvl \(appViewModel.gameLevel)")
                    .customFont(18)
                    .padding(.bottom, 4)
            }
            
            // Кнопка паузы
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
            
            // Регионы
            ForEach(viewModel.regions) { region in
                RegionView(region: region)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                // Разрешаем перетаскивание только из регионов игрока
                                if region.owner == .player && region.troopCount > 0 {
                                    if dragStartRegion == nil || dragStartRegion?.id == region.id {
                                        dragStartRegion = region
                                        dragEndPoint = value.location
                                    }
                                }
                            }
                            .onEnded { value in
                                // Находим целевой регион, если он есть
                                if let dragStartRegion = dragStartRegion {
                                    let endPoint = value.location
                                    
                                    // Проверяем, перетащили ли мы на регион
                                    if let targetRegion = viewModel.regions.first(where: { region in
                                        let dx = endPoint.x - region.position.x
                                        let dy = endPoint.y - region.position.y
                                        let distance = sqrt(dx*dx + dy*dy)
                                        return distance < 90 // Радиус для проверки попадания
                                    }), targetRegion.id != dragStartRegion.id {
                                        // Проверяем, есть ли войска для отправки
                                        if dragStartRegion.troopCount > 0 {
                                            // Отправляем ВСЕ войска по ТЗ
                                            let troopsToSend = dragStartRegion.troopCount
                                            viewModel.sendArmy(from: dragStartRegion, to: targetRegion, count: troopsToSend)
                                            
                                            // Проверяем достижение First Step после отправки армии
                                            checkFirstStepAchievement()
                                        }
                                    }
                                }
                                
                                // Сбрасываем состояние перетаскивания
                                dragStartRegion = nil
                                dragEndPoint = nil
                            }
                    )
            }
            
            // Рисуем стрелку во время перетаскивания
            if let start = dragStartRegion?.position, let end = dragEndPoint {
                ArrowView(start: start, end: end, color: .blue)
            }
            
            // Перемещающиеся армии
            ForEach(viewModel.armies) { army in
                ArmyView(army: army)
            }
            
            // Обучающие подсказки (только если включены)
            if viewModel.showTutorialTips {
                TipsView(showTips: $viewModel.showTutorialTips)
                    .transition(.opacity)
                    .animation(.easeInOut, value: viewModel.showTutorialTips)
                    .zIndex(100) // Поверх всего остального
            }
            
            // Показываем оверлей паузы
            if viewModel.isPaused && !viewModel.showVictoryOverlay && !viewModel.showDefeatOverlay {
                PauseView()
                    .environmentObject(appViewModel)
                    .zIndex(90)
            }
            
            // Показываем оверлей победы
            if viewModel.showVictoryOverlay {
                VictoryOverlayView()
                    .environmentObject(appViewModel)
                    .zIndex(90)
                    .onAppear {
                        // Проверяем достижение First Victory при победе
                        checkFirstVictoryAchievement()
                    }
            }
            
            // Показываем оверлей поражения
            if viewModel.showDefeatOverlay {
                DefeatOverlayView()
                    .environmentObject(appViewModel)
                    .zIndex(90)
            }
            
            // Отображаем уведомление о разблокированном достижении
            if showingAchievementNotification, let achievement = unlockedAchievement {
                AchiUnlockedView(achievement: achievement, isShowing: $showingAchievementNotification)
                    .zIndex(110) // Поверх всех остальных элементов
            }
        }
        .onAppear {
            // Сохраняем ссылку на viewModel в appViewModel и устанавливаем связь с AppViewModel
            appViewModel.gameViewModel = viewModel
            viewModel.appViewModel = appViewModel
            
            // При появлении инициализируем уровень
            viewModel.setupLevel(appViewModel.gameLevel)
        }
        .onDisappear {
            // При исчезновении останавливаем таймеры и очищаем ресурсы
            viewModel.cleanupResources()
        }
    }
    
    // MARK: - Achievement Checking Methods
    
    // Проверяет достижение "First Step"
    private func checkFirstStepAchievement() {
        let gameState = GameState.load()
        
        // Проверяем выполнение достижения, но не было ли оно уже получено
        if gameState.regionsCaptureDcount > 0 && !gameState.completedAchievements.contains("firstStep") {
            // Находим соответствующее достижение
            if let achievement = Achievement.allAchievements.first(where: { $0.id == "firstStep" }) {
                // Показываем уведомление
                showAchievementNotification(achievement)
            }
        }
    }
    
    // Проверяет достижение "First Victory"
    private func checkFirstVictoryAchievement() {
        let gameState = GameState.load()
        
        // Проверяем выполнение достижения, но не было ли оно уже получено
        if gameState.gamesWonCount > 0 && !gameState.completedAchievements.contains("firstVictory") {
            // Находим соответствующее достижение
            if let achievement = Achievement.allAchievements.first(where: { $0.id == "firstVictory" }) {
                // Показываем уведомление
                showAchievementNotification(achievement)
            }
        }
    }
    
    // Общий метод для отображения уведомления о разблокированном достижении
    private func showAchievementNotification(_ achievement: Achievement) {
        unlockedAchievement = achievement
        showingAchievementNotification = true
    }
}

#Preview {
    GameView()
        .environmentObject(AppViewModel())
}
