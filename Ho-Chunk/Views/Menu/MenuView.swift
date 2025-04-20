
import SwiftUI

struct MenuView: View {
    
    var body: some View {
        ZStack {
            BgView(name: .desertBg, isMenu: true)
            
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button {
                        
                    } label: {
                        ActionView(width: 320, height: 200, text: "start", textSize: 32, isQuill: true)
                    }
                }
                
                HStack {
                    Button {
                        
                    } label: {
                        ActionView(width: 200, height: 100, text: "settings", textSize: 24)
                    }
                    
                    Button {
                        
                    } label: {
                        ActionView(width: 200, height: 100, text: "shop", textSize: 24)
                    }
                    
                    Button {
                        
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
