import SwiftUI

struct RegionView: View {
    @ObservedObject var region: Region
    
    var body: some View {
        Image(region.shape)
            .resizable()
            .scaledToFit()
            .colorMultiply(region.owner.color)
            .frame(width: 180, height: 180)
            .shadow(color: .black, radius: 2)
            .overlay {
                VStack {
                    Image(region.owner.logo)
                        .resizable()
                        .frame(width: 30, height: 30)
                    
                    Text("\(region.troopCount)")
                        .customFont(20)
                }
            }
            .position(region.position)
    }
}

#Preview {
    let region = Region(shape: .vector3, position: CGPoint(x: 250, y: 200), owner: .cpu)
    
    RegionView(region: region)
}
