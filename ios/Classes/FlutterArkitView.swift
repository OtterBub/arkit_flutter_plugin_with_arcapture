import Foundation
import RealityKit
import ARKit

import ReplayKit
import AVFoundation

class FlutterArkitView: NSObject, FlutterPlatformView {
    
//    let sceneView: ARSCNView
    static var arView: ARView?
    static var refCount = 0
    let channel: FlutterMethodChannel
    
    var forceTapOnCenter: Bool = false
    var configuration: ARConfiguration? = nil
    var configurationRealityKit: ARWorldTrackingConfiguration? = nil
    
    var bytes: Data? = nil
    
    var capturing: Bool = false
    var gettingBytes = false
    
    var frame: CGRect = CGRect()
    
    var snapshotWhile: Bool = false
    
    
    
    init(withFrame frame: CGRect, viewIdentifier viewId: Int64, messenger msg: FlutterBinaryMessenger) {
//        self.sceneView = ARSCNView(frame: frame)
        self.frame = frame
        if FlutterArkitView.arView == nil {
            FlutterArkitView.arView = ARView(frame: frame)
        }
        self.channel = FlutterMethodChannel(name: "arkit_\(viewId)", binaryMessenger: msg)
        
        super.init()
        
//        self.sceneView.delegate = self
        FlutterArkitView.arView?.session.delegate = self
        self.channel.setMethodCallHandler(self.onMethodCalled)
        FlutterArkitView.refCount += 1
    }
    
    func view() -> UIView { return FlutterArkitView.arView ?? UIView() }
    
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
            // TODO: need porting to arView
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
        case "allClearObject":
            onAllClearObject()
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
//            if snapshotWhile == false {
//                snapshotWhile = true
//                snapshotCaptureRun()
//            }
            onGetStreamSnapshot(arguments, result)
//             onGetSnapshot(arguments, result)
            break
        case "captureStart":
//            snapshotWhile = true
//            snapshotCaptureRun()
            result(false)
            break
        case "captureStop":
//            snapshotWhile = false
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
    
    var count = 0
    
    func snapshotCaptureRunRPVer() {
        let recorder = RPScreenRecorder.shared()
        recorder.isMicrophoneEnabled = false
        let cameraPreviewView = UIView(frame: FlutterArkitView.arView?.frame ?? CGRect(x: 0, y: 0, width: 200, height: 200))
//        recorder.cameraPreviewView = cameraPreviewView
        recorder.startCapture(
            handler: {
                buffer, type, error in
                // do handling buffer
//                self.bytes = buffer.
            },
       
            completionHandler: {
                error in
                // error handling
            }
        )
    }
    
    func snapshotCaptureRun() {
        
        let arFrame = FlutterArkitView.arView?.frame
        
        if arFrame == nil {
            snapshotWhile = false
            return
        }
        
        if arFrame!.height <= 0 && arFrame!.width <= 0 {
            Task {
                if snapshotWhile {
                    snapshotCaptureRun()
                }
            }
            return
        }
        
        FlutterArkitView.arView?.snapshot(saveToHDR: false) {
            [self] image in
            NSLog("snapshotCaptureRun() \(count)")
            count = count + 1
            self.bytes = image?.jpegData(compressionQuality: 0.5)
            if self.snapshotWhile && FlutterArkitView.arView != nil {
                self.snapshotCaptureRun();
            }
        }
        
    }
    
    func recordTest() {
        
        
    
    }
    
    func onDispose(_ result: FlutterResult) {
        FlutterArkitView.refCount -= 1
        if FlutterArkitView.refCount == 0 {
            FlutterArkitView.arView?.session.pause()
            FlutterArkitView.arView?.session.delegate = nil
            FlutterArkitView.arView?.scene.anchors.removeAll()
            // arView?.removeFromSuperview() // this code is occur crash
            FlutterArkitView.arView?.window?.resignKey()
            FlutterArkitView.arView = nil
            snapshotWhile = false
        }
        
        
        
        self.configurationRealityKit = nil
        self.channel.setMethodCallHandler(nil)
        result(nil)
    }
}
