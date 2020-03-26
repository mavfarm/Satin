//
//  Pass.swift
//  Satin
//
//  Created by Colin Duffy on 2/20/20.
//  Copyright © 2020 Colin Duffy. All rights reserved.
//

import Metal
import MetalKit

open class Pass {
    
    public var enabled: Bool = true
    public var needsSwap: Bool = true
    public var clear: Bool = false
    public var renderToScreen: Bool = false
    
    public init() {
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
                            _ fbo: FBO) {
    }
    
    open func resize(_ size: (width: Float, height: Float)) {
        ///
    }
    
    static public func createRenderTarget(width: Int, height: Int, format: MTLPixelFormat) -> MTLTexture {
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
