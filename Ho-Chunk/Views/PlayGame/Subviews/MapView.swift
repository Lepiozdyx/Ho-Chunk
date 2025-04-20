import SwiftUI

struct MapView: View {
    @ObservedObject var mapViewModel: MapViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Отрисовка всех регионов
                ForEach(mapViewModel.regions) { region in
                    RegionViewWrapper(
                        region: region,
                        viewModel: mapViewModel,
                        geometry: geometry
                    )
                }
                
                // Отрисовка активных перемещений войск
                ForEach(mapViewModel.activeTransfers) { transfer in
                    if let fromPosition = mapViewModel.getRegionPosition(regionId: transfer.fromRegionId),
                       let toPosition = mapViewModel.getRegionPosition(regionId: transfer.toRegionId) {
                        
                        let scaledFromPos = CoordinateSpaceHelper.scalePosition(fromPosition, for: geometry.size)
                        let scaledToPos = CoordinateSpaceHelper.scalePosition(toPosition, for: geometry.size)
                        
                        // Отрисовка анимации перемещения войск
                        ArmyTransferView(
                            from: scaledFromPos,
                            to: scaledToPos,
                            progress: transfer.progress,
                            count: transfer.count,
                            fromRegionId: transfer.fromRegionId,
                            regions: mapViewModel.regions
                        )
                    }
                }
                
                // Отрисовка линии перетаскивания
                if let origin = mapViewModel.dragOrigin, let destination = mapViewModel.dragDestination {
                    DragArrowView(from: origin, to: destination)
                }
            }
        }
    }
}

// Отдельный компонент для обертки региона с жестами
struct RegionViewWrapper: View {
    let region: RegionModel
    let viewModel: MapViewModel
    let geometry: GeometryProxy
    
    var body: some View {
        let scaledPosition = CoordinateSpaceHelper.scalePosition(region.position, for: geometry.size)
        let scaledSize = CoordinateSpaceHelper.scaleSize(region.size, for: geometry.size)
        
        RegionView(
            name: region.imageResource,
            size: scaledSize,
            fractionLogo: region.owner.logo,
            fractionColor: region.owner.color,
            amount: region.troopCount
        )
        .position(scaledPosition)
        .overlay(
            // Подсветка выбранного региона
            Circle()
                .stroke(
                    viewModel.selectedRegionId == region.id ? Color.white : Color.clear,
                    lineWidth: 2
                )
                .frame(
                    width: scaledSize + 5,
                    height: scaledSize + 5
                )
        )
        // Обработчик тапа
        .onTapGesture {
            viewModel.selectRegion(regionId: region.id)
        }
        // Обработчик перетаскивания
        .gesture(
            DragGesture(minimumDistance: 5)
                .onChanged { value in
                    // Если это игрока регион и перетаскивание только началось
                    if region.owner == .player && viewModel.dragOrigin == nil {
                        viewModel.startDrag(from: scaledPosition, regionId: region.id)
                    }
                    
                    // Если уже перетаскиваем и это выбранный регион
                    if viewModel.selectedRegionId == region.id {
                        viewModel.updateDragDestination(to: value.location)
                    }
                }
                .onEnded { value in
                    // Если выбран этот регион
                    if viewModel.selectedRegionId == region.id {
                        let _ = viewModel.endDrag(at: value.location, screenSize: geometry.size)
                    }
                }
        )
    }
}

// Компонент для отрисовки стрелки при перетаскивании
struct DragArrowView: View {
    let from: CGPoint
    let to: CGPoint
    
    var body: some View {
        ZStack {
            // Линия от начала до конца
            Path { path in
                path.move(to: from)
                path.addLine(to: to)
            }
            .stroke(Color.white, lineWidth: 2)
            
            // Наконечник стрелки
            Path { path in
                let angle = atan2(to.y - from.y, to.x - from.x)
                let arrowLength: CGFloat = 10
                
                let arrowPoint1 = CGPoint(
                    x: to.x - arrowLength * cos(angle - .pi/6),
                    y: to.y - arrowLength * sin(angle - .pi/6)
                )
                let arrowPoint2 = CGPoint(
                    x: to.x - arrowLength * cos(angle + .pi/6),
                    y: to.y - arrowLength * sin(angle + .pi/6)
                )
                
                path.move(to: to)
                path.addLine(to: arrowPoint1)
                path.move(to: to)
                path.addLine(to: arrowPoint2)
            }
            .stroke(Color.white, lineWidth: 2)
        }
    }
}

#Preview {
    // Создаем игровой движок для превью
    let gameEngine = GameEngine()
    
    // Добавляем тестовые регионы
    var previewState = GameState()
    previewState.regions = [
        UUID(): RegionModel(
            position: CGPoint(x: 150, y: 150),
            size: 120,
            shape: .vector1,
            owner: .player,
            troopCount: 15
        ),
        UUID(): RegionModel(
            position: CGPoint(x: 350, y: 250),
            size: 110,
            shape: .vector2,
            owner: .neutral,
            troopCount: 5
        ),
        UUID(): RegionModel(
            position: CGPoint(x: 550, y: 150),
            size: 120,
            shape: .vector3,
            owner: .cpu,
            troopCount: 10
        )
    ]
    
    // Устанавливаем состояние в движок
    DispatchQueue.main.async {
        gameEngine.loadState(previewState)
    }
    
    // Создаем MapViewModel с нашим движком
    let mapViewModel = MapViewModel(gameEngine: gameEngine)
    
    return MapView(mapViewModel: mapViewModel)
        .frame(width: 800, height: 400)
        .background(Color.gray.opacity(0.2))
}
