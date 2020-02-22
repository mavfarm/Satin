//
//  Buffer.swift
//  Satin
//
//  Created by Colin Duffy on 2/21/20.
//

import MetalKit

/**
 * Base class for storing storing buffers/sending them to uniforms
 */
open class Buffer {
    
    public var uniformBufferOffset: Int = 0
    public var uniformsBuffer: MTLBuffer!
    
    public var alignedUniformsSize: Int = 0
    public var uniformBufferIndex: Int = 0
    
    public init() {
        //
    }
    
    open func setup() {
        guard let device = MTLCreateSystemDefaultDevice() else { return }
        let uniformBufferSize = alignedUniformsSize * Satin.maxBuffersInFlight
        guard let buffer = device.makeBuffer(length: uniformBufferSize, options: [MTLResourceOptions.storageModeShared]) else { return }
        uniformsBuffer = buffer
//        uniformsBuffer.label = "Material Uniforms"
//        uniforms = UnsafeMutableRawPointer(uniformsBuffer.contents()).bindMemory(to: STRUCT_TYPE.self, capacity: 1)
    }
    
    public func update() {
        updateBuffer()
        updateUniforms()
    }
    
    /// Update Buffer
    open func updateBuffer() {
        self.uniformBufferIndex = (self.uniformBufferIndex + 1) % Satin.maxBuffersInFlight
        self.uniformBufferOffset = self.alignedUniformsSize * self.uniformBufferIndex
//        self.uniforms = UnsafeMutableRawPointer(self.uniformsBuffer.contents() + self.uniformBufferOffset).bindMemory(to: STRUCT_TYPE.self, capacity: 1)
    }
    
    /// Update Uniforms
    open func updateUniforms() {
        ///
    }
    
    public static func loadTexture(_ textureName: String) throws -> MTLTexture {
        let defaultDevice = MTLCreateSystemDefaultDevice()!
        let textureLoader = MTKTextureLoader(device: defaultDevice)
        
        let textureLoaderOptions = [
            MTKTextureLoader.Option.textureUsage: NSNumber(value: MTLTextureUsage.shaderRead.rawValue),
            MTKTextureLoader.Option.textureStorageMode: NSNumber(value: MTLStorageMode.`private`.rawValue)
        ]
        
        return try textureLoader.newTexture(name: textureName,
                                            scaleFactor: 1.0,
                                            bundle: nil,
                                            options: textureLoaderOptions)
        
    }
}
