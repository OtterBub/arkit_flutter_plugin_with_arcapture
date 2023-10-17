import Foundation
import RealityKit
import ARKit

class FlutterArkitView: NSObject, FlutterPlatformView {
    
    let sceneView: ARSCNView
    let arView: ARView?
    let channel: FlutterMethodChannel
    
    var forceTapOnCenter: Bool = false
    var configuration: ARConfiguration? = nil
    var configurationRealityKit: ARWorldTrackingConfiguration? = nil
    
    var bytes: Data? = nil
    
    var capturing: Bool = false
    
    
    init(withFrame frame: CGRect, viewIdentifier viewId: Int64, messenger msg: FlutterBinaryMessenger) {
        self.sceneView = ARSCNView(frame: frame)
        self.arView = ARView(frame: frame)
        self.channel = FlutterMethodChannel(name: "arkit_\(viewId)", binaryMessenger: msg)
        
        super.init()
        
        self.sceneView.delegate = self
        self.channel.setMethodCallHandler(self.onMethodCalled)
    }
    
    func view() -> UIView { return self.arView ?? UIView() }
    
    func onMethodCalled(_ call: FlutterMethodCall, _ result: FlutterResult) {
        let arguments = call.arguments as? Dictionary<String, Any>
        
        if configurationRealityKit == nil && call.method != "init" {
            logPluginError("plugin is not initialized properly", toChannel: channel)
            result(nil)
            return
        }
        
        switch call.method {
        case "init":
            initalize(arguments!, result)
            result(nil)
            break
        case "addARKitNode":
            onAddNode(arguments!)
            result(nil)
            break
        case "onUpdateNode":
            onUpdateNode(arguments!)
            result(nil)
            break
        case "removeARKitNode":
            onRemoveNode(arguments!)
            result(nil)
            break
        case "removeARKitAnchor":
            onRemoveAnchor(arguments!)
            result(nil)
            break
        case "addCoachingOverlay":
            if #available(iOS 13.0, *) {
              addCoachingOverlay(arguments!)
            }
            result(nil)
            break
        case "removeCoachingOverlay":
            if #available(iOS 13.0, *) {
              removeCoachingOverlay()
            }
            result(nil)
            break
        case "getNodeBoundingBox":
            onGetNodeBoundingBox(arguments!, result)
            break
        case "transformationChanged":
            onTransformChanged(arguments!)
            result(nil)
            break
        case "isHiddenChanged":
            onIsHiddenChanged(arguments!)
            result(nil)
            break
        case "updateSingleProperty":
            onUpdateSingleProperty(arguments!)
            result(nil)
            break
        case "updateMaterials":
            onUpdateMaterials(arguments!)
            result(nil)
            break
        case "performHitTest":
            onPerformHitTest(arguments!, result)
            break
        case "updateFaceGeometry":
            onUpdateFaceGeometry(arguments!)
            result(nil)
            break
        case "getLightEstimate":
            onGetLightEstimate(result)
            result(nil)
            break
        case "projectPoint":
            onProjectPoint(arguments!, result)
            break
        case "cameraProjectionMatrix":
            onCameraProjectionMatrix(result)
            break
        case "pointOfViewTransform":
            onPointOfViewTransform(result)
            break
        case "playAnimation":
            onPlayAnimation(arguments!)
            result(nil)
            break
        case "stopAnimation":
            onStopAnimation(arguments!)
            result(nil)
            break
        case "dispose":
            onDispose(result)
            result(nil)
            break
        case "cameraEulerAngles":
            onCameraEulerAngles(result)
            break
        case "snapshot":
            onGetSnapshot(arguments, result)
            break
        case "captureStart":
            result(false)
            break
        case "captureStop":
            result(false)
            break
        case "cameraPosition":
            onGetCameraPosition(result)
            break
        default:
            result(FlutterMethodNotImplemented)
            break
        }
    }
    
    func onDispose(_ result: FlutterResult) {
        sceneView.session.pause()
        arView?.session.pause()
        self.configurationRealityKit = nil
        self.channel.setMethodCallHandler(nil)
        result(nil)
    }
}
