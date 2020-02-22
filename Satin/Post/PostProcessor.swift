//
//  PostProcessor.swift
//  Satin
//
//  Created by Colin Duffy on 2/20/20.
//  Copyright © 2020 Colin Duffy. All rights reserved.
//

import Metal
import MetalKit

open class PostProcessor {
    
    var passes: [Pass]
    var fbo: FBO
    var enabled: Bool = true
    
    /// Internal
    internal var width: Float
    internal var height: Float
    
    public init() {
        self.passes = []
        self.width = Float(UIScreen.main.bounds.width)
        self.height = Float(UIScreen.main.bounds.height)
        self.fbo = FBO(width: Int(width), height: Int(height), format: .bgra8Unorm_srgb)
    }
    
    open func add(_ pass: Pass) {
        passes.append(pass)
        pass.resize((width, height))
    }
    
    open func swapBuffers() {
        self.fbo.swapBuffers()
    }
    
    open func update() {
        for pass in passes {
            if pass.enabled {
                pass.update()
            }
        }
    }
    
    open func draw(_ view: MTKView, _ renderPassDescriptor: MTLRenderPassDescriptor, _ commandBuffer: MTLCommandBuffer) {
        let totalPasses = passes.count
        if !enabled && totalPasses > 0 {
            passes[0].draw(view, renderPassDescriptor, commandBuffer, self.fbo.readBuffer)
            return
        }
        
        var index: Int = 0
        let lastPass = totalPasses - 1
        for pass in passes {
            if pass.enabled {
                
                if pass.renderToScreen || index == lastPass {
                    pass.draw(view, renderPassDescriptor, commandBuffer, self.fbo.readBuffer)
                } else {
                    pass.draw(view, renderPassDescriptor, commandBuffer, self.fbo.readBuffer, self.fbo.writeBuffer)
                }
                
                if pass.needsSwap {
                    swapBuffers()
                }
            }
            index += 1
        }
    }
    
    open func resize(_ size: (width: Float, height: Float)) {
        self.width = size.width
        self.height = size.height
        
        self.fbo.resize(Int(width), Int(height))
        
        for pass in passes {
            pass.resize(size)
        }
    }
    
}