import SwiftUI

struct ContentView: View {
    @StateObject private var appViewModel = AppViewModel()
    
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
                Text("Settings") // Заглушка для настроек
                    .environmentObject(appViewModel)
                
            case .shop:
                Text("Shop") // Заглушка для магазина
                    .environmentObject(appViewModel)
                
            case .achievements:
                Text("Achievements") // Заглушка для достижений
                    .environmentObject(appViewModel)
            }
        }
    }
}

#Preview {
    ContentView()
}
