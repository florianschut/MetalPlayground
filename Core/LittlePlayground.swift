//
//  Grote of kleine speeltuin?
//  LittlePlayground.swift
//  MetalPlayground
//
//  Created by Florian Schut on 17/09/2019.
//

import Foundation
import MetalKit
import ModelIO

class LittlePlayground {
    let renderer: Renderer
    let metalKitView: MTKView
    
    init? (metalKitView: MTKView){
        self.metalKitView = metalKitView
        guard let newRenderer = Renderer(metalKitView: self.metalKitView) else {
            print("Renderer could not be initialized")
            return nil
        }
        
        renderer = newRenderer
        
        renderer.mtkView(self.metalKitView, drawableSizeWillChange: self.metalKitView.drawableSize)
        
        self.metalKitView.delegate = renderer
        
        LoadResources()
        
    }
    
    private func LoadResources(){
        //Load meshes and textures
        if(false){//Code for helmet model, replace with do to reenable
            let helmetModel = PGModel()
            let modelUrl = Bundle.main.url(forResource: "model", withExtension: "obj")
            do{
                try helmetModel.buildMeshFromFile(url: modelUrl, device: metalKitView.device!, mtlVertexDescriptor: renderer.mtlVertexDescriptor)
            }catch{
                print("Unable to build MetalKit Mesh. Error info: \(error)")
            }
            
            let textureUrl = Bundle.main.url(forResource: "tex_u1_v1", withExtension: "jpg")
            do {
                try helmetModel.LoadTexture(url: textureUrl, device: metalKitView.device!, textureName: "T_CNS2092_Elora_C.png")
            } catch {
                print("Unable to load texture. Error info: \(error)")
            }
            self.renderer.pgModels.append(helmetModel)
        }
        
        if(false) {
            let dragonModel = PGModel()
            let modelUrl = Bundle.main.url(forResource: "dragon", withExtension: "obj")
            do{
                try dragonModel.buildMeshFromFile(url: modelUrl, device: metalKitView.device!, mtlVertexDescriptor: renderer.mtlVertexDescriptor)
            }catch{
                print("Unable to build MetalKit Mesh. Error info: \(error)")
            }
            self.renderer.pgModels.append(dragonModel)
        }
        do{
            let model = PGModel()
            let modelUrl = Bundle.main.url(forResource: "craneo", withExtension: "OBJ")
            do{
                try model.buildMeshFromFile(url: modelUrl, device: metalKitView.device!, mtlVertexDescriptor: renderer.mtlVertexDescriptor)
            }catch{
                print("Unable to build MetalKit Mesh. Error info: \(error)")
            }
            
            let textureUrl = Bundle.main.url(forResource: "difuso_flip_oscuro_5", withExtension: "jpg")
            do {
                try model.LoadTexture(url: textureUrl, device: metalKitView.device!, textureName: "difuso_flip_oscuro_5.jpg")
            } catch {
                print("Unable to load texture. Error info: \(error)")
            }
            self.renderer.pgModels.append(model)
        }
        do{
            let model = PGModel()
            do{
                try model.buildDebugCube(dimensions: vector_float3(1,1,1), device: metalKitView.device!, mtlVertexDescriptor: renderer.mtlVertexDescriptor)
            }catch{
                print("Unable to build MetalKit Mesh. Error info: \(error)")
            }
            
            let textureUrl = Bundle.main.url(forResource: "difuso_flip_oscuro_5", withExtension: "jpg")
            do {
                try model.LoadTexture(url: textureUrl, device: metalKitView.device!, textureName: "difuso_flip_oscuro_5.jpg")
            } catch {
                print("Unable to load texture. Error info: \(error)")
            }
            
            self.renderer.pgModels.append(model)
        }
    }
    
}
