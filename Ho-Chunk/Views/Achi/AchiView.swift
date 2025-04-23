
import SwiftUI

struct AchiView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var viewModel = ShopViewModel()
    @StateObject private var svm = SettingsViewModel.shared
    
    var body: some View {
        ZStack {
            BgView(name: viewModel.currentTheme.imageResource, isBlur: false)
            
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
            .padding([.top, .horizontal])
            
            VStack {
                Image(.textUnderlay)
                    .resizable()
                    .frame(width: 300, height: 80)
                    .overlay {
                        Text("Achi")
                            .customFont(42)
                    }
                
                Spacer()
                
                HStack(spacing: 20) {
                    ForEach(viewModel.availableThemes) { theme in
                        // Achi items
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            viewModel.appViewModel = appViewModel
        }
    }
}

#Preview {
    AchiView()
        .environmentObject(AppViewModel())
}
