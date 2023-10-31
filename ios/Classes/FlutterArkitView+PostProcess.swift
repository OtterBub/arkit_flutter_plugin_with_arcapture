//
//  RealityKitPostProcess.swift
//  arkit_plugin
//
//  Created by Sung-Kyoung Park on 10/19/23.
//

import RealityKit

@available(iOS 15.0, *)
extension FlutterArkitView {
    func setupPostProcessing() {
        FlutterArkitView.arView?.renderCallbacks.postProcess = self.postProcess
    }
    
    func postProcess(context: ARView.PostProcessContext) {
        let blitEncoder = context.commandBuffer.makeBlitCommandEncoder()
        
        blitEncoder?.copy(from: context.sourceColorTexture, to: context.targetColorTexture)
        blitEncoder?.endEncoding()
        
        Task {
            if self.capturing {
//                NSLog("postProcess Task Block")
                return
            }
            self.capturing = true
            
            let ciimage = CIImage(mtlTexture: context.targetColorTexture)
            let cicontext = CIContext.init()
            let cgImage = cicontext.createCGImage(ciimage!, from: ciimage!.extent)
//            let imageData = cicontext.jpegRepresentation(of: ciimage!, colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!)
            
//            let uiimage = UIImage(data: imageData)?.
            let filterName = "CILanczosScaleTransform"
            let filter = CIFilter(name: filterName)
            filter?.setValue(ciimage, forKey: kCIInputImageKey)
            filter?.setValue(0.4, forKey: kCIInputScaleKey)
            
            let filterResult = filter?.outputImage
            
            
//            let image = UIImage(cgImage: cgImage!, scale: 0.5, orientation: .downMirrored)
            let image = UIImage(ciImage: filterResult!, scale: 1.0, orientation: .downMirrored)
            self.bytes = image.jpegData(compressionQuality: 0.8)
            self.capturing = false
            
//            NSLog("postProcess Task Run")
        }
    }
}
