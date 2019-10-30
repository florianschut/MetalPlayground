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
                try helmetModel.albedoTextures.append(Utilities.LoadTextureFromFile( url: textureUrl, device: metalKitView.device!))
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
        
        if(false){
            let model = PGModel()
            let modelUrl = Bundle.main.url(forResource: "servoSkull", withExtension: "obj")
            do{
                try model.buildMeshFromFile(url: modelUrl, device: metalKitView.device!, mtlVertexDescriptor: renderer.mtlVertexDescriptor)
            }catch{
                print("Unable to build MetalKit Mesh. Error info: \(error)")
            }
            
            let faceAlbedoUrl = Bundle.main.url(forResource: "Servoskull_face_diff", withExtension: "jpg")
            let faceNormalUrl = Bundle.main.url(forResource: "Servoskull_face_normal", withExtension: "jpg")
            let faceGlossUrl = Bundle.main.url(forResource: "Servoskull_face_gloss", withExtension: "jpg")
            
            let mehcanicsAlbedoUrl = Bundle.main.url(forResource: "Servoskull_mechanics_diff", withExtension: "jpg")
            let mehcanicsNormalUrl = Bundle.main.url(forResource: "Servoskull_mechanics_normal", withExtension: "jpg")
            let mehcanicsGlossUrl = Bundle.main.url(forResource: "Servoskull_mechanics_gloss", withExtension: "jpg")

            do {
                try model.albedoTextures.append( Utilities.LoadTextureFromFile(url: mehcanicsAlbedoUrl, device: metalKitView.device!))
                try model.normalTextures.append( Utilities.LoadTextureFromFile(url: mehcanicsNormalUrl, device: metalKitView.device!))
                //try model.glossTextures.append(Utilities.LoadTextureFromFile(url: mehcanicsGlossUrl, device: metalKitView.device!))
                try model.albedoTextures.append( Utilities.LoadTextureFromFile(url: faceAlbedoUrl, device: metalKitView.device!))
                try model.normalTextures.append( Utilities.LoadTextureFromFile(url: faceNormalUrl, device: metalKitView.device!))
                //try model.glossTextures.append(Utilities.LoadTextureFromFile(url: faceGlossUrl, device: metalKitView.device!))
            } catch {
                print("Unable to load texture. Error info: \(error)")
            }
            self.renderer.pgModels.append(model)
        }
        
        if(false) {
            let model = PGModel()
            let modelUrl = Bundle.main.url(forResource: "helmetWavefront", withExtension: "obj")
            
            do{
                try model.buildMeshFromFile(url: modelUrl, device: metalKitView.device!, mtlVertexDescriptor: renderer.mtlVertexDescriptor)
            }catch{
                print("Unable to build MetalKit Mesh. Error info: \(error)")
            }
            
            let albedoUrl = Bundle.main.url(forResource: "GAP_Exam_BaseColor_OlmoPotums_2DAE2", withExtension: "png")
            let normalUrl = Bundle.main.url(forResource: "GAP_Exam_Normal_OlmoPotums_2DAE2", withExtension: "png")
            let metallicUrl = Bundle.main.url(forResource: "GAP_Exam_Metal_OlmoPotums_2DAE2", withExtension: "png")
            let roughnessUrl = Bundle.main.url(forResource: "GAP_Exam_Rough_OlmoPotums_2DAE2", withExtension: "png")
            
            do {
                try model.albedoTextures.append( Utilities.LoadTextureFromFile(url: albedoUrl, device: metalKitView.device!))
                try model.normalTextures.append( Utilities.LoadTextureFromFile(url: normalUrl, device: metalKitView.device!))
                try model.metallicTextures.append( Utilities.LoadTextureFromFile(url: metallicUrl, device: metalKitView.device!))
                try model.roughnessTextures.append( Utilities.LoadTextureFromFile(url: roughnessUrl, device: metalKitView.device!))
            } catch {
                print("Unable to load texture. Error info: \(error)")
            }
            self.renderer.pgModels.append(model)
        }
        do{
            let model = PGModel()
            let modelUrl = Bundle.main.url(forResource: "scifiTank", withExtension: "obj")
            
            do{
                try model.buildMeshFromFile(url: modelUrl, device: metalKitView.device!, mtlVertexDescriptor: renderer.mtlVertexDescriptor)
            }catch{
                print("Unable to build MetalKit Mesh. Error info: \(error)")
            }
            
            let albedoUrl = Bundle.main.url(forResource: "DefaultMaterial_albedo", withExtension: "jpeg")
            let normalUrl = Bundle.main.url(forResource: "DefaultMaterial_normal", withExtension: "jpeg")
            let metallicUrl = Bundle.main.url(forResource: "DefaultMaterial_metallic", withExtension: "jpeg")
            let roughnessUrl = Bundle.main.url(forResource: "DefaultMaterial_roughness", withExtension: "jpeg")
            
            do {
                try model.albedoTextures.append( Utilities.LoadTextureFromFile(url: albedoUrl, device: metalKitView.device!))
                try model.normalTextures.append( Utilities.LoadTextureFromFile(url: normalUrl, device: metalKitView.device!))
                try model.metallicTextures.append( Utilities.LoadTextureFromFile(url: metallicUrl, device: metalKitView.device!))
                try model.roughnessTextures.append( Utilities.LoadTextureFromFile(url: roughnessUrl, device: metalKitView.device!))
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
            self.renderer.pgModels.append(model)
        
        }
    }
}
