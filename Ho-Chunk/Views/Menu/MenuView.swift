
import SwiftUI

struct MenuView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var svm = SettingsViewModel.shared
    @State private var showDailyTaskView: Bool = false
    
    var body: some View {
        ZStack {
            BgView(name: appViewModel.currentTheme.imageResource, isMenu: true)
            
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button {
                        svm.play()
                        appViewModel.startGame()
                    } label: {
                        ActionView(width: 320, height: 150, text: "start", textSize: 32, isQuill: true)
                    }
                }
                
                HStack {
                    Button {
                        svm.play()
                        appViewModel.navigateTo(.settings)
                    } label: {
                        ActionView(width: 190, height: 90, text: "settings", textSize: 24)
                    }
                    
                    Button {
                        svm.play()
                        appViewModel.navigateTo(.shop)
                    } label: {
                        ActionView(width: 190, height: 90, text: "shop", textSize: 24)
                    }
                    
                    Button {
                        svm.play()
                        appViewModel.navigateTo(.achievements)
                    } label: {
                        ActionView(width: 190, height: 90, text: "achi", textSize: 24)
                    }
                    
                    Button {
                        svm.play()
                        showDailyTaskView = true
                    } label: {
                        ActionView(width: 190, height: 90, text: "Daily", textSize: 24)
                    }
                }
            }
            .padding()
            
            if showDailyTaskView {
                DailyTaskView(isPresented: $showDailyTaskView)
                    .environmentObject(appViewModel)
                    .transition(.opacity)
                    .animation(.easeInOut, value: showDailyTaskView)
                    .zIndex(100)
            }
        }
    }
}

#Preview {
    MenuView()
        .environmentObject(AppViewModel())
}
