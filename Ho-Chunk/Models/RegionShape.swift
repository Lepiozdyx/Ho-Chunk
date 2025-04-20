
import SwiftUI

enum RegionShape: String, Codable {
    case vector1
    case vector2
    case vector3
    case vector4
    case vector5
    case vector6
    case vector7
    case vector8
    case vector9
    case vector10
    
    var imageResource: ImageResource {
        switch self {
        case .vector1: return .vector1
        case .vector2: return .vector2
        case .vector3: return .vector3
        case .vector4: return .vector4
        case .vector5: return .vector5
        case .vector6: return .vector6
        case .vector7: return .vector7
        case .vector8: return .vector8
        case .vector9: return .vector9
        case .vector10: return .vector10
        }
    }
}
