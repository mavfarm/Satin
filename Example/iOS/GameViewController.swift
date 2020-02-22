//
//  GameViewController.swift
//  Example iOS
//
//  Created by Reza Ali on 8/22/19.
//  Copyright © 2019 Reza Ali. All rights reserved.
//

import UIKit
import MetalKit

// Our iOS specific view controller
class GameViewController: UIViewController {

    var renderer: Renderer!
    var mtkView: MTKView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let mtkView = self.view as? MTKView else {
            print("View of Gameview controller is not an MTKView")
            return
        }

        // Select the device to render with.  We choose the default device
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            print("Metal is not supported")
            return
        }

        mtkView.device = defaultDevice
        mtkView.backgroundColor = UIColor.black

        guard let newRenderer = Renderer(metalKitView: mtkView) else {
            print("Renderer cannot be initialized")
            return
        }

        renderer = newRenderer
        renderer.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
        mtkView.delegate = renderer
        
        if let myView = self.view {
            let pan = UIPanGestureRecognizer(target: self, action: #selector(panHandler))
            myView.addGestureRecognizer(pan)
        }
    }
    
    @objc
    func panHandler(_ recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .began || recognizer.state == .changed {
            let piece = recognizer.view!
            let pt = recognizer.location(in: piece)
            let normalX = Float(pt.x / UIScreen.main.bounds.width)
            let normalY = Float(pt.y / UIScreen.main.bounds.height)
            renderer.touch(normalX, normalY)
        }
    }
}
