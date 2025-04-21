
import SwiftUI

struct MenuView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    
    var body: some View {
        ZStack {
            BgView(name: .desertBg, isMenu: true)
            
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button {
                        appViewModel.startGame()
                    } label: {
                        ActionView(width: 320, height: 200, text: "start", textSize: 32, isQuill: true)
                    }
                }
                
                HStack {
                    Button {
                        appViewModel.navigateTo(.settings)
                    } label: {
                        ActionView(width: 200, height: 100, text: "settings", textSize: 24)
                    }
                    
                    Button {
                        appViewModel.navigateTo(.shop)
                    } label: {
                        ActionView(width: 200, height: 100, text: "shop", textSize: 24)
                    }
                    
                    Button {
                        appViewModel.navigateTo(.achievements)
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
    MenuView()
}
