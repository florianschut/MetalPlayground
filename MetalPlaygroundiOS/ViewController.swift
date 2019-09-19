//
//  ViewController.swift
//  MetalPlaygroundiOS
//
//  Created by Florian Schut on 12/09/2019.
//

import UIKit
import MetalKit

class ViewController: UIViewController {

    var littlePlayground: LittlePlayground!
    
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
        
        guard let ourPlayground = LittlePlayground(metalKitView: mtkView) else {
            print("We are not going to the playground today")
            return
        }
        littlePlayground = ourPlayground

    }
}
