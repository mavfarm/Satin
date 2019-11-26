//
//  Renderer.swift
//  Example Shared
//
//  Created by Reza Ali on 8/22/19.
//  Copyright © 2019 Reza Ali. All rights reserved.
//

import Metal
import MetalKit

import Forge
import Satin

struct CameraSettings {
    static let dampening: Float = 0.04
    static let downSpeed: Float = 0.2
    static let upSpeed: Float = 0.2
    
    static let maxRotationX: Float = 9.0 * (Float.pi / 180.0) /// in radians
    static let maxRotationY: Float = 9.0 * (Float.pi / 180.0) /// in radians
    static let distanceX: Float = 100.0
    static let distanceY: Float = 100.0
    
    static let buttonPadding: Float = 0.67
    static let rotationLeft: Float = -CameraSettings.maxRotationX * CameraSettings.buttonPadding
    static let rotationRight: Float = CameraSettings.maxRotationX * CameraSettings.buttonPadding
    static let rotationTop: Float = CameraSettings.maxRotationY * CameraSettings.buttonPadding
    static let rotationBottom: Float = -CameraSettings.maxRotationY * CameraSettings.buttonPadding
}

class Renderer: Forge.Renderer {
    var scene: Object!
    var context: Context!
    
    public static var device: MTLDevice!
    
    var perspCamera = PerspectiveCamera()
    #if os(macOS)
    var cameraController: GesturalCameraController!
    #endif
    var renderer: Satin.Renderer!
    
    /// Scene
    var background: Background!
    var menu: Menu!
    var lights: LightManager!
    
    /// Time
    private var startTime: Double = 0
    private var elapsedTime: Double = 0
    
    required init?(metalKitView: MTKView) {
        super.init(metalKitView: metalKitView)
    }
    
    override func setupMtkView(_ metalKitView: MTKView) {
        metalKitView.depthStencilPixelFormat = .depth32Float_stencil8
        metalKitView.sampleCount = 4
        Renderer.device = metalKitView.device!
    }
    
    override func setup() {
        setupContext()
        setupLighting()
        setupScene()
        setupCamera()
        setupRenderer()
    }
    
    func setupContext() {
        context = Context(device, sampleCount, colorPixelFormat, depthPixelFormat, stencilPixelFormat)
    }
    
    func setupLighting() {
        lights = LightManager()
        
//        lights.addPointLight(light: PointLight(
//            position: simd_make_float3(0, 0, -185),
//            color: simd_make_float3(1),
//            distance: 1000,
//            decay: 1,
//            shadow: 0,
//            shadowBias: 0,
//            shadowRadius: 1,
//            shadowMapSize: simd_make_float2(0),
//            shadowCameraNear: 1,
//            shadowCameraFar: 1000
//        ))
        
//        lights.addPointLight(PointLight(
//            shadow: 0,
//            shadowBias: 0,
//            shadowRadius: 1,
//            distance: 1000,
//            decay: 1,
//            shadowCameraNear: 1,
//            shadowCameraFar: 1000,
//            shadowMapSize: simd_make_float2(0),
//            position: simd_make_float3(0, 0, -185),
//            color: simd_make_float3(1)
//        ))
    }
    
    func setupScene() {
        scene = Object()
        
        /// Background
        background = Background(context: context)
        background.setup()
        background.material.lights = lights
        scene.add(background)
        
//        menu = Menu(context: context)
//        menu.setup(library: library, device: device)
//        scene.add(menu)
    }
    
    func setupCamera() {
//        perspCamera.position.z = 185.0
        perspCamera.position.z = 1000.0
        perspCamera.near = 0.001
        perspCamera.far = 10000.0
        
        #if os(macOS)
        cameraController = GesturalCameraController(perspCamera)
        #endif
    }
    
    func setupRenderer() {
        renderer = Satin.Renderer(context: context,
                                  scene: scene,
                                  camera: perspCamera)
        
        startTime = Double( Date().currentTimeMillis() )
    }
    
    override func update() {
        #if os(macOS)
        cameraController.update()
        #endif
        
        let now = Double( Date().currentTimeMillis() )
        elapsedTime = (now - startTime) / 1000.0
        
        /// Update variables
        background.elapsedTime = elapsedTime
        
        lights.update()
        scene.update()
        
        renderer.update()
    }
    
    override func draw(_ view: MTKView, _ commandBuffer: MTLCommandBuffer) {
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        renderer.draw(renderPassDescriptor: renderPassDescriptor, commandBuffer: commandBuffer)
        
    }
    
    override func resize(_ size: (width: Float, height: Float)) {
        let aspect = size.width / size.height
        
        /// Auto-set the FOV
        let distance = perspCamera.position.z
        let fov = 2.0 * atan( (size.width / aspect) / (2.0 * distance) ) * (180.0 / Float.pi)
        
        perspCamera.aspect = aspect
        perspCamera.fov = fov
        renderer.resize(size)
    }
    
    public func setCameraRotation(x:Float, y:Float) {
        perspCamera.orientation = simd_quaternion(x - Float.pi, simd_make_float3(0, 1, 0))
        perspCamera.orientation *= simd_quaternion(y, simd_make_float3(1, 0, 0))
    }
    
    public func resetCamera() {
        perspCamera.orientation = simd_quaternion(-Float.pi, simd_make_float3(0, 1, 0))
    }
}
