
import Foundation

struct Achievement: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    var isUnlocked: Bool
    let iconName: String
    
    // Статические константы для ключей достижений
    static let firstStepKey = "first_step"
    static let firstWinKey = "first_win"
    static let landConquerorKey = "land_conqueror"
    static let destroyerKey = "destroyer"
    static let fightToTheEndKey = "fight_to_the_end"
    
    // Фабричный метод для создания всех достижений
    static func createAllAchievements() -> [Achievement] {
        return [
            Achievement(
                id: firstStepKey,
                title: "Первый шаг",
                description: "Захватить первую территорию",
                isUnlocked: false,
                iconName: "flag.fill"
            ),
            Achievement(
                id: firstWinKey,
                title: "Первая победа",
                description: "Выиграть первый матч",
                isUnlocked: false,
                iconName: "trophy.fill"
            ),
            Achievement(
                id: landConquerorKey,
                title: "Захватчик земель",
                description: "Захватить 500 клеток за всю историю игры",
                isUnlocked: false,
                iconName: "map.fill"
            ),
            Achievement(
                id: destroyerKey,
                title: "Уничтожитель",
                description: "Одержать победу в 10 играх",
                isUnlocked: false,
                iconName: "flame.fill"
            ),
            Achievement(
                id: fightToTheEndKey,
                title: "Сражение до конца",
                description: "Выиграть, будучи в меньшинстве % захваченных зон",
                isUnlocked: false,
                iconName: "arrow.up.heart.fill"
            )
        ]
    }
}
