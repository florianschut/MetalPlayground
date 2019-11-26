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
        
        do{
            let skyboxModel = PGModel()
            try skyboxModel.buildSkyCube(device: metalKitView.device!, mtlVertexDescriptor: renderer.mtlSkyboxVertexDescriptor)
            
            try skyboxModel.albedoTextures.append(Utilities.LoadTextureFromAssets(name: "LuxoMap", device: metalKitView.device!))
            
            self.renderer.skybox = skyboxModel
            
        } catch {
            print("Unable to load Luxo Jr. Skybox textures")
        }
        
        do{
            let model = PGModel()
            let modelUrl = Bundle.main.url(forResource: "scifiTank", withExtension: "obj")
            
            try model.buildMeshFromFile(url: modelUrl, device: metalKitView.device!, mtlVertexDescriptor: renderer.mtlVertexDescriptor)
            
            let albedoUrl = Bundle.main.url(forResource: "DefaultMaterial_albedo", withExtension: "jpeg")
            let normalUrl = Bundle.main.url(forResource: "DefaultMaterial_normal", withExtension: "jpeg")
            let metallicUrl = Bundle.main.url(forResource: "DefaultMaterial_metallic", withExtension: "jpeg")
            let roughnessUrl = Bundle.main.url(forResource: "DefaultMaterial_roughness", withExtension: "jpeg")
            
            try model.albedoTextures.append( Utilities.LoadTextureFromFile(url: albedoUrl, device: metalKitView.device!))
            try model.normalTextures.append( Utilities.LoadTextureFromFile(url: normalUrl, device: metalKitView.device!))
            try model.metallicTextures.append( Utilities.LoadTextureFromFile(url: metallicUrl, device: metalKitView.device!))
            try model.roughnessTextures.append( Utilities.LoadTextureFromFile(url: roughnessUrl, device: metalKitView.device!))
           
            self.renderer.pgModels.append(model)
        } catch {
            print("Unable to load scifiTank model Error info: \(error)")
        }
        
        do{
            let model = PGModel()
          
            try model.buildDebugCube(dimensions: vector_float3(1,1,1), device: metalKitView.device!, mtlVertexDescriptor: renderer.mtlVertexDescriptor)
           
            self.renderer.pgModels.append(model)
        
        }catch {
            print("Unable to build MetalKit Mesh. Error info: \(error)")
        }
        
//        if(false){//Code for helmet model, replace with do to reenable
//            let helmetModel = PGModel()
//            let modelUrl = Bundle.main.url(forResource: "model", withExtension: "obj")
//            do{
//                try helmetModel.buildMeshFromFile(url: modelUrl, device: metalKitView.device!, mtlVertexDescriptor: renderer.mtlVertexDescriptor)
//            }catch{
//                print("Unable to build MetalKit Mesh. Error info: \(error)")
//            }
//
//            let textureUrl = Bundle.main.url(forResource: "tex_u1_v1", withExtension: "jpg")
//            do {
//                try helmetModel.albedoTextures.append(Utilities.LoadTextureFromFile( url: textureUrl, device: metalKitView.device!))
//            } catch {
//                print("Unable to load texture. Error info: \(error)")
//            }
//            self.renderer.pgModels.append(helmetModel)
//        }
//
//        if(false) {
//            let dragonModel = PGModel()
//            let modelUrl = Bundle.main.url(forResource: "dragon", withExtension: "obj")
//            do{
//                try dragonModel.buildMeshFromFile(url: modelUrl, device: metalKitView.device!, mtlVertexDescriptor: renderer.mtlVertexDescriptor)
//            }catch{
//                print("Unable to build MetalKit Mesh. Error info: \(error)")
//            }
//            self.renderer.pgModels.append(dragonModel)
//        }
//
//        if(false){
//            let model = PGModel()
//            let modelUrl = Bundle.main.url(forResource: "servoSkull", withExtension: "obj")
//            do{
//                try model.buildMeshFromFile(url: modelUrl, device: metalKitView.device!, mtlVertexDescriptor: renderer.mtlVertexDescriptor)
//            }catch{
//                print("Unable to build MetalKit Mesh. Error info: \(error)")
//            }
//
//            let faceAlbedoUrl = Bundle.main.url(forResource: "Servoskull_face_diff", withExtension: "jpg")
//            let faceNormalUrl = Bundle.main.url(forResource: "Servoskull_face_normal", withExtension: "jpg")
//            let faceGlossUrl = Bundle.main.url(forResource: "Servoskull_face_gloss", withExtension: "jpg")
//
//            let mehcanicsAlbedoUrl = Bundle.main.url(forResource: "Servoskull_mechanics_diff", withExtension: "jpg")
//            let mehcanicsNormalUrl = Bundle.main.url(forResource: "Servoskull_mechanics_normal", withExtension: "jpg")
//            let mehcanicsGlossUrl = Bundle.main.url(forResource: "Servoskull_mechanics_gloss", withExtension: "jpg")
//
//            do {
//                try model.albedoTextures.append( Utilities.LoadTextureFromFile(url: mehcanicsAlbedoUrl, device: metalKitView.device!))
//                try model.normalTextures.append( Utilities.LoadTextureFromFile(url: mehcanicsNormalUrl, device: metalKitView.device!))
//                //try model.glossTextures.append(Utilities.LoadTextureFromFile(url: mehcanicsGlossUrl, device: metalKitView.device!))
//                try model.albedoTextures.append( Utilities.LoadTextureFromFile(url: faceAlbedoUrl, device: metalKitView.device!))
//                try model.normalTextures.append( Utilities.LoadTextureFromFile(url: faceNormalUrl, device: metalKitView.device!))
//                //try model.glossTextures.append(Utilities.LoadTextureFromFile(url: faceGlossUrl, device: metalKitView.device!))
//            } catch {
//                print("Unable to load texture. Error info: \(error)")
//            }
//            self.renderer.pgModels.append(model)
//        }
//
//        if false {
//            let model = PGModel()
//            do{
//                try model.buildSphere(diameter: 1, segments: 21, device: metalKitView.device!, mtlVertexDescriptor: renderer.mtlVertexDescriptor)
//            }catch{
//                print("Unable to build MetalKit Mesh. Error info: \(error)")
//            }
//
//            let albedoUrl = Bundle.main.url(forResource: "rustediron2_basecolor", withExtension: "png")
//            let normalUrl = Bundle.main.url(forResource: "rustediron2_normal", withExtension: "png")
//            let metallicUrl = Bundle.main.url(forResource: "rustediron2_metallic", withExtension: "png")
//            let roughnessUrl = Bundle.main.url(forResource: "rustediron2_roughness", withExtension: "png")
//
//            do {
//                try model.albedoTextures.append( Utilities.LoadTextureFromFile(url: albedoUrl, device: metalKitView.device!))
//                try model.normalTextures.append( Utilities.LoadTextureFromFile(url: normalUrl, device: metalKitView.device!))
//                try model.metallicTextures.append( Utilities.LoadTextureFromFile(url: metallicUrl, device: metalKitView.device!))
//                try model.roughnessTextures.append( Utilities.LoadTextureFromFile(url: roughnessUrl, device: metalKitView.device!))
//            } catch {
//                print("Unable to load texture. Error info: \(error)")
//            }
//
//            self.renderer.pgModels.append(model)
//        }
    }
}
