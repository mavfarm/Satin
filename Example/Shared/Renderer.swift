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

class Renderer: Forge.Renderer {
    var paramTest: IntParameter!
    var library: MTLLibrary!
    var material: Material!
    var geometry: Geometry!
    var mesh: Mesh!
    var scene: Object!
    var context: Context!
    
    var perspCamera = PerspectiveCamera()
    #if os(macOS)
    var cameraController: GesturalCameraController!
    #endif
    var renderer: Satin.Renderer!
    
    required init?(metalKitView: MTKView) {
        super.init(metalKitView: metalKitView)
    }
    
    override func setupMtkView(_ metalKitView: MTKView) {
        metalKitView.depthStencilPixelFormat = .depth32Float_stencil8
        metalKitView.sampleCount = 4
    }
    
    override func setup() {
        setupContext()
        setupLibrary()
        setupMaterial()
        setupGeometry()
        setupMesh()
        setupScene()
        setupCamera()
        setupRenderer()
    }
    
    func setupContext() {
        context = Context(device, sampleCount, colorPixelFormat, depthPixelFormat, stencilPixelFormat)
    }
    
    func setupLibrary() {
        library = device.makeDefaultLibrary()
    }
    
    func setupMaterial() {
        print(sampleCount)
        
        material = Material(
            library: library,
            vertex: "basic_vertex",
            fragment: "basic_fragment",
            label: "basic",
            context: context
        )
    }
    
    func setupGeometry() {
        geometry = BoxGeometry(size: 2)
    }
    
    func setupMesh() {
        mesh = Mesh(geometry: geometry, material: material)
    }
    
    func setupScene() {
        scene = Object()
        scene.add(mesh)
    }
    
    func setupCamera() {
        perspCamera.position = simd_make_float3(0.0, 0.0, 9.0)
        perspCamera.far = 100.0
        #if os(macOS)
        cameraController = GesturalCameraController(perspCamera)
        #endif
    }
    
    func setupRenderer() {
        renderer = Satin.Renderer(context: context,
                                  scene: scene,
                                  camera: perspCamera)
    }
    
    override func update() {
        #if os(macOS)
        cameraController.update()
        #endif
        renderer.update()
    }
    
    override func draw(_ view: MTKView, _ commandBuffer: MTLCommandBuffer) {
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        renderer.draw(renderPassDescriptor: renderPassDescriptor, commandBuffer: commandBuffer)
    }
    
    override func resize(_ size: (width: Float, height: Float)) {
        perspCamera.aspect = size.width / size.height
        renderer.resize(size)
    }
}
