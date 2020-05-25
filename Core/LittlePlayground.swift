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
        AddSkybox(name: "LuxoMap")
        AddSciFiTank()
        AddDebugCube()
    }
    
    private func AddSkybox(name: String)
    {
        do{
            let skyboxModel = PGModel()
            try skyboxModel.buildSkyCube(device: metalKitView.device!, mtlVertexDescriptor: renderer.mtlSkyboxVertexDescriptor)
            
            try skyboxModel.albedoTextures.append(Utilities.LoadTextureFromAssets(name: name, device: metalKitView.device!))
            
            self.renderer.skybox = skyboxModel
            
        } catch {
            print("Unable to load Luxo Jr. Skybox textures")
        }
    }
    
    private func AddRustedSphere()
    {
        do {
            let model = PGModel()

            try model.buildSphere(diameter: 1, segments: 21, device: metalKitView.device!, mtlVertexDescriptor: renderer.mtlVertexDescriptor)

            let albedoUrl = Bundle.main.url(forResource: "rustediron2_basecolor", withExtension: "png")
            let normalUrl = Bundle.main.url(forResource: "rustediron2_normal", withExtension: "png")
            let metallicUrl = Bundle.main.url(forResource: "rustediron2_metallic", withExtension: "png")
            let roughnessUrl = Bundle.main.url(forResource: "rustediron2_roughness", withExtension: "png")

            try model.albedoTextures.append( Utilities.LoadTextureFromFile(url: albedoUrl, device: metalKitView.device!))
            try model.normalTextures.append( Utilities.LoadTextureFromFile(url: normalUrl, device: metalKitView.device!))
            try model.metallicTextures.append( Utilities.LoadTextureFromFile(url: metallicUrl, device: metalKitView.device!))
            try model.roughnessTextures.append( Utilities.LoadTextureFromFile(url: roughnessUrl, device: metalKitView.device!))

            self.renderer.pgModels.append(model)
        } catch {
            print("Unable to load rusted ball model Error info: \(error)")
        }
    }
    
    private func AddSciFiTank()
    {
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
    }
    
    private func AddDebugCube()
    {
        do{
            let model = PGModel()

            try model.buildDebugCube(dimensions: vector_float3(1,1,1), device: metalKitView.device!, mtlVertexDescriptor: renderer.mtlVertexDescriptor)

            self.renderer.pgModels.append(model)

        }catch {
            print("Unable to build MetalKit Mesh. Error info: \(error)")
        }
    }
}
