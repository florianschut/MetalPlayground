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
    var albedoTextures: [MTLTexture] = []
    var normalTextures: [MTLTexture] = []
    var metallicTextures: [MTLTexture] = []
    var roughnessTextures: [MTLTexture] = []
    
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
        attributes[VertexAttribute.tangent.rawValue].name = MDLVertexAttributeTangent

        let asset = MDLAsset(url: url, vertexDescriptor: mdlVertexDescriptor, bufferAllocator: metalAllocator)

        let meshes = asset.childObjects(of: MDLMesh.self) as! [MDLMesh]
        for mesh in meshes{
            //mesh.addNormals(withAttributeNamed: MDLVertexAttributeNormal, creaseThreshold: 0.0)
            mesh.addOrthTanBasis(forTextureCoordinateAttributeNamed: MDLVertexAttributeTextureCoordinate, normalAttributeNamed: MDLVertexAttributeNormal, tangentAttributeNamed: MDLVertexAttributeTangent)
            try self.meshes.append(MTKMesh(mesh: mesh, device: device))
        }
    }
       
    
    func buildDebugCube(dimensions: vector_float3,device: MTLDevice, mtlVertexDescriptor: MTLVertexDescriptor) throws{
        let metalAllocator = MTKMeshBufferAllocator(device: device)
        
        let cubeMesh = MDLMesh.newBox(withDimensions: dimensions, segments: vector_uint3(2,2,2), geometryType: .triangles, inwardNormals: false, allocator: metalAllocator)
        
        let mdlVertexDescriptor = MTKModelIOVertexDescriptorFromMetal(mtlVertexDescriptor)
        
        guard let attributes = mdlVertexDescriptor.attributes as? [MDLVertexAttribute] else{
            print("Bad vertex descriptor when creating debug box")
            throw RendererError.badVertexDescriptor
        }

        attributes[VertexAttribute.position.rawValue].name = MDLVertexAttributePosition
        attributes[VertexAttribute.texcoord.rawValue].name = MDLVertexAttributeTextureCoordinate
        attributes[VertexAttribute.normal.rawValue].name = MDLVertexAttributeNormal
        
        cubeMesh.vertexDescriptor = mdlVertexDescriptor
        self.albedoTextures.append(Utilities.GetWhiteTexture(device: device))
        self.normalTextures.append(Utilities.GetWhiteTexture(device: device))
        self.metallicTextures.append(Utilities.GetWhiteTexture(device: device))
        self.roughnessTextures.append(Utilities.GetBlackTexture(device: device))
        try self.meshes.append(MTKMesh(mesh: cubeMesh, device: device))
    }
    
    func buildSphere(diameter: Float, segments: Int, device: MTLDevice, mtlVertexDescriptor: MTLVertexDescriptor) throws{
        let metalAllocator = MTKMeshBufferAllocator(device: device)
        
        let sphereMesh = MDLMesh.newEllipsoid(withRadii: simd_float3(diameter, diameter, diameter), radialSegments: segments, verticalSegments: segments, geometryType: .triangles, inwardNormals: false, hemisphere: false, allocator: metalAllocator)
    
        let mdlVertexDescriptor = MTKModelIOVertexDescriptorFromMetal(mtlVertexDescriptor)
        
        guard let attributes = mdlVertexDescriptor.attributes as? [MDLVertexAttribute] else{
            print("Bad vertex descriptor when creating sphere")
            throw RendererError.badVertexDescriptor
        }
        
        attributes[VertexAttribute.position.rawValue].name = MDLVertexAttributePosition
        attributes[VertexAttribute.texcoord.rawValue].name = MDLVertexAttributeTextureCoordinate
        attributes[VertexAttribute.normal.rawValue].name = MDLVertexAttributeNormal
        
        sphereMesh.vertexDescriptor = mdlVertexDescriptor
        try self.meshes.append(MTKMesh(mesh: sphereMesh, device: device))
    }
    
}
