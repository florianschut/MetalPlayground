//
//  Utility.swift
//  MetalPlayground
//
//  Created by Florian Schut on 03/10/2019.
//

import Foundation
import Metal

class Utilities {
    private static var whiteTexture: MTLTexture?
    
    class func GetWhiteTexture(device: MTLDevice) -> MTLTexture? {
        if (whiteTexture == nil){
            let textureDesc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: 1, height: 1, mipmapped: false)
            whiteTexture = device.makeTexture(descriptor: textureDesc)//makeTexture(descriptor: textureDesc, offset: 0, bytesPerRow: 256)
            
            guard let whiteBuffer = device.makeBuffer(length: 32, options: [.storageModeShared]) else {return nil}
            
            let rawPtr = UnsafeMutableRawPointer(whiteBuffer.contents()).bindMemory(to: UInt8.self, capacity: 4)
            rawPtr.initialize(repeating: 255, count: 4)
            whiteTexture?.replace(region: MTLRegion(origin: MTLOrigin(x: 0,y: 0,z: 0), size:MTLSize(width: 1, height: 1, depth: 1) ), mipmapLevel: 0, withBytes: rawPtr, bytesPerRow: 256)
        }
        return whiteTexture!
    }
}
