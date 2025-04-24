
import SwiftUI

struct DailyTaskView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var svm = SettingsViewModel.shared
    @Binding var isPresented: Bool
    
    @StateObject private var viewModel = DailyRewardViewModel()
    
    @State private var scale: CGFloat = 1.0
    @State private var showingRewardNotification: Bool = false
    @State private var rewardClaimed: Bool = false
    
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
                    if viewModel.isRewardAvailable && !rewardClaimed && !viewModel.isClaimingReward {
                        svm.play()
                        handleChestTap()
                    }
                } label: {
                    Image(viewModel.isRewardAvailable && !rewardClaimed ? .chestClose : .chestOpened)
                        .resizable()
                        .frame(width: 200, height: 170)
                        .scaleEffect(scale)
                }
                .disabled(!viewModel.isRewardAvailable || viewModel.isClaimingReward || rewardClaimed)
                .overlay(alignment: .center) {
                    if !viewModel.isRewardAvailable {
                        VStack {
                            Text("The next through:")
                                .customFont(14, color: .yellow)
                            
                            Text("\(viewModel.remainingTime) h")
                                .customFont(20, color: .white)
                        }
                        .padding()
                        .background(
                            Image(.frame)
                                .resizable()
                        )
                    }
                }
                
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
            setup()
        }
        .onChange(of: viewModel.isRewardAvailable) { newValue in
            rewardClaimed = !newValue && appViewModel.gameState.lastDailyRewardClaimDate != nil
        }
    }
    
    private func setup() {
        viewModel.appViewModel = appViewModel
        viewModel.updateState()
        
        rewardClaimed = !viewModel.isRewardAvailable && appViewModel.gameState.lastDailyRewardClaimDate != nil
    }
    
    private func handleChestTap() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            scale = 1.2
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                scale = 1.0
                rewardClaimed = true
            }
            
            if viewModel.claimReward() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    showingRewardNotification = true
                }
            } else {
                rewardClaimed = false
            }
        }
    }
}

#Preview {
    DailyTaskView(isPresented: .constant(true))
        .environmentObject(AppViewModel())
}
