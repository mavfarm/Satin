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
        
//        enableCameraDragging()
        enableDebugUI()
    }
    
    private func enableCameraDragging() {
        /// Listen to dragging for transitioning UIGestureRecognizer
        let tap = UIPanGestureRecognizer(target: self, action: #selector(handleTouch))
        view.addGestureRecognizer(tap)
    }
    
    private func enableDebugUI() {
        /*
        self.view.addSubview(makeSlider(name: "Light X", index: 0, minAmount: -500, maxAmount: 500))
        self.view.addSubview(makeSlider(name: "Light Y", index: 1, minAmount: -500, maxAmount: 500))
        self.view.addSubview(makeSlider(name: "Light Z", index: 2, minAmount: -500, maxAmount: 500))
        
        self.view.addSubview(makeSlider(name: "Light R", index: 3, minAmount: 0, maxAmount: 1))
        self.view.addSubview(makeSlider(name: "Light G", index: 4, minAmount: 0, maxAmount: 1))
        self.view.addSubview(makeSlider(name: "Light B", index: 5, minAmount: 0, maxAmount: 1))
        self.view.addSubview(makeSlider(name: "Light A", index: 6, minAmount: 0, maxAmount: 1))
        
        self.view.addSubview(makeSlider(name: "Ambient R", index: 7, minAmount: 0, maxAmount: 1))
        self.view.addSubview(makeSlider(name: "Ambient G", index: 8, minAmount: 0, maxAmount: 1))
        self.view.addSubview(makeSlider(name: "Ambient B", index: 9, minAmount: 0, maxAmount: 1))
        self.view.addSubview(makeSlider(name: "Ambient A", index: 10, minAmount: 0, maxAmount: 1))
        
        self.view.addSubview(makeSlider(name: "Diffuse R", index: 11, minAmount: 0, maxAmount: 1))
        self.view.addSubview(makeSlider(name: "Diffuse G", index: 12, minAmount: 0, maxAmount: 1))
        self.view.addSubview(makeSlider(name: "Diffuse B", index: 13, minAmount: 0, maxAmount: 1))
        self.view.addSubview(makeSlider(name: "Diffuse A", index: 14, minAmount: 0, maxAmount: 1))
        
        self.view.addSubview(makeSlider(name: "Specular R", index: 15, minAmount: 0, maxAmount: 1))
        self.view.addSubview(makeSlider(name: "Specular G", index: 16, minAmount: 0, maxAmount: 1))
        self.view.addSubview(makeSlider(name: "Specular B", index: 17, minAmount: 0, maxAmount: 1))
        self.view.addSubview(makeSlider(name: "Specular A", index: 18, minAmount: 0, maxAmount: 1))
        
        self.view.addSubview(makeSlider(name: "Specular", index: 19, minAmount: 0, maxAmount: 1))
        self.view.addSubview(makeSlider(name: "Shininess", index: 20, minAmount: 0, maxAmount: 50))
 */
    }
    
    func makeSlider(name:String, index:Int, minAmount:Float, maxAmount:Float) -> UIView {
        let w = Int(UIScreen.main.bounds.width - 40)
        let h = 20
        let x = 20
        let padding = h + 10
        let y = padding * index + 20
        //
        let view = UIView(frame: CGRect(x: x, y: y, width: w, height: h))
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: h))
        label.textAlignment = .left
        label.text = name
        label.textColor = .blue
        view.addSubview(label)
        
        let slider = UISlider(frame: CGRect(x: 100, y: 0, width: w - 100, height: h))
        slider.accessibilityLabel = name
        slider.minimumValue = minAmount
        slider.maximumValue = maxAmount
        slider.addTarget(self, action: #selector(GameViewController.sliderChange(sender:)), for: .valueChanged)
        view.addSubview(slider)
        
        return view
    }
    
    @objc func sliderChange(sender:UISlider!) {
        if let label = sender.accessibilityLabel {
            
            let value = Float(sender.value)
            print(label, value)
            
            /*
            if(label == "Light X") {
                renderer.background.light.position.0 = value
            } else if(label == "Light Y") {
                renderer.background.light.position.1 = value
            } else if(label == "Light Z") {
                renderer.background.light.position.2 = value
            } else if(label == "Light R") {
                renderer.background.light.color.0 = value
            } else if(label == "Light G") {
                renderer.background.light.color.1 = value
            } else if(label == "Light B") {
                renderer.background.light.color.2 = value
            } else if(label == "Light A") {
                renderer.background.light.color.3 = value
            } else if(label == "Ambient R") {
                renderer.background.phong.ambientColor.0 = value
            } else if(label == "Ambient G") {
                renderer.background.phong.ambientColor.1 = value
            } else if(label == "Ambient B") {
                renderer.background.phong.ambientColor.2 = value
            } else if(label == "Ambient A") {
                renderer.background.phong.ambientColor.3 = value
            } else if(label == "Diffuse R") {
               renderer.background.phong.diffuseColor.0 = value
           } else if(label == "Diffuse G") {
               renderer.background.phong.diffuseColor.1 = value
           } else if(label == "Diffuse B") {
               renderer.background.phong.diffuseColor.2 = value
           } else if(label == "Diffuse A") {
               renderer.background.phong.diffuseColor.3 = value
           } else if(label == "Specular R") {
                renderer.background.phong.specularColor.0 = value
           } else if(label == "Specular G") {
               renderer.background.phong.specularColor.1 = value
           } else if(label == "Specular B") {
               renderer.background.phong.specularColor.2 = value
           } else if(label == "Specular A") {
               renderer.background.phong.specularColor.3 = value
           } else if(label == "Specular") {
                renderer.background.phong.settings.0 = value
           } else if(label == "Shininess") {
                print("updating...")
                renderer.background.phong.settings.1 = value
           }
             */
            
        }
    }
    
    @objc func handleTouch(recognizer:UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        
        let changeX:Float = clamp(value: Float(translation.x), minimum: -CameraSettings.distanceX, maximum: CameraSettings.distanceX) / CameraSettings.distanceX
        let targetX:Float = lerp(value: changeX, minimum: 0.0, maximum: CameraSettings.maxRotationX)
        
        let changeY:Float = clamp(value: Float(translation.y), minimum: -CameraSettings.distanceY, maximum: CameraSettings.distanceY) / CameraSettings.distanceY
        let targetY:Float = lerp(value: changeY, minimum: 0.0, maximum: CameraSettings.maxRotationY)
        
        if(recognizer.state == .ended) {
            let cameraSelection:Int = checkCameraSelection(x: targetX, y: -targetY)
            if(cameraSelection > -1) {
                if(cameraSelection < 2) {
                    renderer.menu.setItem(name: cameraSelection > 0 ? "right" : "left")
                    renderer.setCameraRotation(x: -targetX, y: 0)
                } else {
                    renderer.menu.setItem(name: cameraSelection > 2 ? "bottom" : "top")
                    renderer.setCameraRotation(x: 0, y: targetY)
                }
            } else {
                renderer.menu.setItem(name: "")
                renderer.resetCamera()
            }
        } else if(recognizer.state == .changed) {
            renderer.setCameraRotation(x: -targetX, y: targetY)
        }
    }
    
    /**
     * Which item it's currently looking at
     * 0 = Left
     * 1 = Right
     * 2 = Top
     * 3 = Bottom
     * -1 = None
     */
    func checkCameraSelection(x:Float, y:Float) -> Int {
        var selected:Int = -1
        let inYMiddle:Bool = y >= CameraSettings.rotationBottom && y <= CameraSettings.rotationTop
        
        if(inYMiddle) {
            if(x <= CameraSettings.rotationLeft) {
                selected = 0
            } else if(x >= CameraSettings.rotationRight) {
                selected = 1
            }
        } else {
            let inXMiddle:Bool = x >= CameraSettings.rotationLeft && x <= CameraSettings.rotationRight
            if(inXMiddle) {
                if(y >= CameraSettings.rotationTop) {
                    selected = 2
                } else if(y <= CameraSettings.rotationBottom) {
                    selected = 3
                }
            }
        }
        
        return selected
    }
}
