//
//  PhongMaterial.swift
//  Example iOS
//
//  Created by Colin Duffy on 11/21/19.
//  Copyright © 2019 Reza Ali. All rights reserved.
//

import Satin
import Metal
import simd

struct PhongMaterialUniforms {
    var diffuse: simd_float3
    var emissive: simd_float3
    var specular: simd_float3
    var shininess: Float
    var opacity: Float
}

public class PhongMaterial: Material {
    
    weak var lights: LightManager?
    
    public var diffuse: simd_float3 = simd_make_float3(1.0)
    public var emissive: simd_float3 = simd_make_float3(0.0)
    public var specular: simd_float3 = simd_make_float3(1.0)
    public var shininess: Float = 30.0
    public var opacity: Float = 1.0
    
    /// Uniforms
    let alignedUniformsSize = ((MemoryLayout<PhongMaterialUniforms>.size + 255) / 256) * 256
    var uniformBufferIndex: Int = 0
    var uniformBufferOffset: Int = 0
    var uniforms: UnsafeMutablePointer<PhongMaterialUniforms>!
    var uniformsBuffer: MTLBuffer!
    
    public init(_ diffuse: simd_float3, _ emissive: simd_float3, _ specular: simd_float3, _ shininess: Float, _ opacity: Float) {
        super.init()
        
        self.diffuse = diffuse
        self.emissive = emissive
        self.specular = specular
        self.shininess = shininess
        self.opacity = opacity
    }
    
    override open func setup() {
        setupPipeline()
        setupUniformsBuffer()
    }
    
    override open func update() {
        updateUniformsBuffer()
        updateUniforms()
        super.update()
    }
    
    func getMaterialPath(_ name:String) -> String? {
        if let resourcePath = Bundle(for: PhongMaterial.self).resourcePath {
            return resourcePath + "/MetalShaders/materials/" + name + ".metal"
        }
        return nil
    }
    
    func setupPipeline() {
        let metalFileCompiler = MetalFileCompiler()
        
        if let materialPath = getMaterialPath("phong/Shaders") {
            do {
                let source = try metalFileCompiler.parse(URL(fileURLWithPath: materialPath))
                // potentially think about creating a library for all of Satin's Materials
                let library = try Renderer.device.makeLibrary(source: source, options: .none)
                pipeline = try makeAlphaRenderPipeline(
                    library: library,
                    vertex: "phongVertex",
                    fragment: "phongFragment",
                    label: "phongMaterial",
                    context: self.context!)
            }
            catch {
                print(error)
            }
        }
    }

    func setupUniformsBuffer() {
        let uniformBufferSize = alignedUniformsSize * Satin.maxBuffersInFlight
        guard let buffer = Renderer.device.makeBuffer(length: uniformBufferSize, options: [MTLResourceOptions.storageModeShared]) else { return }
        uniformsBuffer = buffer
        uniformsBuffer.label = "Phong Material Uniforms"
        uniforms = UnsafeMutableRawPointer(uniformsBuffer.contents()).bindMemory(to: PhongMaterialUniforms.self, capacity: 1)
    }

    func updateUniforms() {
        if uniforms != nil {
            uniforms[0].diffuse = diffuse
            uniforms[0].emissive = emissive
            uniforms[0].specular = specular
            uniforms[0].shininess = shininess
            uniforms[0].opacity = opacity
        }
    }

    func updateUniformsBuffer() {
        if uniformsBuffer != nil {
            uniformBufferIndex = (uniformBufferIndex + 1) % maxBuffersInFlight
            uniformBufferOffset = alignedUniformsSize * uniformBufferIndex
            uniforms = UnsafeMutableRawPointer(uniformsBuffer.contents() + uniformBufferOffset).bindMemory(to: PhongMaterialUniforms.self, capacity: 1)
        }
    }

    open override func bind(_ renderEncoder: MTLRenderCommandEncoder) {
        renderEncoder.setFragmentBuffer(uniformsBuffer, offset: uniformBufferOffset, index: 0)
        if let lights = lights {
            renderEncoder.setFragmentBuffer(lights.buffer, offset: lights.offset, index: 1)
        }
        super.bind(renderEncoder)
    }
}
