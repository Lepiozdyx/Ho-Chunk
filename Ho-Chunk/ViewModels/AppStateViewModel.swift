
import Foundation

@MainActor
final class AppStateViewModel: ObservableObject {
    enum AppState {
        case one
        case two
        case final
    }
    
    @Published private(set) var appState: AppState = .one
    let webManager: NetworkManager
    
    init(webManager: NetworkManager = NetworkManager()) {
        self.webManager = webManager
    }
    
    func stateCheck() {
        Task {
            if webManager.targetURL != nil {
                appState = .two
                return
            }
            
            do {
                if try await webManager.checkInitialURL() {
                    appState = .two
                } else {
                    appState = .final
                }
            } catch {
                appState = .final
            }
        }
    }
}
