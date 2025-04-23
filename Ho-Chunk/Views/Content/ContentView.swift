import SwiftUI

struct ContentView: View {
    @StateObject private var appViewModel = AppViewModel()
    @StateObject private var settings = SettingsViewModel.shared
    private var orientation = OrientationViewModel.shared
    
    @Environment(\.scenePhase) private var phase
    
    var body: some View {
        ZStack {
            switch appViewModel.currentScreen {
            case .menu:
                MenuView()
                    .environmentObject(appViewModel)
                    .onAppear {
                        orientation.lockLandscape()
                    }
                
            case .game:
                GameView()
                    .environmentObject(appViewModel)
                    .onAppear {
                        orientation.lockLandscape()
                    }
                
            case .settings:
                SettingsView()
                    .environmentObject(appViewModel)
                    .onAppear {
                        orientation.lockLandscape()
                    }
                
            case .shop:
                ShopView()
                    .environmentObject(appViewModel)
                    .onAppear {
                        orientation.lockLandscape()
                    }
                
            case .achievements:
                AchiView()
                    .environmentObject(appViewModel)
                    .onAppear {
                        orientation.lockLandscape()
                    }
            }
        }
        .onAppear {
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
