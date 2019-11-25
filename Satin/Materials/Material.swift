//
//  Material.swift
//  Satin
//
//  Created by Reza Ali on 7/24/19.
//  Copyright © 2019 Reza Ali. All rights reserved.
//

import Metal

protocol MaterialDelegate: AnyObject {
    func materialUpdated()
}

public enum MaterialBlending {
    case normal
    case alpha
    case additive
}

open class Material {
    weak var delegate: MaterialDelegate?
    open var pipeline: MTLRenderPipelineState?
    public var context: SatinContext? {
        didSet {
            setup()
        }
    }
    
    public var onBind: ((_ renderEncoder: MTLRenderCommandEncoder) -> ())?
    public var onUpdate: (() -> ())?
    
    public init() {}
    
    public init(library: MTLLibrary?,
                vertex: String,
                fragment: String,
                label: String,
                context: SatinContext,
                blending: MaterialBlending = .normal) {
        do {
            switch blending {
            case .normal:
                pipeline = try makeRenderPipeline(library: library, vertex: vertex, fragment: fragment, label: label, context: context)
                break;
            case .alpha:
                pipeline = try makeAlphaRenderPipeline(library: library, vertex: vertex, fragment: fragment, label: label, context: context)
                break;
            case .additive:
                pipeline = try makeAdditiveRenderPipeline(library: library, vertex: vertex, fragment: fragment, label: label, context: context)
                break;
            }
        }
        catch {
            print(error)
        }
        self.context = context
    }
    
    public init(pipeline: MTLRenderPipelineState) {
        self.pipeline = pipeline
    }
    
    open func setup() {}
    
    open func update() {
        onUpdate?()
    }
    
    open func bind(_ renderEncoder: MTLRenderCommandEncoder) {
        onBind?(renderEncoder)
    }
    
    deinit {}
}
