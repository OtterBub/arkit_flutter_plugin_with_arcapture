import ARKit
import SceneKit.ModelIO
import RealityKit

extension FlutterArkitView {
    func onAddNode(_ arguments: Dictionary<String, Any>) {
        NSLog("onAddNode -- START")
        let geometryArguments = arguments["geometry"] as? Dictionary<String, Any>
        
        
        let geometry = createGeometry(geometryArguments)
        let node = createNode(geometry, fromDict: arguments)
            
        var fileName: String?
        
        if let geoarguments = geometryArguments {
            let fileName = geoarguments["url"]
            let dartType = geoarguments["dartType"] as! String
            NSLog("[onAddNode] dartType \(dartType)")
           
            if dartType == "ARKitText" {
                let text = geoarguments["text"] as! String
                let extrusionDepth = geoarguments["extrusionDepth"] as! Float
                let anchor = AnchorEntity()
                let textEntity = ModelEntity(
                    mesh: .generateText(
                        text,
                        extrusionDepth: extrusionDepth,
                        font: .systemFont(ofSize: MeshResource.Font.systemFontSize, weight: .bold),
                        containerFrame: CGRect.zero,
                        alignment: .center,
                        lineBreakMode: .byCharWrapping
                    )
                )
                textEntity.model?.materials.append(SimpleMaterial(color: .yellow, roughness: 0.5, isMetallic: true))
                anchor.addChild(textEntity)
                anchor.transform.matrix = simd_float4x4(node.transform)
                FlutterArkitView.arView!.scene.anchors.append(anchor)
                return
            } else if dartType == "ARKitReferenceNode" {
                
            }
        }
        
        
        let newAnchorEntity = RealityKitUtil.convertNodeToAnchorEntity(node: node, fileName: fileName)
        
        if newAnchorEntity == nil {
            NSLog("[FlutterARkitView Handlers] onAddNote newAnchorEntity is nil")
            logPluginError("[FlutterARkitView Handlers] onAddNote SceneNode convert to AnchorEntity error", toChannel: channel)
            return
        }
        
        
        FlutterArkitView.arView!.scene.anchors.append(newAnchorEntity!)

        NSLog("onAddNode -- END")
    }
  
    func onUpdateNode(_ arguments: Dictionary<String, Any>) {
      guard let nodeName = arguments["nodeName"] as? String else {
          logPluginError("nodeName deserialization failed", toChannel: channel)
          return
      }
//      guard let node = sceneView.scene.rootNode.childNode(withName: nodeName, recursively: true) else {
//          logPluginError("node not found", toChannel: channel)
//          return
//      }
//      if let geometryArguments = arguments["geometry"] as? Dictionary<String, Any>,
//         let geometry = createGeometry(geometryArguments, withDevice: sceneView.device) {
//          node.geometry = geometry
//      }
//      if let materials = arguments["materials"] as? Array<Dictionary<String, Any>> {
//          node.geometry?.materials = parseMaterials(materials)
//      }
//      updateNode(node, fromDict: arguments, forDevice: sceneView.device)
    }
  
    func onRemoveNode(_ arguments: Dictionary<String, Any>) {
        guard let nodeName = arguments["nodeName"] as? String else {
            logPluginError("nodeName deserialization failed", toChannel: channel)
            return
        }
//        let node = sceneView.scene.rootNode.childNode(withName: nodeName, recursively: true)
//        node?.removeFromParentNode()

        let entity = FlutterArkitView.arView?.scene.findEntity(named: nodeName)
        let anchor = entity?.anchor
       
        if anchor == nil { return }
        
        FlutterArkitView.arView?.scene.removeAnchor(entity!.anchor!)
    }
  
    func onRemoveAnchor(_ arguments: Dictionary<String, Any>) {
        guard let anchorIdentifier = arguments["anchorIdentifier"] as? String else {
            logPluginError("anchorIdentifier deserialization failed", toChannel: channel)
            return
        }
//        if let anchor = sceneView.session.currentFrame?.anchors.first(where:{ $0.identifier.uuidString == anchorIdentifier }) {
//            sceneView.session.remove(anchor: anchor)
//        }
    }
    
    func onAllClearObject() {
        FlutterArkitView.arView?.scene.anchors.removeAll()
    }
    
    func onGetNodeBoundingBox(_ arguments: Dictionary<String, Any>, _ result:FlutterResult) {
        guard let geometryArguments = arguments["geometry"] as? Dictionary<String, Any> else {
            logPluginError("geometryArguments deserialization failed", toChannel: channel)
            result(nil)
            return
        }
//        let geometry = createGeometry(geometryArguments, withDevice: sceneView.device)
//        let node = createNode(geometry, fromDict: arguments, forDevice: sceneView.device)
        
//        let resArray = [serializeVector(node.boundingBox.min), serializeVector(node.boundingBox.max)]
//        result(resArray)
    }
    
    func onTransformChanged(_ arguments: Dictionary<String, Any>) {
        guard let name = arguments["name"] as? String,
            let params = arguments["transformation"] as? Array<NSNumber>
            else {
                logPluginError("deserialization failed", toChannel: channel)
                return
        }
//        if let node = sceneView.scene.rootNode.childNode(withName: name, recursively: true) {
//            node.transform = deserializeMatrix4(params)
//        } else {
//            logPluginError("node not found", toChannel: channel)
//        }
    }
    
    func onIsHiddenChanged(_ arguments: Dictionary<String, Any>) {
        guard let name = arguments["name"] as? String,
            let params = arguments["isHidden"] as? Bool
            else {
                logPluginError("deserialization failed", toChannel: channel)
                return
        }
//        if let node = sceneView.scene.rootNode.childNode(withName: name, recursively: true) {
//            node.isHidden = params
//        } else {
//            logPluginError("node not found", toChannel: channel)
//        }
    }
    
    func onUpdateSingleProperty(_ arguments: Dictionary<String, Any>) {
        guard let name = arguments["name"] as? String,
            let args = arguments["property"] as? Dictionary<String, Any>,
            let propertyName = args["propertyName"] as? String,
            let propertyValue = args["propertyValue"],
            let keyProperty = args["keyProperty"] as? String
            else {
                logPluginError("deserialization failed", toChannel: channel)
                return
        }
        
//        if let node = sceneView.scene.rootNode.childNode(withName: name, recursively: true) {
//            if let obj = node.value(forKey: keyProperty) as? NSObject {
//                obj.setValue(propertyValue, forKey: propertyName)
//            } else {
//                logPluginError("value is not a NSObject", toChannel: channel)
//            }
//        } else {
//            logPluginError("node not found", toChannel: channel)
//        }
    }
    
    func onUpdateMaterials(_ arguments: Dictionary<String, Any>) {
        guard let name = arguments["name"] as? String,
            let rawMaterials = arguments["materials"] as? Array<Dictionary<String, Any>>
            else {
                logPluginError("deserialization failed", toChannel: channel)
                return
        }
//        if let node = sceneView.scene.rootNode.childNode(withName: name, recursively: true) {
            
//            let materials = parseMaterials(rawMaterials)
//            node.geometry?.materials = materials
//        } else {
//            logPluginError("node not found", toChannel: channel)
//        }
    }
    
    func onUpdateFaceGeometry(_ arguments: Dictionary<String, Any>) {
        #if !DISABLE_TRUEDEPTH_API
        guard let name = arguments["name"] as? String,
            let param = arguments["geometry"] as? Dictionary<String, Any>,
            let fromAnchorId = param["fromAnchorId"] as? String
            else {
                logPluginError("deserialization failed", toChannel: channel)
                return
        }
//        if let node = sceneView.scene.rootNode.childNode(withName: name, recursively: true),
//            let geometry = node.geometry as? ARSCNFaceGeometry,
//            let anchor = sceneView.session.currentFrame?.anchors.first(where: {$0.identifier.uuidString == fromAnchorId}) as? ARFaceAnchor
//        {
//            geometry.update(from: anchor.geometry)
//        } else {
//            logPluginError("node not found, geometry was empty, or anchor not found", toChannel: channel)
//        }
        #else
        logPluginError("TRUEDEPTH_API disabled", toChannel: channel)
        #endif
    }
    
    func onPerformHitTest(_ arguments: Dictionary<String, Any>, _ result: FlutterResult) {
        
        if FlutterArkitView.arView == nil {
            result(nil)
            return
        }
        guard let x = arguments["x"] as? Double,
            let y = arguments["y"] as? Double else {
                logPluginError("deserialization failed", toChannel: channel)
                result(nil)
                return
        }
        let viewWidth = FlutterArkitView.arView!.bounds.size.width
        let viewHeight = FlutterArkitView.arView!.bounds.size.height
        let location = CGPoint(x: viewWidth * CGFloat(x), y: viewHeight * CGFloat(y));
//        let arHitResults = getARHitResultsArray(sceneView, atLocation: location)
        let arHitResults = getARHitResultsArrayRealityKit(FlutterArkitView.arView!, atLocation: location)
        result(arHitResults)
    }
    
    func onGetLightEstimate(_ result: FlutterResult) {
        if FlutterArkitView.arView == nil {
            result(nil)
            return
        }
        
        let frame = FlutterArkitView.arView!.session.currentFrame
        if let lightEstimate = frame?.lightEstimate {
            let res = ["ambientIntensity": lightEstimate.ambientIntensity, "ambientColorTemperature": lightEstimate.ambientColorTemperature]
            result(res)
        } else {
            result(nil)
        }
    }
    
    func onProjectPoint(_ arguments: Dictionary<String, Any>, _ result: FlutterResult) {
        guard let rawPoint = arguments["point"] as? Array<Double> else {
            logPluginError("deserialization failed", toChannel: channel)
            result(nil)
            return
        }
//        let point = deserizlieVector3(rawPoint)
//        let projectedPoint = sceneView.projectPoint(point)
//        let res = serializeVector(projectedPoint)
//        result(res)
        result(nil)
    }
    
    func onCameraProjectionMatrix(_ result: FlutterResult) {
        if FlutterArkitView.arView == nil {
            result(nil)
            return
        }
        if let frame = FlutterArkitView.arView!.session.currentFrame {
            let matrix = serializeMatrix(frame.camera.projectionMatrix)
            result(matrix)
        } else {
            result(nil)
        }
    }
  
    func onPointOfViewTransform(_ result: FlutterResult) {
//        if let pointOfView = sceneView.pointOfView {
//          let matrix = serializeMatrix(pointOfView.simdWorldTransform)
//            result(matrix)
//        } else {
//            result(nil)
//        }
        result(nil)
    }
    
    func onPlayAnimation(_ arguments: Dictionary<String, Any>) {
        guard let key = arguments["key"] as? String,
            let sceneName = arguments["sceneName"] as? String,
            let animationIdentifier = arguments["animationIdentifier"] as? String else {
                logPluginError("deserialization failed", toChannel: channel)
                return
        }
        
//        if let sceneUrl = Bundle.main.url(forResource: sceneName, withExtension: "dae"),
//            let sceneSource = SCNSceneSource(url: sceneUrl, options: nil),
//            let animation = sceneSource.entryWithIdentifier(animationIdentifier, withClass: CAAnimation.self) {
//            animation.repeatCount = 1
//            animation.fadeInDuration = 1
//            animation.fadeOutDuration = 0.5
//            sceneView.scene.rootNode.addAnimation(animation, forKey: key)
//        } else {
//            logPluginError("animation failed", toChannel: channel)
//        }
    }
    
    func onStopAnimation(_ arguments: Dictionary<String, Any>) {
        guard let key = arguments["key"] as? String else {
            logPluginError("deserialization failed", toChannel: channel)
            return
        }
//        sceneView.scene.rootNode.removeAnimation(forKey: key)
    }

    func onCameraEulerAngles(_ result: FlutterResult){
        if FlutterArkitView.arView == nil {
            result(nil)
            return
        }
        if let frame = FlutterArkitView.arView!.session.currentFrame {
            let res = serializeArray(frame.camera.eulerAngles)
            result(res)
        } else {
            result(nil)
        }
   }
    
    enum AuthResult {
        case success(Bool), failure(Error)
    }
    
    func snapshotRun(compressionQuality: CGFloat) async throws -> Data? {
        NSLog("snapshotRun function -- START")
        var result: Data?
        await FlutterArkitView.arView?.snapshot(saveToHDR: false) {
            (image) in
            result = image?.jpegData(compressionQuality: compressionQuality)
            NSLog("arView?.snapshot run \(String(describing: result))")
        }
        NSLog("snapshotRun function -- END")
        return result
    }
    
    func onGetStreamSnapshot(_ arguments: Dictionary<String, Any>?, _ result: FlutterResult) {
        if self.bytes != nil {
            gettingBytes = true
            let data = FlutterStandardTypedData(bytes:bytes!)
            result(data)
        } else {
             result(nil)
        }
        gettingBytes = false
        return
    }

    func onGetSnapshot(_ arguments: Dictionary<String, Any>?, _ result: FlutterResult) {
        if self.bytes != nil {
            let data = FlutterStandardTypedData(bytes:bytes!)
            result(data)
        } else {
            result(nil)
        }
        
        if self.capturing {
            if self.bytes != nil {
                let data = FlutterStandardTypedData(bytes:bytes!)
                result(data)
            } else {
                result(nil)
            }
            return
        }
        
        let arFrame = FlutterArkitView.arView?.frame
        
        if arFrame == nil {
            result(nil)
            return
        }
        
        if arFrame!.height <= 0 && arFrame!.width <= 0 {
            result(nil)
            return
        }
        
        
        
        self.capturing = true
        
        let compressionQuality: Double = arguments?["compressionQuality"] as? Double ?? 0.8
        
        if FlutterArkitView.arView == nil {
            result(nil)
            return
        }
        
        
        
        FlutterArkitView.arView?.snapshot(saveToHDR: false) {
            [self] (image) in
            self.bytes = image?.jpegData(compressionQuality: compressionQuality)
            self.capturing = false
        }
        
        if self.bytes != nil {
            let data = FlutterStandardTypedData(bytes:bytes!)
            result(data)
        } else {
            result(nil)
        }
        
        return
    }
    
    func onGetCameraPosition(_ result: FlutterResult) {
        if let frame: ARFrame = FlutterArkitView.arView?.session.currentFrame {
            let cameraPosition = frame.camera.transform.columns.3
            let res = serializeArray(cameraPosition)
            result(res)
        } else {
            result(nil)
        }
     }
}
