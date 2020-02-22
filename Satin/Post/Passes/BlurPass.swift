//
//  BlurPass.swift
//  Satin
//
//  Created by Colin Duffy on 2/21/20.
//

import MetalKit
import simd

// MARK: - BlurPass

open class BlurPass: FSPass {
    
    public var buffer: BlurBuffer!
    
    override open func setup() {
        super.setup()
        
        let metalFileCompiler = MetalFileCompiler()
        if let materialPath = getPipelinesPath("Passes/BlurPass/Shaders.metal") {
            do {
                let source = try metalFileCompiler.parse(URL(fileURLWithPath: materialPath))
                // potentially think about creating a library for all of Satin's Materials
                let library = try context.device.makeLibrary(source: source, options: .none)
                if let pipeline = try makeRenderPipeline(
                    library: library,
                    vertex: "basicVertex",
                    fragment: "BlurPass_fragment",
                    label: "BlurMaterial",
                    context: context) {
                    self.material = Material(pipeline: pipeline)
                    self.buffer = BlurBuffer()
                    self.buffer.setup()
                }
            }
            catch {
                print(error)
            }
        }
    }
    
    override open func draw(_ view: MTKView,
                            _ renderPassDescriptor: MTLRenderPassDescriptor,
                            _ commandBuffer: MTLCommandBuffer,
                            _ fbo: FBO) {
        let initialDirection = self.buffer.direction
        
        self.buffer.flip = true
        
        let iterations: Int = 8
        for i in 0...iterations - 1 {
            let radius = Float(iterations - i)
            let direction = i % 2 == 0 ? simd_make_float2(radius, 0) : simd_make_float2(0, radius)
            self.buffer.direction = direction * initialDirection
            self.buffer.update()
            material?.onBind = { (_ renderEncoder: MTLRenderCommandEncoder) in
                renderEncoder.setFragmentTexture(fbo.readBuffer, index: 0)
                renderEncoder.setFragmentBuffer(self.buffer.uniformsBuffer, offset: self.buffer.uniformBufferOffset, index: 0)
            }
            renderer.draw(renderPassDescriptor: renderPassDescriptor, commandBuffer: commandBuffer, renderTarget: fbo.writeBuffer)
            fbo.swapBuffers()
        }
        
        /// - Final pass
        self.buffer.direction = simd_make_float2(0, 0)
        self.buffer.update()
        material?.onBind = { (_ renderEncoder: MTLRenderCommandEncoder) in
            renderEncoder.setFragmentTexture(fbo.readBuffer, index: 0)
            renderEncoder.setFragmentBuffer(self.buffer.uniformsBuffer, offset: self.buffer.uniformBufferOffset, index: 0)
        }
        
        if renderToScreen {
            renderer.draw(renderPassDescriptor: renderPassDescriptor, commandBuffer: commandBuffer)
        } else if needsUpdate {
            renderer.draw(renderPassDescriptor: renderPassDescriptor, commandBuffer: commandBuffer, renderTarget: fbo.writeBuffer)
        }
        
        self.buffer.direction = initialDirection
    }
    
    override open func resize(_ size: (width: Float, height: Float)) {
        self.buffer.resolution = simd_make_float2(size.width, size.height)
        super.resize(size)
    }
    
}
