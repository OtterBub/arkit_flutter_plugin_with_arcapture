import Foundation
import ARKit

@available(iOS 13.0, *)
extension FlutterArkitView: ARCoachingOverlayViewDelegate {
  func addCoachingOverlay(_ arguments: Dictionary<String, Any>) {
    let goalType = arguments["goal"] as! Int
    let goal = ARCoachingOverlayView.Goal.init(rawValue: goalType)!

    if self.arView == nil { return }

    let coachingView = ARCoachingOverlayView(frame: self.arView!.frame)

    coachingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    removeCoachingOverlay()

    self.arView!.addSubview(coachingView)

    coachingView.goal = goal
    coachingView.session = self.arView!.session
    coachingView.delegate = self
    coachingView.setActive(true, animated: true)
  }
  
  func removeCoachingOverlay() {
      if self.arView == nil { return }
      if let view = self.arView?.subviews.first(where: {$0 is ARCoachingOverlayView}) {
      view.removeFromSuperview()
    }
  }
  
  func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
    self.channel.invokeMethod("coachingOverlayViewDidDeactivate", arguments: nil)
  }
}
