
import SwiftUI

struct ShopView: View {
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
                    
                    Image(.coinCounter)
                        .resizable()
                        .frame(width: 170, height: 55)
                        .overlay {
                            Text("\(appViewModel.coins)")
                                .customFont(18)
                                .offset(x: 10, y: 3)
                        }
                }
                Spacer()
            }
            .padding([.top, .leading])
            
            VStack {
                Image(.textUnderlay)
                    .resizable()
                    .frame(width: 300, height: 80)
                    .overlay {
                        Text("SHOP")
                            .customFont(42)
                    }
                
                Spacer()
                
                HStack {
                    // Extract to reusable view
                    VStack {
                        Image(.frame)
                            .resizable()
                            .frame(maxWidth: 200, maxHeight: 200)
                            .overlay {
                                Image(.desertBg)
                                    .resizable()
                                    .padding(6)
                            }
                        
                        Button {
                            svm.play()
                            // by and setup bg image to GameView() action
                        } label: {
                            Image(.button)
                                .resizable()
                                .frame(maxWidth: 200, maxHeight: 75)
                                .overlay {
                                    HStack {
                                        Image(.coin)
                                            .resizable()
                                            .frame(width: 25, height: 25)
                                        
                                        Text("100")
                                            .customFont(14)
                                    }
                                    .offset(y: -5)
                                }
                        }
                    }
                    
                    Image(.frame)
                        .resizable()
                        .frame(maxWidth: 200, maxHeight: 200)
                        .overlay {
                            Image(.nightBg)
                                .resizable()
                                .padding(6)
                        }
                    
                    Image(.frame)
                        .resizable()
                        .frame(maxWidth: 200, maxHeight: 200)
                        .overlay {
                            Image(.fallBg)
                                .resizable()
                                .padding(6)
                        }
                    
                    Image(.frame)
                        .resizable()
                        .frame(maxWidth: 200, maxHeight: 200)
                        .overlay {
                            Image(.wildwest1Bg)
                                .resizable()
                                .padding(6)
                        }
                    
                    Image(.frame)
                        .resizable()
                        .frame(maxWidth: 200, maxHeight: 200)
                        .overlay {
                            Image(.wildwest2Bg)
                                .resizable()
                                .padding(6)
                        }
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    ShopView()
        .environmentObject(AppViewModel())
}
