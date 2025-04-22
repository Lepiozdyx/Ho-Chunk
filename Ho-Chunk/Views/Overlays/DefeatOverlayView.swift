
import SwiftUI

struct DefeatOverlayView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @State private var showRetryButton: Bool = false
    @State private var showMenuButton: Bool = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            HStack {
                Image(.indian)
                    .resizable()
                    .scaledToFit()
                    .offset(y: 16)
                
                Spacer()
            }
            
            VStack(spacing: 10) {
                Image(.textUnderlay)
                    .resizable()
                    .frame(width: 300, height: 80)
                    .overlay {
                        Text("DEFEAT")
                            .customFont(42)

                    }
                
                Button {
                    appViewModel.restartLevel()
                } label: {
                    ActionView(width: 250, height: 150, text: "retry", textSize: 28)
                }
                .buttonStyle(.plain)
                .opacity(showRetryButton ? 1 : 0)
                .offset(y: showRetryButton ? 0 : 20)
                
                Button {
                    appViewModel.goToMenu()
                } label: {
                    ActionView(width: 250, height: 150, text: "menu", textSize: 28)
                }
                .buttonStyle(.plain)
                .opacity(showMenuButton ? 1 : 0)
                .offset(y: showMenuButton ? 0 : 20)
            }
            .padding()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4).delay(0.5)) {
                showRetryButton = true
            }
            
            withAnimation(.easeOut(duration: 0.4).delay(0.8)) {
                showMenuButton = true
            }
        }
    }
}

#Preview {
    DefeatOverlayView()
}
