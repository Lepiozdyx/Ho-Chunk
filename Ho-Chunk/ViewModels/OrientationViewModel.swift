
import SwiftUI

class OrientationViewModel {
    
    static let shared = OrientationViewModel()
    
    private init() {}
    
    func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        InterfaceOrientationHelper.orientationMask = orientation
        
        if orientation != .all {
            InterfaceOrientationHelper.isAutoRotationEnabled = false
        } else {
            InterfaceOrientationHelper.isAutoRotationEnabled = true
        }
        
        UIViewController.attemptRotationToDeviceOrientation()
    }
    
    func unlockOrientation() {
        InterfaceOrientationHelper.orientationMask = .all
        InterfaceOrientationHelper.isAutoRotationEnabled = true
        UIViewController.attemptRotationToDeviceOrientation()
    }
    
    func lockLandscape() {
        InterfaceOrientationHelper.orientationMask = .landscape
        InterfaceOrientationHelper.isAutoRotationEnabled = false
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if windowScene.interfaceOrientation.isPortrait {
                InterfaceOrientationHelper.isAutoRotationEnabled = true
                UIViewController.attemptRotationToDeviceOrientation()
                
                if #available(iOS 16.0, *) {
                    windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeRight))
                } else {
                    UIDevice.current.setValue(UIDeviceOrientation.landscapeRight.rawValue, forKey: "orientation")
                }
                
                InterfaceOrientationHelper.isAutoRotationEnabled = false
            }
        }
    }
}
