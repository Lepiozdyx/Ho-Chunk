
import SwiftUI

struct RegionView: View {
    @ObservedObject var region: Region
    var scalingService: GameScalingService
    
    var body: some View {
        Image(region.shape)
            .resizable()
            .colorMultiply(region.owner.color)
            .frame(
                width: scalingService.scaledSize(region.width),
                height: scalingService.scaledSize(region.height)
            )
            .shadow(color: .black, radius: 2)
            .overlay {
                VStack {
                    Image(region.owner.logo)
                        .resizable()
                        .frame(
                            width: scalingService.scaledSize(25),
                            height: scalingService.scaledSize(25)
                        )
                    
                    Text("\(region.troopCount)")
                        .customFont(scalingService.scaledSize(18))
                }
            }
            .position(scalingService.scaledPosition(region.position))
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
    
    return RegionView(region: region, scalingService: GameScalingService.shared)
}
