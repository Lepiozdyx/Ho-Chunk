import SwiftUI

struct ContentView: View {
    @StateObject private var gameViewModel = GameViewModel()
    
    // Отслеживаем последний state для отладки
    @State private var lastNavState: NavigationState = .menu
    
    var body: some View {
        ZStack {
            switch gameViewModel.navigationState {
            case .menu:
                MenuView(gameViewModel: gameViewModel)
                    .transition(.opacity)
                    .onAppear {
                        if lastNavState != .menu {
                            print("📌 NAVIGATION: Menu View appeared (from \(lastNavState))")
                            lastNavState = .menu
                        }
                    }
            case .game:
                PlayGameView(gameViewModel: gameViewModel)
                    .transition(.opacity)
                    .onAppear {
                        if lastNavState != .game {
                            print("📌 NAVIGATION: Play Game View appeared (from \(lastNavState))")
                            lastNavState = .game
                        }
                    }
            case .pause:
                ZStack {
                    // Показываем игру на заднем плане (без инициализации)
                    PlayGameView(gameViewModel: gameViewModel)
                    
                    PauseView(gameViewModel: gameViewModel)
                        .transition(.opacity)
                        .onAppear {
                            if lastNavState != .pause {
                                print("📌 NAVIGATION: Pause View appeared (from \(lastNavState))")
                                lastNavState = .pause
                            }
                        }
                }
            case .settings:
                Text("Settings Screen")
                    .onAppear {
                        if lastNavState != .settings {
                            print("📌 NAVIGATION: Settings View appeared (from \(lastNavState))")
                            lastNavState = .settings
                        }
                    }
            case .shop:
                Text("Shop Screen")
                    .onAppear {
                        if lastNavState != .shop {
                            print("📌 NAVIGATION: Shop View appeared (from \(lastNavState))")
                            lastNavState = .shop
                        }
                    }
            case .achievements:
                Text("Achievements Screen")
                    .onAppear {
                        if lastNavState != .achievements {
                            print("📌 NAVIGATION: Achievements View appeared (from \(lastNavState))")
                            lastNavState = .achievements
                        }
                    }
            case .tutorial:
                Text("Tutorial Screen")
                    .onAppear {
                        if lastNavState != .tutorial {
                            print("📌 NAVIGATION: Tutorial View appeared (from \(lastNavState))")
                            lastNavState = .tutorial
                        }
                    }
            }
        }
        .animation(.easeInOut, value: gameViewModel.navigationState)
    }
}

#Preview {
    ContentView()
}
