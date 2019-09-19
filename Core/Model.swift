//
//  Model.swift
//  MetalPlayground
//
//  Created by Florian Schut on 17/09/2019.
//

import Foundation
import MetalKit
import ModelIO

class PGModel{
    var meshes: [MTKMesh] = []
    var colorMaps: [MTLTexture] = []
    
    func buildMeshFromFile(url: URL!, device: MTLDevice, mtlVertexDescriptor: MTLVertexDescriptor) throws {
        let metalAllocator = MTKMeshBufferAllocator(device: device)

        let mdlVertexDescriptor = MTKModelIOVertexDescriptorFromMetal(mtlVertexDescriptor)

        guard let attributes = mdlVertexDescriptor.attributes as? [MDLVertexAttribute] else{
            print("Bad vertex descriptor when loading model from file \(String(describing: url))")
            throw RendererError.badVertexDescriptor
        }

        attributes[VertexAttribute.position.rawValue].name = MDLVertexAttributePosition
        attributes[VertexAttribute.texcoord.rawValue].name = MDLVertexAttributeTextureCoordinate
        attributes[VertexAttribute.normal.rawValue].name = MDLVertexAttributeNormal

        let asset = MDLAsset(url: url, vertexDescriptor: mdlVertexDescriptor, bufferAllocator: metalAllocator)

        let meshes = asset.childObjects(of: MDLMesh.self) as! [MDLMesh]
        for mesh in meshes{
            mesh.addNormals(withAttributeNamed: MDLVertexAttributeNormal, creaseThreshold: 1.0)
            try self.meshes.append(MTKMesh(mesh: mesh, device: device))
        }
    }
    
    func LoadTexture(url: URL!, device: MTLDevice, textureName: String) throws {
        let textureLoader = MTKTextureLoader(device: device)
        
        let textureLoaderOptions = [
            MTKTextureLoader.Option.textureUsage: NSNumber(value: MTLTextureUsage.shaderRead.rawValue),
            MTKTextureLoader.Option.textureStorageMode: NSNumber(value: MTLStorageMode.private.rawValue)
        ]

        self.colorMaps.append(try textureLoader.newTexture(URL: url, options: textureLoaderOptions))
    }
    
    
}
