import Foundation
import SwiftUI

struct GameLevel {
    let id: Int
    let regions: [RegionDefinition]
    
    struct RegionDefinition {
        let shape: ImageResource
        let position: CGPoint
        let width: CGFloat
        let height: CGFloat
        let owner: Player
        let initialTroops: Int
        
        init(shape: ImageResource, position: CGPoint, width: CGFloat = 180, height: CGFloat = 180, owner: Player, initialTroops: Int) {
            self.shape = shape
            self.position = position
            self.width = width
            self.height = height
            self.owner = owner
            self.initialTroops = initialTroops
        }
    }
    
    static let levels: [GameLevel] = [
        GameLevel(id: 1, regions: [
            RegionDefinition(shape: .vector6, position: CGPoint(x: 466, y: 242), width: 170, height: 170, owner: .player, initialTroops: 5),

            RegionDefinition(shape: .vector2, position: CGPoint(x: 247, y: 201), width: 130, height: 200, owner: .neutral, initialTroops: 0),
            RegionDefinition(shape: .vector3, position: CGPoint(x: 350, y: 288), width: 160, height: 140, owner: .neutral, initialTroops: 0),
            RegionDefinition(shape: .vector4, position: CGPoint(x: 321, y: 137), width: 110, height: 160, owner: .neutral, initialTroops: 0),
            RegionDefinition(shape: .vector7, position: CGPoint(x: 427, y: 119), width: 170, height: 140, owner: .neutral, initialTroops: 0),
        ]),
        GameLevel(id: 2, regions: [
            RegionDefinition(shape: .vector8, position: CGPoint(x: 568, y: 282), width: 170, height: 120, owner: .player, initialTroops: 0),
            RegionDefinition(shape: .vector9, position: CGPoint(x: 569, y: 207), width: 160, height: 90, owner: .player, initialTroops: 0),
            RegionDefinition(shape: .vector10, position: CGPoint(x: 489, y: 113), width: 120, height: 130, owner: .player, initialTroops: 0),

            RegionDefinition(shape: .vector1, position: CGPoint(x: 195, y: 311), width: 210, height: 110, owner: .cpu, initialTroops: 0),

            RegionDefinition(shape: .vector2, position: CGPoint(x: 208, y: 188), width: 140, height: 160, owner: .neutral, initialTroops: 0),
            RegionDefinition(shape: .vector3, position: CGPoint(x: 306, y: 265), width: 140, height: 150, owner: .neutral, initialTroops: 0),
            RegionDefinition(shape: .vector4, position: CGPoint(x: 274, y: 115), width: 130, height: 150, owner: .neutral, initialTroops: 0),
            RegionDefinition(shape: .vector5, position: CGPoint(x: 429, y: 292), width: 155, height: 125, owner: .neutral, initialTroops: 0),
            RegionDefinition(shape: .vector6, position: CGPoint(x: 399, y: 217), width: 125, height: 155, owner: .neutral, initialTroops: 0),
            RegionDefinition(shape: .vector7, position: CGPoint(x: 371, y: 101), width: 150, height: 140, owner: .neutral, initialTroops: 0)
        ]),
        GameLevel(id: 3, regions: [
            RegionDefinition(shape: .vector2, position: CGPoint(x: 574, y: 276), width: 110, height: 120, owner: .player, initialTroops: 0),
            RegionDefinition(shape: .vector8, position: CGPoint(x: 563, y: 160), width: 180, height: 130, owner: .player, initialTroops: 0),

            RegionDefinition(shape: .vector3, position: CGPoint(x: 114, y: 279), width: 140, height: 170, owner: .cpu, initialTroops: 0),

            RegionDefinition(shape: .vector4, position: CGPoint(x: 200, y: 221), width: 140, height: 170, owner: .neutral, initialTroops: 0),
            RegionDefinition(shape: .vector5, position: CGPoint(x: 303, y: 269), width: 170, height: 150, owner: .neutral, initialTroops: 0),
            RegionDefinition(shape: .vector6, position: CGPoint(x: 432, y: 167), width: 150, height: 180, owner: .neutral, initialTroops: 0),
            RegionDefinition(shape: .vector7, position: CGPoint(x: 293, y: 152), width: 140, height: 150, owner: .neutral, initialTroops: 0),
            RegionDefinition(shape: .vector9, position: CGPoint(x: 446, y: 296), width: 160, height: 100, owner: .neutral, initialTroops: 0),
        ]),
        GameLevel(id: 4, regions: [
            RegionDefinition(shape: .vector3, position: CGPoint(x: 577, y: 144), width: 210, height: 80, owner: .player, initialTroops: 0),
            RegionDefinition(shape: .vector4, position: CGPoint(x: 526, y: 248), width: 120, height: 120, owner: .player, initialTroops: 0),

            RegionDefinition(shape: .vector6, position: CGPoint(x: 150, y: 79), width: 170, height: 100, owner: .cpu, initialTroops: 0),
            RegionDefinition(shape: .vector8, position: CGPoint(x: 78, y: 185), width: 150, height: 110, owner: .cpu, initialTroops: 0),

            RegionDefinition(shape: .vector2, position: CGPoint(x: 84, y: 306), width: 150, height: 130, owner: .neutral, initialTroops: 0),
            RegionDefinition(shape: .vector2, position: CGPoint(x: 431, y: 300), width: 180, height: 110, owner: .neutral, initialTroops: 0),
            RegionDefinition(shape: .vector4, position: CGPoint(x: 255, y: 314), width: 220, height: 100, owner: .neutral, initialTroops: 0),
            RegionDefinition(shape: .vector6, position: CGPoint(x: 385, y: 183), width: 200, height: 90, owner: .neutral, initialTroops: 0),
            RegionDefinition(shape: .vector10, position: CGPoint(x: 245, y: 177), width: 170, height: 140, owner: .neutral, initialTroops: 0),
            RegionDefinition(shape: .vector10, position: CGPoint(x: 653, y: 273), width: 120, height: 130, owner: .neutral, initialTroops: 0),
        ]),
        GameLevel(id: 5, regions: [
            RegionDefinition(shape: .vector6, position: CGPoint(x: 175, y: 106), width: 160, height: 110, owner: .player, initialTroops: 0),
            RegionDefinition(shape: .vector2, position: CGPoint(x: 77, y: 301), width: 130, height: 120, owner: .player, initialTroops: 0),
            RegionDefinition(shape: .vector10, position: CGPoint(x: 67, y: 172), width: 110, height: 130, owner: .player, initialTroops: 0),

            RegionDefinition(shape: .vector8, position: CGPoint(x: 565, y: 86), width: 110, height: 90, owner: .cpu, initialTroops: 0),
            RegionDefinition(shape: .vector10, position: CGPoint(x: 663, y: 195), width: 110, height: 160, owner: .cpu, initialTroops: 0),

            RegionDefinition(shape: .vector4, position: CGPoint(x: 165, y: 268), width: 140, height: 80, owner: .neutral, initialTroops: 0),
            RegionDefinition(shape: .vector4, position: CGPoint(x: 280, y: 238), width: 110, height: 100, owner: .neutral, initialTroops: 0),
            RegionDefinition(shape: .vector5, position: CGPoint(x: 281, y: 129), width: 140, height: 110, owner: .neutral, initialTroops: 0),
            RegionDefinition(shape: .vector3, position: CGPoint(x: 518, y: 263), width: 170, height: 80, owner: .neutral, initialTroops: 0),
            RegionDefinition(shape: .vector6, position: CGPoint(x: 517, y: 175), width: 180, height: 80, owner: .neutral, initialTroops: 0),
            RegionDefinition(shape: .vector7, position: CGPoint(x: 375, y: 249), width: 130, height: 140, owner: .neutral, initialTroops: 0),
            RegionDefinition(shape: .vector9, position: CGPoint(x: 425, y: 124), width: 160, height: 90, owner: .neutral, initialTroops: 0),
        ]),
        GameLevel(id: 6, regions: [
            RegionDefinition(shape: .vector8, position: CGPoint(x: 563, y: 255), width: 160, height: 160, owner: .player, initialTroops: 0),

            RegionDefinition(shape: .vector2, position: CGPoint(x: 130, y: 123), width: 150, height: 150, owner: .cpu, initialTroops: 0),

            RegionDefinition(shape: .vector3, position: CGPoint(x: 289, y: 137), width: 160, height: 130, owner: .neutral, initialTroops: 0),
            RegionDefinition(shape: .vector4, position: CGPoint(x: 425, y: 148), width: 160, height: 140, owner: .neutral, initialTroops: 0),
            RegionDefinition(shape: .vector6, position: CGPoint(x: 140, y: 260), width: 160, height: 160, owner: .neutral, initialTroops: 0),
            RegionDefinition(shape: .vector6, position: CGPoint(x: 571, y: 132), width: 170, height: 130, owner: .neutral, initialTroops: 0),
            RegionDefinition(shape: .vector7, position: CGPoint(x: 312, y: 283), width: 180, height: 180, owner: .neutral, initialTroops: 0),
            RegionDefinition(shape: .vector10, position: CGPoint(x: 461, y: 293), width: 170, height: 160, owner: .neutral, initialTroops: 0),
        ]),
        GameLevel(id: 7, regions: [
            RegionDefinition(shape: .vector6, position: CGPoint(x: 387, y: 308), width: 110, height: 110, owner: .player, initialTroops: 0),
            RegionDefinition(shape: .vector3, position: CGPoint(x: 426, y: 156), width: 90, height: 190, owner: .player, initialTroops: 0),

            RegionDefinition(shape: .vector1, position: CGPoint(x: 118, y: 310), width: 200, height: 120, owner: .cpu, initialTroops: 0),
            RegionDefinition(shape: .vector2, position: CGPoint(x: 143, y: 185), width: 90, height: 160, owner: .cpu, initialTroops: 0),

            RegionDefinition(shape: .vector1, position: CGPoint(x: 522, y: 227), width: 160, height: 140, owner: .neutral, initialTroops: 0),
            RegionDefinition(shape: .vector3, position: CGPoint(x: 505, y: 327), width: 160, height: 90, owner: .neutral, initialTroops: 0),
            RegionDefinition(shape: .vector3, position: CGPoint(x: 244, y: 268), width: 180, height: 180, owner: .neutral, initialTroops: 0),
            RegionDefinition(shape: .vector4, position: CGPoint(x: 331, y: 187), width: 130, height: 180, owner: .neutral, initialTroops: 0),
            RegionDefinition(shape: .vector4, position: CGPoint(x: 519, y: 120), width: 80, height: 130, owner: .neutral, initialTroops: 0),
            RegionDefinition(shape: .vector4, position: CGPoint(x: 636, y: 326), width: 160, height: 70, owner: .neutral, initialTroops: 0),
            RegionDefinition(shape: .vector8, position: CGPoint(x: 612, y: 161), width: 100, height: 190, owner: .neutral, initialTroops: 0),
        ]),
    ]
    
    static func getLevel(_ id: Int) -> GameLevel {
        return levels.first { $0.id == id } ?? levels[0]
    }
}
