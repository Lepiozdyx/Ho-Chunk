
import SwiftUI

struct Achievement: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let description: String
    let imageResourceName: String
    let reward: Int
    var progress: Int = 0
    var target: Int = 1
    
    var imageResource: ImageResource {
        switch imageResourceName {
        case "firstStap":
            return .firstStap
        case "firstVictory":
            return .firstVictory
        case "landInvader":
            return .landInvader
        case "destroyer":
            return .destroyer
        case "hardBattle":
            return .hardBattle
        default:
            return .firstStap
        }
    }
    
    static func == (lhs: Achievement, rhs: Achievement) -> Bool {
        return lhs.id == rhs.id
    }
    
    static let allAchievements: [Achievement] = [
        Achievement(
            id: "firstStep",
            name: "First Step",
            description: "Capture your first territory",
            imageResourceName: "firstStap",
            reward: 20
        ),
        Achievement(
            id: "firstVictory",
            name: "First Victory",
            description: "Win your first match",
            imageResourceName: "firstVictory",
            reward: 50
        ),
        Achievement(
            id: "landInvader",
            name: "Land Invader",
            description: "Capture 500 regions",
            imageResourceName: "landInvader",
            reward: 80,
            progress: 0,
            target: 500
        ),
        Achievement(
            id: "destroyer",
            name: "Destroyer",
            description: "Win 10 games",
            imageResourceName: "destroyer",
            reward: 100,
            progress: 0,
            target: 10
        ),
        Achievement(
            id: "hardBattle",
            name: "Battle to the End",
            description: "Win while being in the minority",
            imageResourceName: "hardBattle",
            reward: 50
        )
    ]
}
