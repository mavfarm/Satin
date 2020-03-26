//
//  ImageMaterial.swift
//  Satin
//
//  Created by Colin Duffy on 3/25/20.
//

import Metal

open class ImageMaterial: Material {
    
    public var texture: MTLTexture?
    
    override public init() {
        super.init()
    }

    override open func setup() {
        setupPipeline()
    }

    func setupPipeline() {
        guard let context = self.context else { return }
        let metalFileCompiler = MetalFileCompiler()
        if let materialPath = getPipelinesPath("Materials/ImageMaterial/Shaders.metal") {
            do {
                let source = try metalFileCompiler.parse(URL(fileURLWithPath: materialPath))
                // potentially think about creating a library for all of Satin's Materials
                let library = try context.device.makeLibrary(source: source, options: .none)
                pipeline = try makeAlphaRenderPipeline(
                    library: library,
                    vertex: "basicVertex",
                    fragment: "ImageFragment",
                    label: "ImageMaterial",
                    context: context)
            }
            catch {
                print(error)
            }
        }
    }
    
    override open func bind(_ renderEncoder: MTLRenderCommandEncoder) {
        renderEncoder.setFragmentTexture(self.texture, index: 0)
        super.bind(renderEncoder)
    }
    
}
