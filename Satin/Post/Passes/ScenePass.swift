//
//  ScenePass.swift
//  Satin
//
//  Created by Colin Duffy on 2/20/20.
//  Copyright © 2020 Colin Duffy. All rights reserved.
//

import Metal
import MetalKit

open class ScenePass: Pass {
    
    public var renderer: Satin.Renderer!
    public var camera: Camera
    public var scene: Object
    public var context: Context
    public var needsUpdate: Bool = true
    
    public init(_ context: Context, _ importScene: Object?, _ importCamera: Camera?) {
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
                            _ fbo: FBO) {
        if renderToScreen {
            renderer.draw(renderPassDescriptor: renderPassDescriptor, commandBuffer: commandBuffer)
        } else if needsUpdate {
            renderer.draw(renderPassDescriptor: renderPassDescriptor, commandBuffer: commandBuffer, renderTarget: fbo.writeBuffer)
        }
    }
    
    override open func resize(_ size: (width: Float, height: Float)) {
        renderer.resize(size)
        needsUpdate = true
    }
    
}
