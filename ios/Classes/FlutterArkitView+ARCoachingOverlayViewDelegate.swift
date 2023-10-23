import Foundation
import ARKit

@available(iOS 13.0, *)
extension FlutterArkitView: ARCoachingOverlayViewDelegate {
  func addCoachingOverlay(_ arguments: Dictionary<String, Any>) {
    let goalType = arguments["goal"] as! Int
    let goal = ARCoachingOverlayView.Goal.init(rawValue: goalType)!

      if FlutterArkitView.arView == nil { return }

      let coachingView = ARCoachingOverlayView(frame: FlutterArkitView.arView!.frame)

    coachingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    removeCoachingOverlay()

    FlutterArkitView.arView!.addSubview(coachingView)

    coachingView.goal = goal
    coachingView.session = FlutterArkitView.arView!.session
    coachingView.delegate = self
    coachingView.setActive(true, animated: true)
  }
  
  func removeCoachingOverlay() {
      if FlutterArkitView.arView == nil { return }
      if let view = FlutterArkitView.arView?.subviews.first(where: {$0 is ARCoachingOverlayView}) {
      view.removeFromSuperview()
    }
  }
  
  func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
    self.channel.invokeMethod("coachingOverlayViewDidDeactivate", arguments: nil)
  }
}
