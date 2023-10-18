import Foundation
import ARKit

extension FlutterArkitView: ARSessionDelegate {
    func session(_ session: ARSession, didFailWithError error: Error) {
        logPluginError("sessionDidFailWithError: \(error.localizedDescription)", toChannel: channel)
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera){
        var params = [String: NSNumber]()
        
        switch camera.trackingState {
        case .notAvailable:
            params["trackingState"] = 0
            break
        case .limited(let reason):
            params["trackingState"] = 1
            switch reason {
            case .initializing:
                params["reason"] = 1
                break
            case .relocalizing:
                params["reason"] = 2
                break
            case .excessiveMotion:
                params["reason"] = 3
                break
            case .insufficientFeatures:
                params["reason"] = 4
                break
            default:
                params["reason"] = 0
                break
            }
            break
        case .normal:
            params["trackingState"] = 2
            break
        }
        
        self.channel.invokeMethod("onCameraDidChangeTrackingState", arguments: params)
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        self.channel.invokeMethod("onSessionWasInterrupted", arguments: nil)
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        self.channel.invokeMethod("onSessionInterruptionEnded", arguments: nil)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if (node.name == nil) {
            node.name = NSUUID().uuidString
        }
        let params = prepareParamsForAnchorEvent(node, anchor)
        self.channel.invokeMethod("didAddNodeForAnchor", arguments: params)
    }
     
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        let params = prepareParamsForAnchorEvent(node, anchor)
        self.channel.invokeMethod("didUpdateNodeForAnchor", arguments: params)
    }

    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        let params = prepareParamsForAnchorEvent(node, anchor)
        self.channel.invokeMethod("didRemoveNodeForAnchor", arguments: params)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        let params = ["time": NSNumber(floatLiteral: time)]
        self.channel.invokeMethod("updateAtTime", arguments: params)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        if #available(iOS 13.4, *) {
            guard let meshAnchor = anchor as? ARMeshAnchor else {
                return nil
            }
            let geometry = createGeometryFromAnchor(meshAnchor: meshAnchor)
            //apply occlusion material
            geometry.firstMaterial?.colorBufferWriteMask = []
            geometry.firstMaterial?.writesToDepthBuffer = true
            geometry.firstMaterial?.readsFromDepthBuffer = true
            
            
            let node = SCNNode(geometry: geometry)
            //change rendering order so it renders before  our virtual object
            node.renderingOrder = -1
            return node
        } else {
            // Fallback on earlier versions
            return nil
        }
        
    }
    
    // Taken from https://developer.apple.com/forums/thread/130599
    @available(iOS 13.4, *)
    func createGeometryFromAnchor(meshAnchor: ARMeshAnchor) -> SCNGeometry {
        let meshGeometry = meshAnchor.geometry
        let vertices = meshGeometry.vertices
        let normals = meshGeometry.normals
        let faces = meshGeometry.faces
        
        // use the MTL buffer that ARKit gives us
        let vertexSource = SCNGeometrySource(buffer: vertices.buffer, vertexFormat: vertices.format, semantic: .vertex, vertexCount: vertices.count, dataOffset: vertices.offset, dataStride: vertices.stride)
        
        let normalsSource = SCNGeometrySource(buffer: normals.buffer, vertexFormat: normals.format, semantic: .normal, vertexCount: normals.count, dataOffset: normals.offset, dataStride: normals.stride)
        // Copy bytes as we may use them later
        let faceData = Data(bytes: faces.buffer.contents(), count: faces.buffer.length)
        
        // create the geometry element
        let geometryElement = SCNGeometryElement(data: faceData, primitiveType: primitiveType(type: faces.primitiveType), primitiveCount: faces.count, bytesPerIndex: faces.bytesPerIndex)
        
        return SCNGeometry(sources: [vertexSource, normalsSource], elements: [geometryElement])
    }

    @available(iOS 13.4, *)
    func primitiveType(type: ARGeometryPrimitiveType) -> SCNGeometryPrimitiveType {
            switch type {
                case .line: return .line
                case .triangle: return .triangles
            default : return .triangles
            }
    }
    
    fileprivate func prepareParamsForAnchorEvent(_ node: SCNNode, _ anchor: ARAnchor) -> Dictionary<String, Any> {
        var serializedAnchor = serializeAnchor(anchor)
        serializedAnchor["nodeName"] = node.name
        return serializedAnchor
    }
}
