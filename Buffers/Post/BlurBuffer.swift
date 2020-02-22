//
//  BlurBuffer.swift
//  Satin
//
//  Created by Colin Duffy on 2/21/20.
//

import simd

struct BlurUniforms {
    var direction: simd_float2
    var resolution: simd_float2
    var flip: Bool
}

// MARK: - BlurBuffer

open class BlurBuffer: Buffer {
    
    public var direction: simd_float2
    public var resolution: simd_float2
    public var flip: Bool
    
    var uniforms: UnsafeMutablePointer<BlurUniforms>!
    
    override public init() {
        self.direction = simd_make_float2(1.0, 1.0)
        let screen = UIScreen.main.bounds
        self.resolution = simd_make_float2(Float(screen.width), Float(screen.height))
        self.flip = true
        
        super.init()
        
        self.alignedUniformsSize = ((MemoryLayout<BlurBuffer>.size + 255) / 256) * 256
    }
    
    override open func setup() {
        super.setup()
        uniformsBuffer.label = "Blur Uniforms"
        uniforms = UnsafeMutableRawPointer(uniformsBuffer.contents()).bindMemory(to: BlurUniforms.self, capacity: 1)
    }
    
    override open func updateBuffer() {
        super.updateBuffer()
        self.uniforms = UnsafeMutableRawPointer(self.uniformsBuffer.contents() + self.uniformBufferOffset).bindMemory(to: BlurUniforms.self, capacity: 1)
    }
    
    override open func updateUniforms() {
        self.uniforms[0].direction = direction
        self.uniforms[0].resolution = resolution
        self.uniforms[0].flip = flip
    }
    
}
