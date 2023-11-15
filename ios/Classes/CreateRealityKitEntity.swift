//
//  CreateRealityKitEntity.swift
//  arkit_plugin
//
//  Created by Sung-Kyoung Park on 11/7/23.
//

import Foundation
import RealityKit
import SceneKit

func createAnchorEntity(geoArg: Dictionary<String, Any>?, trans: float4x4?) -> AnchorEntity? {
    
    
    if geoArg == nil {
        return nil
    }
    
    let inputArg = geoArg! as Dictionary<String, Any>
    let dartType = geoArg!["dartType"] as! String
    
    var entity:Entity?
    
    switch dartType {
    case "ARKitText":
        entity = createTextEntity(geoArg: inputArg, trans: trans)
        
    case "ARKitLine":
        return createLineAnchorEntity(geoArg: inputArg, trans: trans)
        
    default:
        return nil
    }
    
    if entity == nil { return nil }
    
    let anchor = AnchorEntity()
    anchor.addChild(entity!)
    anchor.transform.matrix = trans ?? float4x4.init()
    
    return anchor
}


func createTextEntity(geoArg: Dictionary<String, Any>, trans: float4x4?) -> Entity? {
    
    let arguments = geoArg
    let text = arguments["text"] as! String
    let extrusionDepth = arguments["extrusionDepth"] as! Float
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
    return textEntity
}

func createLineAnchorEntity(geoArg: Dictionary<String, Any>, trans: float4x4?) -> AnchorEntity? {
    NSLog("createLineAnchorEntity - START")
    let arguments = geoArg
    let fromVector = deserizlieVector3(arguments["fromVector"] as! Array<Double>)
    let toVector = deserizlieVector3(arguments["toVector"] as! Array<Double>)
    
    var upVector:SCNVector3?
    if arguments.keys.contains("upVector") {
        upVector = deserizlieVector3(arguments["upVector"] as! Array<Double>)
    }
    
    var thickness:Double?
    if arguments.keys.contains("thickness") {
        thickness = (arguments["thickness"] as! Double)
    }
    
    var color:Int?
    if arguments.keys.contains("color") {
        color = (arguments["color"] as! Int?)
    }
        
    
    let convertedToVector = simd_float3(toVector)
    let convertedFromVector = simd_float3(fromVector)
    let convertedUpVector = upVector == nil ? nil : simd_float3(upVector!)

    NSLog("[createLineAnchorEntity] ToVector \(convertedToVector) ")
    NSLog("[createLineAnchorEntity] FromVector \(convertedFromVector) ")

    let midPosition = (convertedToVector + convertedFromVector) / 2
    
    NSLog("[createLineAnchorEntity] midPosition result \(midPosition) ")
    
    
    let anchor = AnchorEntity()
    anchor.position = midPosition
    anchor.look(at: convertedFromVector, from: midPosition, upVector: convertedUpVector ?? SIMD3(0, 1, 0), relativeTo: nil)
    
    let meters = simd_distance(convertedFromVector, convertedToVector)
    
//    let lineMaterial = SimpleMaterial(color: .red, roughness: 1, isMetallic: false)
    let lineMaterial = SimpleMaterial(color: color == nil ? .red : UIColor(rgb: UInt(color!)), roughness: 1, isMetallic: false)
    
    
    let bottomLineMesh = MeshResource.generateBox(width: Float(0.003 * (thickness ?? 1)), height: 0.001, depth: meters + 0.003, cornerRadius: 0.01)
//    let bottomLineMesh = MeshResource.generatePlane(width: 0.003, depth: meters + 0.003, cornerRadius: 0.01)
    
    let bottomLineEntity = ModelEntity(mesh: bottomLineMesh, materials: [lineMaterial])
    
//    bottomLineEntity.position = .init(0, 0, 0)
    anchor.addChild(bottomLineEntity)
    
    NSLog("[createLineAnchorEntity] thickness: \(String(describing: thickness))")
    NSLog("createLineAnchorEntity - END")
    return anchor
}
