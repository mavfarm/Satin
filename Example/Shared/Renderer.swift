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
import SceneKit
import simd

func toRad(_ number: Float) -> Float {
    return number * (.pi / 180)
}

extension simd_quatf {
    
    static let identity = simd_quaternion(0, simd_make_float3(0, 0, 0))
    
    static func fromRotation(_ xRot: Float, _ yRot: Float, _ zRot: Float) -> simd_quatf {
        let xQuat = simd_quaternion(toRad(xRot), simd_make_float3(1, 0, 0))
        let yQuat = simd_quaternion(toRad(yRot), simd_make_float3(0, 1, 0))
        let zQuat = simd_quaternion(toRad(zRot), simd_make_float3(0, 0, -1))
        return xQuat * yQuat * zQuat
    }
    
    static func rotateX(_ matrix: simd_quatf, _ rotation: Float) -> simd_quatf {
        return matrix * simd_quaternion(toRad(rotation), simd_make_float3(1, 0, 0))
    }
    
    static func rotateY(_ matrix: simd_quatf, _ rotation: Float) -> simd_quatf {
        return matrix * simd_quaternion(toRad(rotation), simd_make_float3(0, 1, 0))
    }
    
    static func rotateZ(_ matrix: simd_quatf, _ rotation: Float) -> simd_quatf {
        return matrix * simd_quaternion(toRad(rotation), simd_make_float3(0, 0, -1))
    }
    
}

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
    
    var sceneKit: SceneKitScene!
    
    var context: Context!
    var scene: Object!
    var camera = PerspectiveCamera()
    var mesh: Mesh!
    
    var texture: MTLTexture!
    
    // Post
    var post: PostProcessor!
    var blurPass: BlurPass!
    
    required init?(metalKitView: MTKView) {
        super.init(metalKitView: metalKitView)
    }
    
    override func setupMtkView(_ metalKitView: MTKView) {
        metalKitView.depthStencilPixelFormat = .depth32Float_stencil8
        metalKitView.sampleCount = 1
        
        let width = Int(UIScreen.main.bounds.width)
        let height = Int(UIScreen.main.bounds.height)
        self.texture = Pass.createRenderTarget(width: width, height: height, format: .bgra8Unorm_srgb)
        
        sceneKit = SceneKitScene(device: device)
        sceneKit.setupScene(width, height)
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
        camera.position.z = 800.0
        camera.near = 0.001
        camera.far = 10000.0
        camera.fov = 60
        
        scene = Object()
        scene.id = "Scene"
        
        /// Background
        let material = ImageMaterial()
        material.texture = texture
//        let material = NormalMaterial()
//        let material = UVMaterial()
        
        let geometry = BoxGeometry(
            size: (
                Float(UIScreen.main.bounds.width),
                Float(UIScreen.main.bounds.height),
                100
            )
        )
        mesh = Mesh(
            geometry: geometry,
            material: material
        )
        mesh.id = "Ball"
        mesh.cullMode = .none
        scene.add(mesh)
    }
    
    func setupPost() {
        post = PostProcessor()
        
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
        mesh.orientation = simd_quatf.rotateY(mesh.orientation, 1)
        post.update()
    }
    
    override func draw(_ view: MTKView, _ commandBuffer: MTLCommandBuffer) {
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        
        sceneKit.draw(commandQueue, texture)
        post.draw(view, renderPassDescriptor, commandBuffer)
    }
    
    override func resize(_ size: (width: Float, height: Float)) {
        let aspect = size.width / size.height
        camera.aspect = aspect
        post.resize(size)
    }
    
    public func touch(_ posX: Float, _ posY: Float) {
        blurPass.buffer.direction = simd_make_float2(
            lerp(value: posX, minimum: -10, maximum: 10),
            lerp(value: posY, minimum: -10, maximum: 10)
        )
    }
}
