
import SwiftUI

struct GameView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var viewModel = GameViewModel()
    @State private var dragStartRegion: Region? = nil
    @State private var dragEndPoint: CGPoint? = nil
    
    var body: some View {
        ZStack {
            // Фон
            BgView(name: .desertBg, isBlur: true)
            
            // Верхний индикатор прогресса
            VStack {
                GameTopBarView(playerControlPercentage: viewModel.calculatePlayerControlPercentage())
                
                // Кнопка паузы
                HStack {
                    Spacer()
                    
                    Button {
                        viewModel.togglePause(true)
                        appViewModel.pauseGame()
                    } label: {
                        Image(systemName: "pause.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding()
                }
                
                Spacer()
            }
            
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
        }
        .onAppear {
            // При появлении инициализируем уровень
            viewModel.setupLevel(appViewModel.gameLevel)
            viewModel.togglePause(false)
        }
        .onDisappear {
            // При исчезновении останавливаем таймеры и очищаем ресурсы
            viewModel.togglePause(true)
            viewModel.cleanupResources()
        }
        .onChange(of: viewModel.isGameOver) { isOver in
            if isOver {
                // Обработка окончания игры
                viewModel.togglePause(true)
                
                if viewModel.isVictory {
                    appViewModel.showVictory()
                } else {
                    appViewModel.showDefeat()
                }
            }
        }
    }
}

#Preview {
    GameView()
        .environmentObject(AppViewModel())
}
