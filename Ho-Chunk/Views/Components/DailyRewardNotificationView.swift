
import SwiftUI

struct DailyRewardNotificationView: View {
    let rewardAmount: Int
    @Binding var isShowing: Bool
    
    @State private var offset: CGFloat = 200
    @State private var opacity: Double = 0
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Image(.coin)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .padding(.leading, 8)
                
                VStack(alignment: .leading) {
                    Text("Reward!")
                        .customFont(12, color: .yellow)
                    
                    Text("+\(rewardAmount)")
                        .customFont(16)
                }
            }
            .offset(y: offset)
            .opacity(opacity)
        }
        .padding(.bottom)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                offset = 0
                opacity = 1
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                withAnimation(.easeOut(duration: 0.5)) {
                    offset = 200
                    opacity = 0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isShowing = false
                }
            }
        }
    }
}

#Preview {
    DailyRewardNotificationView(
        rewardAmount: 20,
        isShowing: .constant(true)
    )
}
