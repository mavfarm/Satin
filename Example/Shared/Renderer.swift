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

public func getMetal(_ path: String) -> URL? {
    return Bundle.main.url(forResource: path, withExtension: "metal")
}

public func compileShader(
    _ context: Satin.Context?,
    _ shader: String,
    _ vertex: String,
    _ fragment: String,
    _ label: String) -> MTLRenderPipelineState? {
    let device = MTLCreateSystemDefaultDevice()!
    let metalFileCompiler = MetalFileCompiler()
    let materialPath = getMetal(shader)
    
    do {
        let source = try metalFileCompiler.parse(materialPath!)
        
        // potentially think about creating a library for all of Satin's Materials
        let library = try device.makeLibrary(source: source, options: .none)
        
        return try makeRenderPipeline(
            library: library,
            vertex: vertex,
            fragment: fragment,
            label: label,
            context: context!
        )
        
    } catch {
        print("\n\nCAN'T LOAD SHADER!!!", shader)
        print(error)
    }
    
    return nil
}

class Renderer: Forge.Renderer {
    
    var context: Context!
    var scene: Object!
    var perspCamera = PerspectiveCamera()
    
    /// Scene
    var background: Background!
    
    // Post
    var post: PostProcessor!
    
    required init?(metalKitView: MTKView) {
        super.init(metalKitView: metalKitView)
    }
    
    override func setupMtkView(_ metalKitView: MTKView) {
        metalKitView.depthStencilPixelFormat = .depth32Float_stencil8
        metalKitView.sampleCount = 4
    }
    
    override func setup() {
        setupContext()
        setupScene()
        setupPost()
    }
    
    func setupContext() {
        context = Context(device, sampleCount, colorPixelFormat, depthPixelFormat, stencilPixelFormat)
    }
    
    func setupScene() {
        scene = Object()
        scene.id = "Scene"
        
        /// Background
        background = Background()
        scene.add(background)
        
        perspCamera.position.z = 1000.0
        perspCamera.near = 0.001
        perspCamera.far = 10000.0
    }
    
    func setupPost() {
        post = PostProcessor()
//        post.enabled = false
        
        // Scene
        let scenePass = RenderPass(context, scene, perspCamera)
        post.add(scenePass)
        
        // Color pass
        if let colorPipeline = compileShader(
            self.context!,
            "MetalShaders/materials/ColorPass",
            "ColorPass_vertex",
            "ColorPass_fragment",
            "Color Material"
            ) {
            let material = Material(pipeline: colorPipeline)
            let pass = FSPass(context, nil, nil)
            pass.material = material
            post.add(pass)
        }
        
        // Blur pass
        if let blurPipeline = compileShader(
            self.context!,
            "MetalShaders/materials/BlurPass",
            "BlurPass_vertex",
            "BlurPass_fragment",
            "Blur Material"
            ) {
            let material = Material(pipeline: blurPipeline)
            let pass = FSPass(context, nil, nil)
            pass.material = material
            post.add(pass)
        }
    }
    
    override func update() {
        post.update()
    }
    
    override func draw(_ view: MTKView, _ commandBuffer: MTLCommandBuffer) {
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        post.draw(view, renderPassDescriptor, commandBuffer)
    }
    
    override func resize(_ size: (width: Float, height: Float)) {
        let aspect = size.width / size.height
        
        /// Auto-set the FOV
        let distance = perspCamera.position.z
        let fov = 2.0 * atan( (size.width / aspect) / (2.0 * distance) ) * (180.0 / Float.pi)
        
        perspCamera.aspect = aspect
        perspCamera.fov = fov
        post.resize(size)
    }
}
