
import SwiftUI

struct BackgroundTheme: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let imageResourceName: String
    let price: Int
    
    var imageResource: ImageResource {
        switch imageResourceName {
        case "desertBg":
            return .desertBg
        case "nightBg":
            return .nightBg
        case "fallBg":
            return .fallBg
        case "wildwest1Bg":
            return .wildwest1Bg
        case "wildwest2Bg":
            return .wildwest2Bg
        default:
            return .desertBg
        }
    }
    
    static func == (lhs: BackgroundTheme, rhs: BackgroundTheme) -> Bool {
        return lhs.id == rhs.id
    }
    
    static let availableThemes: [BackgroundTheme] = [
        BackgroundTheme(id: "desert", name: "Desert", imageResourceName: "desertBg", price: 0),
        BackgroundTheme(id: "night", name: "Night", imageResourceName: "nightBg", price: 100),
        BackgroundTheme(id: "fall", name: "Fall", imageResourceName: "fallBg", price: 100),
        BackgroundTheme(id: "wildwest1", name: "Wild West 1", imageResourceName: "wildwest1Bg", price: 100),
        BackgroundTheme(id: "wildwest2", name: "Wild West 2", imageResourceName: "wildwest2Bg", price: 100)
    ]
    
    static func getTheme(id: String) -> BackgroundTheme {
        return availableThemes.first { $0.id == id } ?? availableThemes[0]
    }
}
