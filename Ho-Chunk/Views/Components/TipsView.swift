import SwiftUI

struct TipsView: View {
    @Binding var showTips: Bool
    @State private var currentTipIndex: Int = 0
    
    // Массив подсказок для обучения
    let tips = [
        "Welcome to Ho-Chunk, Warrior! In this game, you are the leader of the tribe and your job is to conquer territories.",
        "Your regions (blue) generate 1 soldier every second. The more regions you have, the faster your army grows!",
        "To move troops, tap your region and gesture drag to any other region on the map.",
        "You can capture neutral regions (gray) with any number of troops, but you need more troops than they have to capture enemy regions.",
        "Your goal is to conquer the entire map. On the next level, a real opponent awaits you. Act without delay, the enemy is not slumbering! Good luck!"
    ]
    
    var isLastTip: Bool {
        return currentTipIndex >= tips.count - 1
    }
    
    var body: some View {
        HStack {
            VStack {
                Spacer()
                
                Image(.frame)
                    .resizable()
                    .frame(width: 200, height: 210)
                    .overlay {
                        Text(tips[currentTipIndex])
                            .customFont(15, color: .black)
                            .padding()
                    }
                    .overlay(alignment: .topTrailing) {
                        if !isLastTip {
                            Button {
                                // Пропускаем все подсказки
                                showTips = false
                            } label: {
                                Image(.buttonCircle)
                                    .resizable()
                                    .frame(width: 35, height: 35)
                                    .overlay {
                                        Image(systemName: "xmark")
                                            .resizable()
                                            .frame(width: 15, height: 15)
                                            .foregroundStyle(.yellow)
                                    }
                            }
                            .offset(x: 10, y: -10)
                        }
                    }
                
                Button {
                    if isLastTip {
                        showTips = false
                    } else {
                        withAnimation {
                            currentTipIndex += 1
                        }
                    }
                } label: {
                    ActionView(
                        width: 150,
                        height: 75,
                        text: isLastTip ? "close" : "next",
                        textSize: 18
                    )
                }
            }
            .transition(.opacity)
            
            Spacer()
        }
    }
}

#Preview {
    TipsView(showTips: .constant(true))
}
