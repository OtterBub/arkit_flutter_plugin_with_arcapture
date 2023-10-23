//
//  RealityKitUtil.swift
//  arkit_plugin
//
//  Created by Sung-Kyoung Park on 10/18/23.
//

import ARKit
import RealityKit

class RealityKitUtil {
    
    @available(iOS 15.0, *)
    static func entityEditMaterialLoop(
        entity: Entity,
        material: Material,
        physicMaterial: PhysicallyBasedMaterial? = nil,
        depth: Int = 0
    ) -> Entity
    {
        for (index, comp) in entity.children.enumerated() {
            NSLog("Loop [\(index)] is \(comp)")

            var modelComp: ModelComponent? = comp.components[ModelComponent.self]
            if modelComp != nil {
                if modelComp!.materials.isEmpty {
                    modelComp!.materials.append(material)
                }
                
                if physicMaterial != nil {
                    modelComp!.materials.append(physicMaterial!)
                }
                
                entity.children[index].components.set(modelComp!)
            }
            
           
            var _ = entityEditMaterialLoop(entity: comp, material: material)
            
        }
        return entity
    }
    
    static func convertNodeToAnchorEntity(node: SCNNode) -> AnchorEntity? {
        let resultAnchorEntity = AnchorEntity()
        
        let newEntity = convertNodeToEntity(node: node)
        resultAnchorEntity.addChild(newEntity)
        
        return resultAnchorEntity
    }
    
    static func convertNodeToEntity(node: SCNNode) -> Entity {
        var resultEntity = Entity()
        
        let nodeGeo = node.geometry
        
        if nodeGeo != nil {
            
            let mesh = MDLMesh(scnGeometry: nodeGeo!)
            let asset = MDLAsset()
            asset.add(mesh)
            
            let documentsPath = NSSearchPathForDirectoriesInDomains( .documentDirectory, .userDomainMask, true)[0]
            let name = node.name ?? "SCNNode"
            
            let exportUrl = URL(fileURLWithPath: documentsPath + "/\(name)" + ( nodeGeo!.materials.isEmpty ? ".usdc" : ".obj"))
            do {
                try asset.export(to: exportUrl)
                NSLog("[RealityKitUtil] convertNodeToEntity export is success \n \(exportUrl)")
            } catch {
                NSLog("[RealityKitUtil] convertNodeToEntity export is error \(error)")
            }
            
            let loadEntity = try? Entity.load(contentsOf: exportUrl)
            if loadEntity == nil {
                NSLog("[RealityKitUtil] convertNodeToEntity load failed, objEntity is nil \(String(describing: resultEntity))")
            } else {
                resultEntity = loadEntity!
            }
            
            if #available(iOS 15.0, *) {
                resultEntity = RealityKitUtil.entityEditMaterialLoop(entity: resultEntity, material: SimpleMaterial(
                    color: UIColor(
                        red: CGFloat.random(in: 0...1),
                        green: CGFloat.random(in: 0...1),
                        blue: CGFloat.random(in: 0...1),
                        alpha: 1.0
                    ),
                    roughness: 0.5,
                    isMetallic: Bool.random()
                ))
            }
        }
        
        resultEntity.transform.matrix = simd_float4x4(node.transform)
        
        for childNode in node.childNodes {
            let childEntity = convertNodeToEntity(node: childNode)
            resultEntity.addChild(childEntity)
        }
        
        if node.name != nil {
            resultEntity.name = node.name!;
        }
        
        return resultEntity
    }
}

internal extension float4x4 {
    var orientation: simd_quatf {
        return simd_quaternion(self)
    }
}
