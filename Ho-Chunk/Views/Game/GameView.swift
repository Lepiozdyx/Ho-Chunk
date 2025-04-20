import SwiftUI

struct GameView: View {
    @StateObject private var viewModel = GameViewModel()
    @State private var dragStartRegion: Region? = nil
    @State private var dragEndPoint: CGPoint? = nil
    
    var body: some View {
        ZStack {
            // Фон
            BgView(name: .desertBg)
            
            // Верхний индикатор прогресса
            VStack {
                GameTopBarView(playerControlPercentage: viewModel.calculatePlayerControlPercentage())
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
        .onDisappear {
            // Останавливаем генерацию войск при скрытии представления
            viewModel.regions.forEach { $0.stopTroopGeneration() }
        }
    }
}

#Preview {
    GameView()
}
