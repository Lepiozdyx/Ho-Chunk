import SwiftUI

struct ContentView: View {
    @StateObject private var appViewModel = AppViewModel()
    @StateObject private var settings = SettingsViewModel.shared
    
    @Environment(\.scenePhase) private var phase
    
    var body: some View {
        ZStack {
            switch appViewModel.currentScreen {
            case .menu:
                MenuView()
                    .environmentObject(appViewModel)
                
            case .game:
                GameView()
                    .environmentObject(appViewModel)
                
            case .settings:
                SettingsView()
                    .environmentObject(appViewModel)
                
            case .shop:
                ShopView()
                    .environmentObject(appViewModel)
                
            case .achievements:
                Text("Achievements") // Заглушка для достижений
                    .environmentObject(appViewModel)
            }
        }
        .onAppear {
            // Проверяем ежедневный бонус при запуске
            appViewModel.checkDailyBonus()
            
            if settings.musicIsOn {
                settings.playMusic()
            }
        }
        .onChange(of: phase) { newPhase in
            switch newPhase {
            case .active:
                settings.playMusic()
            case .background, .inactive:
                settings.stopMusic()
            @unknown default:
                break
            }
        }
    }
}

#Preview {
    ContentView()
}
