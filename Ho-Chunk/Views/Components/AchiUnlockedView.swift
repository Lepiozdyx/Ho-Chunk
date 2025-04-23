
import SwiftUI

struct AchiUnlockedView: View {
    let achievement: Achievement
    @Binding var isShowing: Bool
    
    @State private var offset: CGFloat = 200
    @State private var opacity: Double = 0
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Image(.frame)
                    .resizable()
                    .frame(width: 200, height: 70)
                    .overlay {
                        HStack {
                            Image(achievement.imageResource)
                                .resizable()
                                .frame(width: 50, height: 50)
                                .padding(.leading, 8)
                            
                            VStack(alignment: .leading) {
                                Text("Unlocked!")
                                    .customFont(12, color: .yellow)
                                
                                Text(achievement.name)
                                    .customFont(16)
                            }
                        }
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
            
            // Автоматически скрываем через 3 секунды
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
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
