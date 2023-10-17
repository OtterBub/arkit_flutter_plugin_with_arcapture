import ARKit
import RealityKit

extension FlutterArkitView {
    func initalize(_ arguments: Dictionary<String, Any>, _ result:FlutterResult) {
        
        initalizeGesutreRecognizers(arguments)
        
        self.configurationRealityKit = ARWorldTrackingConfiguration()
        
        if #available(iOS 13.4, *) {
            self.configurationRealityKit?.sceneReconstruction = .meshWithClassification
            self.configurationRealityKit?.planeDetection = [.horizontal, .vertical]
            self.arView?.environment.sceneUnderstanding.options.insert(.occlusion)
            self.arView?.debugOptions.insert(.showSceneUnderstanding)
            self.configurationRealityKit?.frameSemantics.insert(.personSegmentationWithDepth)
        } else {
            // Fallback on earlier versions
        }
        
        
        if(self.configurationRealityKit != nil) {
            self.arView?.session.run(configurationRealityKit!)
        }
        
        // test arview mesh
        testARViewMesh()
    }
    
    func entityLoop(entity: Entity, depth: Int = 0, material: SimpleMaterial) -> Entity {
        for (index, comp) in entity.children.enumerated() {
//            NSLog("Loop [\(index)] is \(comp)")

            var modelComp: ModelComponent? = comp.components[ModelComponent.self]
            if modelComp != nil {
                modelComp!.materials.removeAll()
                modelComp!.materials.append(
                    SimpleMaterial(color: UIColor(
                        red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1), alpha: 1.0)
                       , isMetallic: true))
                entity.children[index].components.set(modelComp!)
            }
            
           
            var _ = entityLoop(entity: comp, material: material)
            
        }
        return entity
    }
        
    
    func testARViewMesh() {
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
       
        // Create box
//        let mesh = MeshResource.generateBox(size: 0.1, cornerRadius: 0.005)
        let material = SimpleMaterial(color: .gray, roughness: 0.15, isMetallic: true)
//        let model = ModelEntity(mesh: mesh, materials: [material])

        // Create horizontal plane anchor for the content
//        let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
//        anchor.children.append(model)

        // Add the horizontal plane anchor to the scene
//        self.arView.scene.anchors.append(anchor)
        
//        let url = URL(fileURLWithPath: "models.scnassets/NuttellaLatte.usdz")
        
        // Test USDZ
//        let url = Bundle.main.url(forResource: "models.scnassets/NuttellaLatte", withExtension: "usdz")
        let url = Bundle.main.url(forResource: "models.scnassets/Boat.obj", withExtension: nil)
//        let url = Bundle.main.url(forResource: "models.scnassets/dash", withExtension: "dae")
        
        let mdlAsset = MDLAsset(url: url!)
        
        let name = "exportFile"
        
        let exportPath = URL(fileURLWithPath: documentsPath + "/\(name)" + ".usdc")
        
        do {
            let exportResult: () = try mdlAsset.export(to: exportPath)
//            NSLog("exportResult is success \(exportResult)")
        }
        catch {
            NSLog("exportResult is error \(error)")
        }
        
        let objEntity = try? Entity.load(contentsOf: exportPath)
        if objEntity == nil {
            NSLog("objEntity is nil \(String(describing: objEntity))")
            return
        }
        
        var modelComp: ModelComponent = objEntity!.children[0].children[0].components[ModelComponent.self] as! ModelComponent
        
        modelComp.materials.append(material)
        objEntity!.children[0].children[0].components.set(modelComp)
        
        let newEntity = entityLoop(entity: objEntity!, material: material)
        
//        for (index, comp) in objEntity!.children.enumerated() {
//            NSLog("Loop [\(index)] is \(comp)")
//        }
        
        
        
        
        let anchorLatte = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
        anchorLatte.children.append(newEntity)
        
        anchorLatte.scale = SIMD3(SCNVector3(x: 2, y: 2, z: 2))
        
        self.arView?.scene.anchors.append(anchorLatte)
    }
    
    func parseDebugOptions(_ arguments: Dictionary<String, Any>) -> SCNDebugOptions {
        var options = ARSCNDebugOptions().rawValue
        if let showFeaturePoint = arguments["showFeaturePoints"] as? Bool {
            if (showFeaturePoint) {
                options |= ARSCNDebugOptions.showFeaturePoints.rawValue
            }
        }
        if let showWorldOrigin = arguments["showWorldOrigin"] as? Bool {
            if (showWorldOrigin) {
                options |= ARSCNDebugOptions.showWorldOrigin.rawValue
            }
        }
        return ARSCNDebugOptions(rawValue: options)
    }
    
    func parseConfiguration(_ arguments: Dictionary<String, Any>) -> ARConfiguration? {
        let configurationType = arguments["configuration"] as! Int
        var configuration: ARConfiguration? = nil
        
        switch configurationType {
        case 0:
            configuration = createWorldTrackingConfiguration(arguments)
            break
        case 1:
            #if !DISABLE_TRUEDEPTH_API
            configuration = createFaceTrackingConfiguration(arguments)
            #else
            logPluginError("TRUEDEPTH_API disabled", toChannel: channel)
            #endif
            break
        case 2:
            if #available(iOS 12.0, *) {
                configuration = createImageTrackingConfiguration(arguments)
            } else {
                logPluginError("configuration is not supported on this device", toChannel: channel)
            }
            break
        case 3:
            if #available(iOS 13.0, *) {
                configuration = createBodyTrackingConfiguration(arguments)
            } else {
                logPluginError("configuration is not supported on this device", toChannel: channel)
            }
            break
        default:
            break
        }
        configuration?.worldAlignment = parseWorldAlignment(arguments)
        return configuration
    }
    
    func parseWorldAlignment(_ arguments: Dictionary<String, Any>) -> ARConfiguration.WorldAlignment {
        if let worldAlignment = arguments["worldAlignment"] as? Int {
            if worldAlignment == 0 {
                return .gravity
            }
            if worldAlignment == 1 {
                return .gravityAndHeading
            }
        }
        return .camera
    }
}
