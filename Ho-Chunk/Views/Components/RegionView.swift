import SwiftUI

struct RegionView: View {
    @ObservedObject var region: Region
    
    var body: some View {
        Image(region.shape)
            .resizable()
            .colorMultiply(region.owner.color)
            .frame(width: region.width, height: region.height)
            .shadow(color: .black, radius: 2)
            .overlay {
                VStack {
                    Image(region.owner.logo)
                        .resizable()
                        .frame(width: 25, height: 25)
                    
                    Text("\(region.troopCount)")
                        .customFont(18)
                }
            }
            .position(region.position)
    }
}

#Preview {
    let region = Region(
        shape: .vector3,
        position: CGPoint(x: 250, y: 200),
        width: 150,
        height: 200,
        owner: .cpu
    )
    
    return RegionView(region: region)
}
