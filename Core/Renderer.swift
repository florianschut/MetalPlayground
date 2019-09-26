//
//  File.swift
//  MetalPlaygroundMac
//
//  Created by Florian Schut on 10/09/2019.
//

import Metal
import MetalKit
import simd
import ModelIO


let alignedUniformsSize = (MemoryLayout<Uniforms>.size + 0xff) & -0x100

let maxBuffersInFlight = 3

enum RendererError: Error {
    case badVertexDescriptor
}

class Renderer: NSObject, MTKViewDelegate
{
    public let device: MTLDevice
    let commandQueue: MTLCommandQueue
    var dynamicUniformBuffer: MTLBuffer
    var pipelineState: MTLRenderPipelineState
    var depthState: MTLDepthStencilState
    let mtlVertexDescriptor: MTLVertexDescriptor
    var pgModels: [PGModel] = []
    var cubeModel: PGModel;
    
    var roatationVector: vector_float4 = vector_float4()
    
    let inFlightSemaphore = DispatchSemaphore(value: maxBuffersInFlight)

    var uniformBufferOffset = 0

    var uniformBufferIndex = 0

    var uniforms: UnsafeMutablePointer<Uniforms>

    var projectionMatrix: matrix_float4x4 = matrix_float4x4()

    var rotation: Float = 0.5//.5 * Float.pi
    var pointLight = Light(position: vector_float4(-2.0, 1.0, 2.0, 1), color: vector_float4(1.0,1.0,1.0,1.0))

    init?(metalKitView: MTKView)
    {
        self.device = metalKitView.device!
        guard let queue = self.device.makeCommandQueue() else {return nil}
        self.commandQueue = queue

        let uniformBufferSize = alignedUniformsSize * maxBuffersInFlight
        
        guard let buffer = self.device.makeBuffer(length: uniformBufferSize, options: [MTLResourceOptions.storageModeShared]) else {return nil}
        dynamicUniformBuffer = buffer
        
        self.dynamicUniformBuffer.label = "UniformBuffer"
        
        uniforms = UnsafeMutableRawPointer(dynamicUniformBuffer.contents()).bindMemory(to: Uniforms.self, capacity: 1)
        
        metalKitView.depthStencilPixelFormat = MTLPixelFormat.depth32Float_stencil8
        metalKitView.colorPixelFormat = MTLPixelFormat.bgra8Unorm_srgb
        metalKitView.sampleCount = 1
        
        mtlVertexDescriptor = Renderer.buildMetalVertexDescriptor()
        
        do{
            pipelineState = try Renderer.buildRenderPipelineWithDevice(device: device, metalKitView: metalKitView, mtlVertexDescriptor: mtlVertexDescriptor)
        } catch {
            print("Unable to compile render pipeline state. Error info: \(error)")
            return nil
        }
        
        let depthStateDescriptor = MTLDepthStencilDescriptor()
        depthStateDescriptor.depthCompareFunction = MTLCompareFunction.less
        depthStateDescriptor.isDepthWriteEnabled = true
        guard let state = device.makeDepthStencilState(descriptor: depthStateDescriptor) else {return nil}
        depthState = state
        
        cubeModel = PGModel()
        cubeModel.buildDebugCube(dimensions: vector_float3(0.25,0.25,0.25), device: self.device, mtlVertexDescriptor: mtlVertexDescriptor)
        
        super.init()
        
    }
    
    class func buildMetalVertexDescriptor() -> MTLVertexDescriptor{
        
        let mtlVertexDescriptor = MTLVertexDescriptor()
        
        mtlVertexDescriptor.attributes[VertexAttribute.position.rawValue].format = MTLVertexFormat.float3
        mtlVertexDescriptor.attributes[VertexAttribute.position.rawValue].offset = 0
        mtlVertexDescriptor.attributes[VertexAttribute.position.rawValue].bufferIndex = BufferIndex.meshPositions.rawValue
        
        mtlVertexDescriptor.attributes[VertexAttribute.normal.rawValue].format = MTLVertexFormat.float3
        mtlVertexDescriptor.attributes[VertexAttribute.normal.rawValue].offset = 0
        mtlVertexDescriptor.attributes[VertexAttribute.normal.rawValue].bufferIndex = BufferIndex.meshNormals.rawValue
        
        mtlVertexDescriptor.attributes[VertexAttribute.texcoord.rawValue].format = MTLVertexFormat.float2
        mtlVertexDescriptor.attributes[VertexAttribute.texcoord.rawValue].offset = 0
        mtlVertexDescriptor.attributes[VertexAttribute.texcoord.rawValue].bufferIndex = BufferIndex.meshGenerics.rawValue
        
        mtlVertexDescriptor.layouts[BufferIndex.meshPositions.rawValue].stride = 12
        mtlVertexDescriptor.layouts[BufferIndex.meshPositions.rawValue].stepRate = 1
        mtlVertexDescriptor.layouts[BufferIndex.meshPositions.rawValue].stepFunction = MTLVertexStepFunction.perVertex
        
        mtlVertexDescriptor.layouts[BufferIndex.meshNormals.rawValue].stride = 12
        mtlVertexDescriptor.layouts[BufferIndex.meshNormals.rawValue].stepRate = 1
        mtlVertexDescriptor.layouts[BufferIndex.meshNormals.rawValue].stepFunction = MTLVertexStepFunction.perVertex

        mtlVertexDescriptor.layouts[BufferIndex.meshGenerics.rawValue].stride = 8
        mtlVertexDescriptor.layouts[BufferIndex.meshGenerics.rawValue].stepRate = 1
        mtlVertexDescriptor.layouts[BufferIndex.meshGenerics.rawValue].stepFunction = MTLVertexStepFunction.perVertex
        
        return mtlVertexDescriptor
    }
    
    class func buildRenderPipelineWithDevice(device: MTLDevice, metalKitView: MTKView, mtlVertexDescriptor: MTLVertexDescriptor) throws -> MTLRenderPipelineState {
        
        let library = device.makeDefaultLibrary()
        
        let vertexFunction = library?.makeFunction(name: "vertexShader")
        let fragmentFunction = library?.makeFunction(name: "fragmentShader")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.label = "DefaultRenderPipeline"
        pipelineDescriptor.sampleCount = metalKitView.sampleCount;
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.vertexDescriptor = mtlVertexDescriptor
    
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat = metalKitView.depthStencilPixelFormat
        pipelineDescriptor.stencilAttachmentPixelFormat = metalKitView.depthStencilPixelFormat
        
        return try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        
    }
    
    func addModel(pgModel: PGModel){
        self.pgModels.append(pgModel)
    }
    func addModel(pgModels: [PGModel]){
        self.pgModels += pgModels
    }

    private func updateDynamicBufferState(){
        uniformBufferIndex = (uniformBufferIndex + 1) % maxBuffersInFlight
        
        uniformBufferOffset = alignedUniformsSize * uniformBufferIndex
        
        uniforms = UnsafeMutableRawPointer(dynamicUniformBuffer.contents() + uniformBufferOffset).bindMemory(to: Uniforms.self, capacity: 1)
    }
    var lightRotation:Float = 0.0
    
    //TODO: Doesn't have anything to do with renderer
    private func updateGameState(){
        uniforms[0].projectionMatrix = projectionMatrix
        
        let rotationAxis = SIMD3<Float>(0,1,0)
        let modelMatrix = matrix4x4_rotation(radians: rotation, axis: rotationAxis)
        //let cameraRotation = matrix4x4_rotation(radians: radians_from_degrees(33), axis: rotationAxis)
       // let modelMatrix = matrix4x4_translation(self.translation.x, self.translation.y, self.translation.z)
        let viewTransform = matrix4x4_translation(0.0, 0.0, 2.5)
        //viewTransform *= cameraRotation
        uniforms[0].modelMatrix = modelMatrix
        let lightRotationMatrix = matrix4x4_rotation(radians: lightRotation, axis: rotationAxis)
        
        uniforms[0].viewMatrix = simd_inverse(viewTransform)
        self.pointLight.position = lightRotationMatrix * vector_float4(0,0,11,1)
        uniforms[0].lights = self.pointLight
        lightRotation += 0.015
        //self.rotation += 0.005
       // self.translation += vector_float3(0.00, 0.00, 0.00)
       
    }
    
    func draw(in view: MTKView) {
        _ = inFlightSemaphore.wait(timeout: DispatchTime.distantFuture)
        
        if let commandBuffer = commandQueue.makeCommandBuffer(){
            
            let semaphore = inFlightSemaphore
            commandBuffer.addCompletedHandler{(_ commandBuffer)-> Swift.Void in
                semaphore.signal()
            }
            
            self.updateDynamicBufferState()
            self.updateGameState()
            
            let renderPassDescriptor = view.currentRenderPassDescriptor
            
            if let renderPassDescriptor = renderPassDescriptor, let renderEncoder =
                commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor){
                
                renderEncoder.label = "Primary Render Encoder"
                
                renderEncoder.pushDebugGroup("Draw Box")
                
                renderEncoder.setCullMode(.back)
                
                renderEncoder.setFrontFacing(.counterClockwise)
                
                renderEncoder.setRenderPipelineState(pipelineState)
                
                renderEncoder.setDepthStencilState(depthState)
                
                renderEncoder.setVertexBuffer(dynamicUniformBuffer, offset: uniformBufferOffset, index: BufferIndex.uniforms.rawValue)
                renderEncoder.setFragmentBuffer(dynamicUniformBuffer, offset: uniformBufferOffset, index: BufferIndex.uniforms.rawValue)
                for model in self.pgModels {
                    //TODO: Add logic for multiple textures and no textures
                    renderEncoder.setFragmentTexture(model.colorMaps[0], index: TextureIndex.color.rawValue)
                    
                    //TODO: Read up on this stuff
                    for mesh in model.meshes {
                        for (index, element) in mesh.vertexDescriptor.layouts.enumerated(){
                            guard let layout = element as? MDLVertexBufferLayout else{
                                return
                            }
                            
                            if layout.stride != 0 {
                                let buffer = mesh.vertexBuffers[index]
                                renderEncoder.setVertexBuffer(buffer.buffer, offset: buffer.offset, index: index)
                            }
                        }
                        for submesh in mesh.submeshes {
                            renderEncoder.drawIndexedPrimitives(type: submesh.primitiveType, indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer, indexBufferOffset: submesh.indexBuffer.offset)
                        }
                    }
                }
                //renderEncoder.drawIndexedPrimitives(type: , indexCount: <#T##Int#>, indexType: <#T##MTLIndexType#>, indexBuffer: <#T##MTLBuffer#>, indexBufferOffset: <#T##Int#>)
                
                renderEncoder.popDebugGroup()
                
                renderEncoder.endEncoding()
                
                if let drawable = view.currentDrawable {
                    commandBuffer.present(drawable)
                }
            }
            commandBuffer.commit()
        }
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        let aspect = Float(size.width) / Float(size.height)
        projectionMatrix = matrix_perspective_right_hand(fovyRadians: radians_from_degrees(65), aspectRatio: aspect, nearZ: 0.01, farZ: 10.0)
    }
}

// Generic matrix math utility functions
func matrix4x4_rotation(radians: Float, axis: SIMD3<Float>) -> matrix_float4x4 {
    let unitAxis = normalize(axis)
    let ct = cosf(radians)
    let st = sinf(radians)
    let ci = 1 - ct
    let x = unitAxis.x, y = unitAxis.y, z = unitAxis.z
    return matrix_float4x4.init(columns:(vector_float4(    ct + x * x * ci, y * x * ci + z * st, z * x * ci - y * st, 0),
                                         vector_float4(x * y * ci - z * st,     ct + y * y * ci, z * y * ci + x * st, 0),
                                         vector_float4(x * z * ci + y * st, y * z * ci - x * st,     ct + z * z * ci, 0),
                                         vector_float4(                  0,                   0,                   0, 1)))
}

func matrix4x4_translation(_ translationX: Float, _ translationY: Float, _ translationZ: Float) -> matrix_float4x4 {
    return matrix_float4x4.init(columns:(vector_float4(1, 0, 0, 0),
                                         vector_float4(0, 1, 0, 0),
                                         vector_float4(0, 0, 1, 0),
                                         vector_float4(translationX, translationY, translationZ, 1)))
}

func matrix_perspective_right_hand(fovyRadians fovy: Float, aspectRatio: Float, nearZ: Float, farZ: Float) -> matrix_float4x4 {
    let ys = 1 / tanf(fovy * 0.5)
    let xs = ys / aspectRatio
    let zs = farZ / (nearZ - farZ)
    return matrix_float4x4.init(columns:(vector_float4(xs,  0, 0,   0),
                                         vector_float4( 0, ys, 0,   0),
                                         vector_float4( 0,  0, zs, -1),
                                         vector_float4( 0,  0, zs * nearZ, 0)))
}

func radians_from_degrees(_ degrees: Float) -> Float {
    return (degrees / 180) * .pi
}

