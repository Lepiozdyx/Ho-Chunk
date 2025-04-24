
import SwiftUI

struct RootView: View {
    
    @StateObject private var state = AppStateViewModel()
    private var orientation = OrientationViewModel.shared
    
    var body: some View {
        Group {
            switch state.appState {
            case .one:
                LoadingView()
            case .two:
                if let url = state.webManager.targetURL {
                    WebViewManager(url: url, webManager: state.webManager)
                        .onAppear {
                            orientation.unlockOrientation()
                        }
                } else {
                    WebViewManager(url: NetworkManager.initialURL, webManager: state.webManager)
                        .onAppear {
                            orientation.unlockOrientation()
                        }
                }
            case .final:
                ContentView()
            }
        }
        .onAppear {
            state.stateCheck()
        }
    }
}

#Preview {
    RootView()
}
