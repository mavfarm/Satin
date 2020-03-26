//
//  SceneKitScene.swift
//  Example iOS
//
//  Created by Colin Duffy on 3/25/20.
//  Copyright © 2020 Reza Ali. All rights reserved.
//

import Satin
import SceneKit

/**
 * An example scene
 */
class SceneKitScene {
    
    public var renderer: SCNRenderer!
    public var view: SCNView!
    public var scene: SCNScene!
    
    private let clearColor: MTLClearColor = MTLClearColorMake(0.2, 0.01, 0.01, 1)
    private var boxNode: SCNNode!
    private var sphereNode: SCNNode!
    private var time: Float
    
    init(device: MTLDevice) {
        renderer = SCNRenderer(device: device, options: nil)
        time = 0
    }
    
    deinit {
        //
    }
    
    func setupScene(_ width: Int, _ height: Int) {
        /// Scene
        let camera = SCNCamera();
        camera.zNear = 0;
        camera.zFar = 100;
        camera.fieldOfView = 60
        
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 0, 10)
        cameraNode.look(at: SCNVector3(0, 0, 0))
        
        view = SCNView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        view.allowsCameraControl = true
        view.antialiasingMode = .multisampling4X
        view.autoenablesDefaultLighting = true
        view.scene = scene
        view.showsStatistics = true
        view.isPlaying = true
        
        scene = SCNScene()
        scene.rootNode.addChildNode(cameraNode)
        
        let box = SCNBox(width: 2, height: 2, length: 1, chamferRadius: 0)
        box.materials.first?.diffuse.contents = UIColor.blue
        boxNode = SCNNode(geometry: box)
        boxNode.camera = camera
        scene.rootNode.addChildNode(boxNode)
        
        let sphere = SCNSphere(radius: 1)
        sphere.materials.first?.diffuse.contents = UIColor.yellow
        sphereNode = SCNNode(geometry: sphere)
        sphereNode.camera = camera
        scene.rootNode.addChildNode(sphereNode)
    }
    
    func draw(_ commandQueue: MTLCommandQueue, _ texture: MTLTexture) {
        boxNode.eulerAngles = SCNVector3(
            x: boxNode.eulerAngles.x + 0.01,
            y: boxNode.eulerAngles.y + 0.0033,
            z: 0
        )
        
        let x = cos(time) * 2.0
        let y = cos(time * 0.67) * 5.0
        sphereNode.position = SCNVector3Make(x, y, 0)
        renderSceneKit(commandQueue, texture, renderer, view, scene, clearColor)
        time += 30.0 / 1000.0
    }
    
}
