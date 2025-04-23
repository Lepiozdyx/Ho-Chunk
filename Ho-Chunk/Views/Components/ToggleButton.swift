
import SwiftUI

struct ToggleButton: View {
    let isON: Bool
    let action: () -> Void
    
    var body: some View {
        Button {
            withAnimation {
                action()
            }
        } label: {
            Capsule()
                .frame(width: 100, height: 40)
                .foregroundStyle(isON ? .green.opacity(0.85) : .gray)
                .overlay(alignment: isON ? .trailing : .leading) {
                    Capsule()
                        .frame(width: 35, height: 35)
                        .foregroundStyle(.black.opacity(0.85))
                        .padding(.horizontal, 6)
                }
        }
        .buttonStyle(.plain)
    }
}
