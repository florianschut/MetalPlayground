//
//  ViewController.swift
//  MetalPlaygroundiOS
//
//  Created by Florian Schut on 12/09/2019.
//

import UIKit
import MetalKit

class ViewController: UIViewController {

   var renderer: Renderer!
    var mtkView: MTKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let mtkView = self.view as? MTKView else{
            print("View Attatched to ViewController is not a MTKView")
            return
        }
        
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            print("Metal is not supported on this device")
            return
        }
        
        mtkView.device = defaultDevice
        mtkView.backgroundColor = UIColor.white
        
        guard let newRenderer = Renderer(metalKitView: mtkView) else {
            print("Renderer could not be initialized")
            return
        }
        
        renderer = newRenderer
        
        renderer.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
        
        mtkView.delegate = renderer

    }
}
