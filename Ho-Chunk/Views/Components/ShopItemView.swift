
import SwiftUI

struct ShopItemView: View {
    let theme: BackgroundTheme
    let isPurchased: Bool
    let isSelected: Bool
    let canAfford: Bool
    let onBuy: () -> Void
    let onSelect: () -> Void
    
    @StateObject private var svm = SettingsViewModel.shared
    
    var body: some View {
        VStack {
            Image(.frame)
                .resizable()
                .frame(maxWidth: 200, maxHeight: 200)
                .overlay {
                    Image(theme.imageResource)
                        .resizable()
                        .padding(6)
                }
            
            Button {
                svm.play()
                if isPurchased {
                    if !isSelected {
                        onSelect()
                    }
                } else if canAfford {
                    onBuy()
                }
            } label: {
                Image(.button)
                    .resizable()
                    .frame(maxWidth: 200, maxHeight: 75)
                    .overlay {
                        if isPurchased {
                            Text(isSelected ? "used" : "use")
                                .customFont(18)
                                .offset(y: -5)
                        } else {
                            HStack {
                                Image(.coin)
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                
                                Text("\(theme.price)")
                                    .customFont(14)
                            }
                            .offset(y: -5)
                        }
                    }
            }
            .disabled((isPurchased && isSelected) || (!isPurchased && !canAfford))
            .opacity((isPurchased && isSelected) || (!isPurchased && !canAfford) ? 0.6 : 1)
        }
    }
}

#Preview {
    ShopItemView(theme: BackgroundTheme.getTheme(id: "desertBg"), isPurchased: true, isSelected: true, canAfford: true, onBuy: {}, onSelect: {})
}
