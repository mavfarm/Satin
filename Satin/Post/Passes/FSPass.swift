//
//  FSPass.swift
//  Satin
//
//  Created by Colin Duffy on 2/20/20.
//  Copyright © 2020 Colin Duffy. All rights reserved.
//

import MetalKit

open class FSPass: ScenePass {
    
    static let Geometry = PlaneGeometry(size: (1, 1))
        
    internal var mesh: Mesh?
    
    public var material: Material? {
        get {
            return mesh?.material
        }
        set(value) {
            mesh?.material = value
        }
    }
    
    override open func setup() {
        mesh = Mesh(
            geometry: FSPass.Geometry,
            material: nil
        )
        scene.add(mesh!)
        
        super.setup()
    }
    
    override open func draw(_ view: MTKView,
                            _ renderPassDescriptor: MTLRenderPassDescriptor,
                            _ commandBuffer: MTLCommandBuffer,
                            _ fbo: FBO) {
        // Set "uniforms"
        material?.onBind = { (_ renderEncoder: MTLRenderCommandEncoder) in
            renderEncoder.setFragmentTexture(fbo.readBuffer, index: 0)
        }
        
        if renderToScreen {
            renderer.draw(renderPassDescriptor: renderPassDescriptor, commandBuffer: commandBuffer)
        } else if needsUpdate {
            renderer.draw(renderPassDescriptor: renderPassDescriptor, commandBuffer: commandBuffer, renderTarget: fbo.writeBuffer)
        }
    }
    
}
