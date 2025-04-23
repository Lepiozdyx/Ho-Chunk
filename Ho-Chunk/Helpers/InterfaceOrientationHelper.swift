
import SwiftUI

class InterfaceOrientationHelper {
    public static var orientationMask: UIInterfaceOrientationMask = .landscapeLeft
    public static var isAutoRotationEnabled: Bool = false
}

class CustomHostingController<Content: View>: UIHostingController<Content> {
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return InterfaceOrientationHelper.orientationMask
    }

    override var shouldAutorotate: Bool {
        return InterfaceOrientationHelper.isAutoRotationEnabled
    }
}
