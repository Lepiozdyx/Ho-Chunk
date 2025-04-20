
import SwiftUI

enum FractionType: Int, Codable {
    case player = 0
    case cpu = 1
    case neutral = 2
    
    var color: Color {
        switch self {
        case .player: return .blue
        case .cpu: return .red
        case .neutral: return .gray
        }
    }
    
    var logo: ImageResource {
        switch self {
        case .player: return .indianLogo
        case .cpu: return .targetLogo
        case .neutral: return .neutralLogo
        }
    }
}
