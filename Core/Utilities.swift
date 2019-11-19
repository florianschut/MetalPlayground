//
//  Utility.swift
//  MetalPlayground
//
//  Created by Florian Schut on 03/10/2019.
//

import Foundation
import MetalKit
import Metal


final class Utilities {
    private static var whiteTexture: MTLTexture?

    enum Errors: Error {
        case errorMakingBuffer
        case errorMakingTexture
        
    }
    
    private init(){} //Class is static and should not be initialized

    class func GetWhiteTexture(device: MTLDevice) -> MTLTexture {
        if (self.whiteTexture == nil){
            //Creating empty texture
            let textureDesc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: 1, height: 1, mipmapped: false)
            guard let createdTexture = device.makeTexture(descriptor: textureDesc) else { fatalError("Could not create texture") }
            self.whiteTexture = createdTexture
            
            //Initializing texture to be white
            guard let whiteBuffer = device.makeBuffer(length: 32, options: [.storageModeShared]) else {fatalError("Could not create buffer")}
            let rawPtr = UnsafeMutableRawPointer(whiteBuffer.contents()).bindMemory(to: UInt8.self, capacity: 4)
            rawPtr.initialize(repeating: 255, count: 4)
            
            self.whiteTexture!.replace(region: MTLRegion(origin: MTLOrigin(x: 0,y: 0,z: 0), size:MTLSize(width: 1, height: 1, depth: 1) ), mipmapLevel: 0, withBytes: rawPtr, bytesPerRow: 256)
        }
        return self.whiteTexture!
    }
    
    class func GetBlackTexture(device: MTLDevice) -> MTLTexture {
        if (self.whiteTexture == nil){
            //Creating empty texture
            let textureDesc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: 1, height: 1, mipmapped: false)
            guard let createdTexture = device.makeTexture(descriptor: textureDesc) else { fatalError("Could not create texture") }
            self.whiteTexture = createdTexture
            
            //Initializing texture to be white
            guard let blackBuffer = device.makeBuffer(length: 32, options: [.storageModeShared]) else {fatalError("Could not create buffer")}
            let rawPtr = UnsafeMutableRawPointer(blackBuffer.contents()).bindMemory(to: UInt8.self, capacity: 4)
            rawPtr.initialize(repeating: 0, count: 4)
            
            self.whiteTexture!.replace(region: MTLRegion(origin: MTLOrigin(x: 0,y: 0,z: 0), size:MTLSize(width: 1, height: 1, depth: 1) ), mipmapLevel: 0, withBytes: rawPtr, bytesPerRow: 256)
        }
        return self.whiteTexture!
    }
    
    class func LoadTextureFromFile(url: URL!, device: MTLDevice) throws -> MTLTexture{
        let textureLoader = MTKTextureLoader(device: device)
        
        let textureLoaderOptions = [
            MTKTextureLoader.Option.textureUsage: NSNumber(value: MTLTextureUsage.shaderRead.rawValue),
            MTKTextureLoader.Option.textureStorageMode: NSNumber(value: MTLStorageMode.private.rawValue)
        ]
        return try textureLoader.newTexture(URL: url, options: textureLoaderOptions)
    }
    
    class func LoadTextureFromAssets(name: String!, device: MTLDevice) throws -> MTLTexture{
        let textureLoader = MTKTextureLoader(device: device)
        
        let textureLoaderOptions = [
            MTKTextureLoader.Option.textureUsage: NSNumber(value: MTLTextureUsage.shaderRead.rawValue),
            MTKTextureLoader.Option.textureStorageMode: NSNumber(value: MTLStorageMode.private.rawValue)
        ]
        return try textureLoader.newTexture(name: name, scaleFactor: 1, bundle: nil, options: textureLoaderOptions)
    }
}
