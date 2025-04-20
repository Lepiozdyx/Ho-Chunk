
import SwiftUI

struct MenuView: View {
    @ObservedObject var gameViewModel: GameViewModel
    
    var body: some View {
        ZStack {
            BgView(name: .desertBg, isMenu: true)
            
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button {
                        gameViewModel.navigateToGame()
                    } label: {
                        ActionView(width: 320, height: 200, text: "start", textSize: 32, isQuill: true)
                    }
                }
                
                HStack {
                    Button {
                        gameViewModel.navigateToSettings()
                    } label: {
                        ActionView(width: 200, height: 100, text: "settings", textSize: 24)
                    }
                    
                    Button {
                        gameViewModel.navigateToShop()
                    } label: {
                        ActionView(width: 200, height: 100, text: "shop", textSize: 24)
                    }
                    
                    Button {
                        gameViewModel.navigateToAchievements()
                    } label: {
                        ActionView(width: 200, height: 100, text: "achi", textSize: 24)
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    MenuView(gameViewModel: GameViewModel())
}
