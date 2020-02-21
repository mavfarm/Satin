//
//  RenderPass.swift
//  Satin
//
//  Created by Colin Duffy on 2/20/20.
//  Copyright © 2020 Colin Duffy. All rights reserved.
//

import Metal
import MetalKit

class RenderPass: Pass {
    
    var renderer: Satin.Renderer!
    var camera: Camera
    var scene: Object
    
    internal var context: Context
    internal var needsUpdate: Bool = true
    
    init(_ context: Context, _ importScene: Object?, _ importCamera: Camera?) {
        self.context = context
        self.camera = OrthographicCamera(left: -0.5, right: 0.5, bottom: -0.5, top: 0.5, near: 0, far: 1)
        self.scene = Object()
        
        if importScene != nil {
            self.scene = importScene!
        }
        
        if importCamera != nil {
            self.camera = importCamera!
        }
        
        super.init()
    }
    
    override open func setup() {
        renderer = Satin.Renderer(context: context, scene: scene, camera: camera)
    }
    
    override open func update() {
        if needsUpdate {
            renderer.update()
        }
    }
    
    override open func draw(_ view: MTKView,
                            _ renderPassDescriptor: MTLRenderPassDescriptor,
                            _ commandBuffer: MTLCommandBuffer,
                            _ readTarget: MTLTexture) {
        // > Ensure to bind the readTarget to your material before rendering
        renderer.draw(renderPassDescriptor: renderPassDescriptor, commandBuffer: commandBuffer)
    }
    
    override open func draw(_ view: MTKView,
                            _ renderPassDescriptor: MTLRenderPassDescriptor,
                            _ commandBuffer: MTLCommandBuffer,
                            _ readTarget: MTLTexture,
                            _ writeTarget: MTLTexture) {
        if !needsUpdate {
            return
        }
        // > Ensure to bind the readTarget to your material before rendering
        renderer.draw(renderPassDescriptor: renderPassDescriptor, commandBuffer: commandBuffer, renderTarget: writeTarget)
    }
    
    override open func resize(_ size: (width: Float, height: Float)) {
        renderer.resize(size)
        needsUpdate = true
    }
    
}
