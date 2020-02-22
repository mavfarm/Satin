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
import simd

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
    var camera = PerspectiveCamera()
    
    // Post
    var post: PostProcessor!
    var blurPass: BlurPass!
    
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
        camera.position.z = 1000.0
        camera.near = 0.001
        camera.far = 10000.0
        
        scene = Object()
        scene.id = "Scene"
        
        /// Background
        let geometry = IcoSphereGeometry(radius: 400, res: 3)
        let mesh = Mesh(
            geometry: geometry,
            material: NormalMaterial()
        )
        mesh.id = "Ball"
        mesh.cullMode = .none
        mesh.triangleFillMode = .lines
        scene.add(mesh)
    }
    
    func setupPost() {
        post = PostProcessor()
//        post.enabled = false
        
        // Scene
        let scenePass = ScenePass(context, scene, camera)
        post.add(scenePass)
        
        // Blur pass
        let useBlurPass: Bool = true
        if useBlurPass {
            blurPass = BlurPass(context, nil, nil)
            blurPass.buffer.direction = simd_make_float2(2, 2)
            post.add(blurPass)
        }
        
        // Color pass
        let useColorPass: Bool = false
        if useColorPass {
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
                pass.renderToScreen = true
                post.add(pass)
            }
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
        let distance = camera.position.z
        let fov = 2.0 * atan( (size.width / aspect) / (2.0 * distance) ) * (180.0 / Float.pi)
        
        camera.aspect = aspect
        camera.fov = fov
        post.resize(size)
    }
    
    public func touch(_ posX: Float, _ posY: Float) {
        blurPass.buffer.direction = simd_make_float2(
            lerp(value: posX, minimum: -10, maximum: 10),
            lerp(value: posY, minimum: -10, maximum: 10)
        )
    }
}
