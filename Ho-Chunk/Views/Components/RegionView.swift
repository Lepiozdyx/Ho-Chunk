import SwiftUI

struct RegionView: View {
    let region: Region
    
    var body: some View {
        Image(region.shape)
            .resizable()
            .scaledToFit()
            .colorMultiply(region.owner.color)
            .frame(width: 180, height: 180) // Увеличиваем размер в 1.5 раза (было 120)
            .shadow(color: .black, radius: 2)
            .overlay {
                VStack {
                    Image(region.owner.logo)
                        .resizable()
                        .frame(width: 30, height: 30) // Увеличиваем размер иконки тоже
                    
                    Text("\(region.troopCount)")
                        .customFont(20) // Увеличиваем размер текста
                }
            }
            .position(region.position)
    }
}

#Preview {
    let region = Region(shape: .vector3, position: CGPoint(x: 250, y: 200), owner: .cpu)
    
    RegionView(region: region)
}
