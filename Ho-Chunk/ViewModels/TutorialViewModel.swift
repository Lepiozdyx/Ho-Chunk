
import SwiftUI
import Combine

class TutorialViewModel: ObservableObject {
    // Состояние обучения
    enum TutorialStep: Int, CaseIterable {
        case welcome = 0
        case troopGeneration
        case dragToMove
        case combat
        case objective
        case completed
        
        var title: String {
            switch self {
            case .welcome: return "Добро пожаловать!"
            case .troopGeneration: return "Генерация войск"
            case .dragToMove: return "Перемещение войск"
            case .combat: return "Механика боя"
            case .objective: return "Цель игры"
            case .completed: return "Обучение завершено!"
            }
        }
        
        var description: String {
            switch self {
            case .welcome:
                return "Добро пожаловать в Ho-Chunk, мини-RTS игру, где ваша цель - захватить все территории на карте!"
            case .troopGeneration:
                return "Каждая контролируемая вами область (синяя) генерирует +1 войско в секунду. Нейтральные области (серые) не генерируют войск."
            case .dragToMove:
                return "Чтобы переместить войска, коснитесь своей области, затем перетащите на целевую область и отпустите. Стрелка покажет направление движения."
            case .combat:
                return "При атаке происходит сравнение количества войск. Если атакующих больше, область переходит под ваш контроль с оставшимися войсками (атакующие - защищающиеся)."
            case .objective:
                return "Ваша цель - захватить все области на карте, включая территории противника (красные). Противник будет пытаться сделать то же самое!"
            case .completed:
                return "Отлично! Теперь вы готовы играть в Ho-Chunk! Захватите все территории, чтобы победить!"
            }
        }
    }
    
    // Опубликованные свойства
    @Published var currentStep: TutorialStep = .welcome
    @Published var showTutorialTip: Bool = true
    
    // Ссылка на GameViewModel
    private var gameViewModel: GameViewModel
    
    // Инициализатор
    init(gameViewModel: GameViewModel) {
        self.gameViewModel = gameViewModel
    }
    
    // MARK: - Методы для управления обучением
    
    // Переход к следующему шагу обучения
    func nextStep() {
        let allSteps = TutorialStep.allCases
        if let currentIndex = allSteps.firstIndex(of: currentStep),
           currentIndex < allSteps.count - 1 {
            currentStep = allSteps[currentIndex + 1]
        } else {
            // Если это последний шаг, закрываем обучение
            completeTutorial()
        }
    }
    
    // Переход к предыдущему шагу обучения
    func previousStep() {
        let allSteps = TutorialStep.allCases
        if let currentIndex = allSteps.firstIndex(of: currentStep),
           currentIndex > 0 {
            currentStep = allSteps[currentIndex - 1]
        }
    }
    
    // Закрытие обучения
    func closeTutorial() {
        showTutorialTip = false
    }
    
    // Завершение обучения
    func completeTutorial() {
        currentStep = .completed
        
        // Задержка перед закрытием подсказки
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.closeTutorial()
            // Возвращаемся к игре
            self?.gameViewModel.navigationState = .game
        }
    }
    
    // Подсказка для текущего шага (например, выделение определенной области)
    func highlightForCurrentStep() -> UUID? {
        switch currentStep {
        case .troopGeneration, .dragToMove:
            // Находим регион игрока для выделения
            return gameViewModel.gameEngine.gameState.regions.values.first(where: { $0.owner == .player })?.id
        case .combat:
            // Находим нейтральный регион для выделения
            return gameViewModel.gameEngine.gameState.regions.values.first(where: { $0.owner == .neutral })?.id
        case .objective:
            // Находим регион CPU для выделения
            return gameViewModel.gameEngine.gameState.regions.values.first(where: { $0.owner == .cpu })?.id
        default:
            return nil
        }
    }
    
    // Проверка, требуется ли специальное действие на текущем шаге
    func requiresSpecialAction() -> Bool {
        switch currentStep {
        case .dragToMove, .combat:
            return true
        default:
            return false
        }
    }
    
    // Получение подсказки для текущего шага
    func getTipForCurrentStep() -> (title: String, description: String) {
        return (currentStep.title, currentStep.description)
    }
}
