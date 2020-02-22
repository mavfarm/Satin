//
//  NormalMaterial.swift
//  Satin
//
//  Created by Colin Duffy on 2/21/20.
//

import Metal

open class NormalMaterial: Material {
    
    override public init() {
        super.init()
    }

    override open func setup() {
        setupPipeline()
    }

    func setupPipeline() {
        guard let context = self.context else { return }
        let metalFileCompiler = MetalFileCompiler()
        if let materialPath = getPipelinesPath("Materials/NormalMaterial/Shaders.metal") {
            do {
                let source = try metalFileCompiler.parse(URL(fileURLWithPath: materialPath))
                // potentially think about creating a library for all of Satin's Materials
                let library = try context.device.makeLibrary(source: source, options: .none)
                pipeline = try makeAlphaRenderPipeline(
                    library: library,
                    vertex: "basicVertex",
                    fragment: "NormalFragment",
                    label: "NormalMaterial",
                    context: context)
            }
            catch {
                print(error)
            }
        }
    }
    
}
