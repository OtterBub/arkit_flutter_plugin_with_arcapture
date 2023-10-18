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
    static func entityEditMaterialLoop(entity: Entity, depth: Int = 0,
                                material: SimpleMaterial,
                                physicMaterial: PhysicallyBasedMaterial? = nil) -> Entity
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
}
