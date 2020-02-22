//
//  UVMaterial.swift
//  Satin
//
//  Created by Colin Duffy on 2/21/20.
//

import Metal

open class UVMaterial: Material {
    
    override public init() {
        super.init()
    }

    override open func setup() {
        setupPipeline()
    }

    func setupPipeline() {
        guard let context = self.context else { return }
        let metalFileCompiler = MetalFileCompiler()
        if let materialPath = getPipelinesPath("Materials/UVMaterial/Shaders.metal") {
            do {
                let source = try metalFileCompiler.parse(URL(fileURLWithPath: materialPath))
                // potentially think about creating a library for all of Satin's Materials
                let library = try context.device.makeLibrary(source: source, options: .none)
                pipeline = try makeAlphaRenderPipeline(
                    library: library,
                    vertex: "basicVertex",
                    fragment: "UVFragment",
                    label: "UVMaterial",
                    context: context)
            }
            catch {
                print(error)
            }
        }
    }
    
}
