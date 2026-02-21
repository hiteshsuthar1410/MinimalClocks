import FirebaseAuth
import SwiftUI

extension ContentView {
    func showWidgetInfo(_ widgetType: MCWidgetInfo.WidgetType) {
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        showSheet = .widgetInfo(widgetType: widgetType)
    }

    func authenticateUser() {
        if let user = Auth.auth().currentUser {
            user.getIDTokenResult { result, error in
                if error != nil {
                    debugPrint(error as Any, terminator: "\n")
                }
                debugPrint(result as Any, terminator: "\n")
            }
        } else {
            debugPrint("\ncurrent user is nil")
        }
    }
}
