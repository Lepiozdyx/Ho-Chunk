
import SwiftUI

struct AchievementItemView: View {
    let achievement: Achievement
    let isCompleted: Bool
    let isClaimed: Bool
    let canClaim: Bool
    let onClaim: () -> Void
    
    @StateObject private var svm = SettingsViewModel.shared
    
    var body: some View {
        VStack {
            Image(.frame)
                .resizable()
                .frame(maxWidth: 250, maxHeight: 250)
                .overlay {
                    VStack {
                        Image(achievement.imageResource)
                            .resizable()
                            .frame(width: 65, height: 65)
                            .saturation(isCompleted ? 1.0 : 0.0)
                        
                        Text(achievement.name)
                            .customFont(14, color: .yellow)
                            .padding(.top, 4)
                        
                        Text(achievement.description)
                            .customFont(10, color: .black.opacity(0.6))
                            .padding(.horizontal, 4)
                        
                        // Show progress for achievements with targets > 1
                        if achievement.target > 1 {
                            Text("\(achievement.progress)/\(achievement.target)")
                                .customFont(10)
                                .padding(.top, 2)
                        }
                    }
                }
            
            Button {
                svm.play()
                if canClaim {
                    onClaim()
                }
            } label: {
                Image(.button)
                    .resizable()
                    .frame(maxWidth: 200, maxHeight: 65)
                    .overlay {
                        if isClaimed {
                            Text("claimed")
                                .customFont(18)
                                .offset(y: -5)
                        } else if canClaim {
                            HStack {
                                Image(.coin)
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                
                                Text("+\(achievement.reward)")
                                    .customFont(16)
                            }
                            .offset(y: -5)
                        } else {
                            Text("locked")
                                .customFont(18)
                                .offset(y: -5)
                        }
                    }
            }
            .disabled(!canClaim)
            .opacity(canClaim ? 1.0 : 0.6)
        }
    }
}

#Preview {
    let achi = Achievement.init(id: "firstVictory", name: "First Victory", description: "Win your first match", imageResourceName: "firstVictory", reward: 50)
    
    AchievementItemView(achievement: achi, isCompleted: true, isClaimed: false, canClaim: true, onClaim: {})
}
