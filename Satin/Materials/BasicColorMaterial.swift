//
//  BasicColorMaterial.swift
//  Satin
//
//  Created by Reza Ali on 9/25/19.
//  Copyright © 2019 Reza Ali. All rights reserved.
//

import Foundation

import Metal
import simd

struct BasicColorMaterialUniforms {
    var color: simd_float4
}

open class BasicColorMaterial: Material {
    public var color: simd_float4 = simd_make_float4(1.0, 1.0, 1.0, 1.0)
    let alignedUniformsSize = ((MemoryLayout<BasicColorMaterialUniforms>.size + 255) / 256) * 256

    var uniformBufferIndex: Int = 0
    var uniformBufferOffset: Int = 0
    var uniforms: UnsafeMutablePointer<BasicColorMaterialUniforms>!
    var uniformsBuffer: MTLBuffer!

    public init(_ color: simd_float4) {
        super.init()
        self.color = color
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

    func setupPipeline() {
        guard let context = self.context else { return }
        let metalFileCompiler = MetalFileCompiler()
        if let materialPath = getPipelinesPath("Materials/BasicColorMaterial/Shaders.metal") {
            do {
                let source = try metalFileCompiler.parse(URL(fileURLWithPath: materialPath))
                // potentially think about creating a library for all of Satin's Materials
                let library = try context.device.makeLibrary(source: source, options: .none)
                pipeline = try makeAlphaRenderPipeline(
                    library: library,
                    vertex: "basicColorVertex",
                    fragment: "basicColorFragment",
                    label: "basicColorMaterial",
                    context: context)
            }
            catch {
                print(error)
            }
        }
    }

    func setupUniformsBuffer() {
        guard let context = self.context else { return }
        let device = context.device
        let uniformBufferSize = alignedUniformsSize * Satin.maxBuffersInFlight
        guard let buffer = device.makeBuffer(length: uniformBufferSize, options: [MTLResourceOptions.storageModeShared]) else { return }
        uniformsBuffer = buffer
        uniformsBuffer.label = "Basic Color Material Uniforms"
        uniforms = UnsafeMutableRawPointer(uniformsBuffer.contents()).bindMemory(to: BasicColorMaterialUniforms.self, capacity: 1)
    }

    func updateUniforms() {
        if uniforms != nil {
            uniforms[0].color = color
        }
    }

    func updateUniformsBuffer() {
        if uniformsBuffer != nil {
            uniformBufferIndex = (uniformBufferIndex + 1) % maxBuffersInFlight
            uniformBufferOffset = alignedUniformsSize * uniformBufferIndex
            uniforms = UnsafeMutableRawPointer(uniformsBuffer.contents() + uniformBufferOffset).bindMemory(to: BasicColorMaterialUniforms.self, capacity: 1)
        }
    }

    open override func bind(_ renderEncoder: MTLRenderCommandEncoder) {
        renderEncoder.setFragmentBuffer(uniformsBuffer, offset: uniformBufferOffset, index: 0)
        super.bind(renderEncoder)
    }
}
