
import SwiftUI

struct AchiUnlockedView: View {
    let achievement: Achievement
    @Binding var isShowing: Bool
    
    @State private var offset: CGFloat = -200
    @State private var opacity: Double = 0
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                Image(achievement.imageResource)
                    .resizable()
                    .frame(width: 40, height: 45)
            }
            Spacer()
        }
        .padding([.horizontal, .top], 8)
        .offset(y: offset)
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                offset = 0
                opacity = 1
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeOut(duration: 0.5)) {
                    offset = -200
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
    AchiUnlockedView(
        achievement: Achievement(
            id: "firstStep",
            name: "First Step",
            description: "Capture your first territory",
            imageResourceName: "firstStap",
            reward: 20
        ),
        isShowing: .constant(true)
    )
}
