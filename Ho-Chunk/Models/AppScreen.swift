import Foundation

enum AppScreen: CaseIterable {
    case menu
    case game
    // Оверлеи игрового процесса
    case pause
    case victory
    case defeat
    // Дополнительные экраны
    case settings
    case shop
    case achievements
}
