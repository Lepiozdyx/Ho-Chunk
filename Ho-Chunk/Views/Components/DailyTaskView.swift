
import SwiftUI

struct DailyTaskView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var svm = SettingsViewModel.shared

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
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
                        Text("Daily")
                            .customFont(42)
                    }
                
                Spacer()
                
                Button {
                    svm.play()
                    // get reward action
                    appViewModel.goToMenu()
                } label: {
                    Image(.chestClose)
                        .resizable()
                        .frame(width: 200, height: 170)
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    DailyTaskView()
        .environmentObject(AppViewModel())
}
