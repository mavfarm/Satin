//
//  Pass.swift
//  Satin-iOS
//
//  Created by Colin Duffy on 2/20/20.
//

import Metal
import MetalKit

class Pass {
    
    var enabled: Bool = true
    var needsSwap: Bool = true
    var clear: Bool = false
    var renderToScreen: Bool = false
    
    init() {
        setup()
    }
    
    open func setup() {
        ///
    }
    
    open func update() {
        ///
    }
    
    open func draw(_ view: MTKView,
                            _ renderPassDescriptor: MTLRenderPassDescriptor,
                            _ commandBuffer: MTLCommandBuffer,
                            _ readTarget: MTLTexture) {
    }
    
    open func draw(_ view: MTKView,
                            _ renderPassDescriptor: MTLRenderPassDescriptor,
                            _ commandBuffer: MTLCommandBuffer,
                            _ readTarget: MTLTexture,
                            _ writeTarget: MTLTexture) {
    }
    
    open func resize(_ size: (width: Float, height: Float)) {
        ///
    }
    
    static func createRenderTarget(width: Int, height: Int, format: MTLPixelFormat) -> MTLTexture {
        let texDesc = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: format,
            width: width,
            height: height,
            mipmapped: false
        )
        texDesc.usage = [.renderTarget, .shaderRead]
        
        let device = MTLCreateSystemDefaultDevice()!
        let texture = device.makeTexture(descriptor: texDesc)!
        return texture
    }
    
}
