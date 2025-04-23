
import SwiftUI

struct DailyTaskView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var svm = SettingsViewModel.shared
    @Binding var isPresented: Bool
    
    @StateObject private var viewModel: DailyRewardViewModel
    
    @State private var scale: CGFloat = 1.0
    @State private var isChestOpen: Bool = false
    @State private var showingRewardNotification: Bool = false
    
    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
        self._viewModel = StateObject(wrappedValue: DailyRewardViewModel(appViewModel: AppViewModel()))
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Button {
                        svm.play()
                        isPresented = false
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
                        Text("Reward")
                            .customFont(42)
                    }
                
                Spacer()
                
                Button {
                    if viewModel.isRewardAvailable && !isChestOpen && !viewModel.isClaimingReward {
                        svm.play()
                        handleChestTap()
                    }
                } label: {
                    Image(viewModel.isRewardAvailable && !isChestOpen ? .chestClose : .chestOpened)
                        .resizable()
                        .frame(width: 200, height: 170)
                        .scaleEffect(scale)
                        .overlay(alignment: .topTrailing) {
                            if !viewModel.isRewardAvailable {
                                Text(viewModel.remainingTime)
                                    .customFont(18, color: .coffemilk)
                            }
                        }
                }
                .disabled(!viewModel.isRewardAvailable || viewModel.isClaimingReward || isChestOpen)
                
                Spacer()
            }
            .padding()
            
            if showingRewardNotification {
                DailyRewardNotificationView(
                    rewardAmount: 20,
                    isShowing: $showingRewardNotification
                )
                .zIndex(110)
            }
        }
        .onAppear {
            viewModel.appViewModel = appViewModel
            isChestOpen = !viewModel.isRewardAvailable
        }
    }
    
    private func handleChestTap() {
        viewModel.isClaimingReward = true
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            scale = 1.2
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                scale = 1.0
                isChestOpen = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                showingRewardNotification = true
                
                viewModel.claimReward()
            }
        }
    }
}

#Preview {
    DailyTaskView(isPresented: .constant(true))
        .environmentObject(AppViewModel())
}
