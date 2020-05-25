//
//  ViewController.swift
//  MetalPlaygroundMac
//
//  Created by Florian Schut on 10/09/2019.
//

import Cocoa
import MetalKit
import ModelIO

class ViewController: NSViewController {
    
    var littlePlayground: LittlePlayground!
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
        
        guard let ourPlayground = LittlePlayground(metalKitView: mtkView) else {
            print("We are not going to the playground today")
            return
        }
        littlePlayground = ourPlayground
        
    }
  
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

