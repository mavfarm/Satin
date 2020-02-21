//
//  FSPass.swift
//  Satin
//
//  Created by Colin Duffy on 2/20/20.
//  Copyright © 2020 Colin Duffy. All rights reserved.
//

import MetalKit

open class FSPass: RenderPass {
    
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
                            _ readTarget: MTLTexture) {
        // > Ensure to bind the readTarget to your material before rendering
        setTexture(readTarget)
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
        setTexture(readTarget)
        renderer.draw(renderPassDescriptor: renderPassDescriptor, commandBuffer: commandBuffer, renderTarget: writeTarget)
    }
    
    /**
     * Sets the texture to read from
     */
    open func setTexture(_ texture: MTLTexture) {
        material?.onBind = { (_ renderEncoder: MTLRenderCommandEncoder) in
            renderEncoder.setFragmentTexture(texture, index: 0)
        }
    }
    
}
