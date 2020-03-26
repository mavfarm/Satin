//
//  RenderUtils.swift
//  Satin
//
//  Created by Colin Duffy on 3/25/20.
//

import Metal
import SceneKit

/**
 * Should work with both SceneKit and ARKit
 */
public func renderSceneKit(_ commandQueue: MTLCommandQueue,
                    _ texture: MTLTexture,
                    _ renderer: SCNRenderer,
                    _ view: SCNView,
                    _ scene: SCNScene,
                    _ clearColor: MTLClearColor) {
    let viewport = CGRect(x: 0, y: 0, width: CGFloat(texture.width), height: CGFloat(texture.height))
    
    // write to texture, clear the texture before rendering using clearColor, store the result
    let renderPassDescriptor = MTLRenderPassDescriptor()
    renderPassDescriptor.colorAttachments[0].clearColor = clearColor
    // Auto Clear
    renderPassDescriptor.colorAttachments[0].loadAction = .clear
    // Color Texture
    renderPassDescriptor.colorAttachments[0].texture = texture
    renderPassDescriptor.colorAttachments[0].storeAction = .store
    
    let commandBuffer = commandQueue.makeCommandBuffer()!

    renderer.scene = scene
    renderer.pointOfView = view.pointOfView
    renderer.autoenablesDefaultLighting = true
    renderer.render(withViewport: viewport, commandBuffer: commandBuffer, passDescriptor: renderPassDescriptor)
    
    commandBuffer.commit()
    commandBuffer.waitUntilCompleted()
}
