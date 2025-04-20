import SwiftUI

enum Player: String, Identifiable {
    case player
    case cpu
    case neutral
    
    var id: String {
        self.rawValue
    }
    
    var color: Color {
        switch self {
        case .player:
            return .blue
        case .cpu:
            return .red
        case .neutral:
            return .gray
        }
    }
    
    var logo: ImageResource {
        switch self {
        case .player:
            return .indianLogo
        case .cpu:
            return .targetLogo
        case .neutral:
            return .neutralLogo
        }
    }
}
