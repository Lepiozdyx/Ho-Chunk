
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var svm = SettingsViewModel.shared
    
    var body: some View {
        ZStack {
            BgView(name: .desertBg, isBlur: false)
            
            VStack {
                HStack {
                    Button {
                        svm.play()
                        appViewModel.goToMenu()
                    } label: {
                        Image(.buttonCircle)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .overlay {
                                Image(.menu)
                                    .resizable()
                                    .frame(width: 30, height: 30)
                            }
                    }
                    
                    Spacer()
                }
                Spacer()
            }
            .padding([.top, .leading])
            
            VStack {
                Image(.textUnderlay)
                    .resizable()
                    .frame(width: 300, height: 80)
                    .overlay {
                        Text("SETTINGS")
                            .customFont(42)
                    }
                
                Spacer()
                
                HStack {
                    Image(.frame)
                        .resizable()
                        .frame(width: 220, height: 150)
                        .overlay {
                            VStack {
                                Text("Mute")
                                    .customFont(16, color: .white)
                                
                                ToggleButton(isON: svm.soundIsOn) {
                                    svm.play()
                                    svm.toggleSound()                           }
                            }
                        }
                    
                    Image(.frame)
                        .resizable()
                        .frame(width: 220, height: 150)
                        .overlay {
                            VStack {
                                Text("Music")
                                    .customFont(16, color: .white)
                                
                                ToggleButton(isON: svm.musicIsOn) {
                                    svm.play()
                                    svm.toggleMusic()                           }
                            }
                        }
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppViewModel())
}
