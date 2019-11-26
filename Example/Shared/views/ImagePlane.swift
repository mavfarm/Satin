//
//  ImagePlane.swift
//  Example
//
//  Created by Colin Duffy on 10/23/19.
//  Copyright © 2019 Reza Ali. All rights reserved.
//

import Metal
import MetalKit
import Satin

class ImagePlane: Object {
    
    private var material: Material!
    private var geometry: Geometry!
    private var mesh: Mesh!
    private var texture: MTLTexture!
    private var sampler: MTLSamplerState!
    
    init(context:Context?) {
        super.init()
        self.context = context
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    func setup(library: MTLLibrary?, device: MTLDevice, textureName: String) {
        do {
            texture = try loadTexture(device: device, textureName: textureName)
        } catch {
            print("Couldnt load texture:", textureName)
        }
        
        let descriptor = MTLSamplerDescriptor()
        descriptor.minFilter = .nearest
        descriptor.magFilter = .nearest
        descriptor.mipFilter = .nearest
        descriptor.maxAnisotropy = 1
        descriptor.sAddressMode = .clampToEdge
        descriptor.tAddressMode = .clampToEdge
        descriptor.rAddressMode = .clampToEdge
        descriptor.normalizedCoordinates = true
        descriptor.lodMinClamp = 0
        descriptor.lodMaxClamp = .greatestFiniteMagnitude
        sampler = device.makeSamplerState(descriptor: descriptor)!
        
        material = Material(
            library: library,
            vertex: "basic_vertex",
            fragment: "texture_fragment",
            label: "image",
            context: context!,
            blending: .additive
        )
        
        material.onBind = { (_ renderEncoder: MTLRenderCommandEncoder) in
            renderEncoder.setFragmentSamplerState(self.sampler, index: 0)
            renderEncoder.setFragmentTexture(self.texture, index: 0)
        }
        
        let w = Float(1024)
        let h = Float(512)
        geometry = PlaneGeometry(size: (w, h))
        
        mesh = Mesh(geometry: geometry, material: material)
        deselectItem()
        
        add(mesh)
    }
    
    private func loadTexture(device: MTLDevice, textureName: String) throws -> MTLTexture {
        /// Load texture data with optimal parameters for sampling
        
        let textureLoader = MTKTextureLoader(device: device)
        
        let textureLoaderOptions = [
            MTKTextureLoader.Option.textureUsage: NSNumber(value: MTLTextureUsage.shaderRead.rawValue),
            MTKTextureLoader.Option.textureStorageMode: NSNumber(value: MTLStorageMode.`private`.rawValue)
        ]
        
        return try textureLoader.newTexture(name: textureName,
                                            scaleFactor: 1.0,
                                            bundle: nil,
                                            options: textureLoaderOptions)
        
    }
    
    public func selectItem() {
        let scale = Float(1.0)
        mesh.scale = simd_make_float3(scale, scale, scale)
    }
    
    public func deselectItem() {
        let scale = Float(0.5)
        mesh.scale = simd_make_float3(scale, scale, scale)
    }
    
}
