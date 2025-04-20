import SwiftUI

struct PlayGameView: View {
    @ObservedObject var gameViewModel: GameViewModel
    @StateObject private var mapViewModel: MapViewModel
    
    // Флаг для отслеживания инициализации игры (сохраняется в @State)
    @State private var isViewInitialized = false
    
    init(gameViewModel: GameViewModel) {
        self._gameViewModel = ObservedObject(wrappedValue: gameViewModel)
        self._mapViewModel = StateObject(wrappedValue: MapViewModel(gameEngine: gameViewModel.gameEngine))
    }
    
    var body: some View {
        ZStack {
            BgView(name: .desertBg, isBlur: true)
            
            VStack {
                // Верхняя панель с прогрессом
                GameTopBarView(playerControlPercentage: gameViewModel.gameEngine.gameState.playerControlPercentage)
                    .id(gameViewModel.gameEngine.gameState.playerControlPercentage) // Принудительное обновление при изменении процента
                
                Spacer()
                
                // Основной вид карты - передаем только необходимые данные
                MapView(mapViewModel: mapViewModel)
                    .layoutPriority(1)
                
                Spacer()
            }
            
            // Кнопка паузы
            VStack {
                HStack {
                    Spacer()
                    
                    Button {
                        gameViewModel.navigateToPause()
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
            
            // Оверлеи победы/поражения (оптимизированные)
            if gameViewModel.gameEngine.gameState.isPlayerVictory {
                VictoryOverlayView(gameViewModel: gameViewModel)
            }
            
            if gameViewModel.gameEngine.gameState.isPlayerDefeat {
                DefeatOverlayView(gameViewModel: gameViewModel)
            }
        }
        .onAppear {
            print("📱 PlayGameView: appeared - checking initialization")
            
            // Инициализируем игру только один раз для этого экземпляра View
            if !isViewInitialized {
                print("📱 PlayGameView: First initialization")
                initializeGame()
                isViewInitialized = true
            } else {
                print("📱 PlayGameView: Already initialized, reappeared")
            }
        }
        .onDisappear {
            print("📱 PlayGameView: disappeared")
            // НЕ останавливаем игру при исчезновении - это порождает проблемы с двойной инициализацией
        }
    }
    
    private func initializeGame() {
        print("🎮 PlayGameView: Initializing game level \(gameViewModel.playerProgress.currentLevel)")
        
        // Запускаем игру через GameViewModel
        gameViewModel.startGame(level: gameViewModel.playerProgress.currentLevel)
    }
}

#Preview {
    let gameViewModel = GameViewModel()
    
    // Устанавливаем тестовое состояние для превью
    var previewState = GameState()
    previewState.regions = [
        UUID(): RegionModel(
            position: CGPoint(x: 100, y: 300),
            size: 120,
            shape: .vector1,
            owner: .player,
            troopCount: 5
        ),
        UUID(): RegionModel(
            position: CGPoint(x: 600, y: 300),
            size: 120,
            shape: .vector10,
            owner: .cpu,
            troopCount: 5
        ),
        UUID(): RegionModel(
            position: CGPoint(x: 300, y: 200),
            size: 110,
            shape: .vector3,
            owner: .neutral,
            troopCount: 0
        )
    ]
    
    // Загружаем состояние в движок
    DispatchQueue.main.async {
        gameViewModel.gameEngine.loadState(previewState)
    }
    
    return PlayGameView(gameViewModel: gameViewModel)
}
