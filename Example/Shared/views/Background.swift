//
//  Background.swift
//  Example
//
//  Created by Colin Duffy on 10/23/19.
//  Copyright © 2019 Reza Ali. All rights reserved.
//

import Metal
import MetalKit
import Satin
import simd

class Background: Object {
    
    public var elapsedTime: Double = 0
    public var displacement: Float = 0
    
//    public var material: Material!
    public var material: PhongMaterial!
    private var geometry: Geometry!
    private var mesh: Mesh!
    
    private var texture: MTLTexture!
    private var sampler:MTLSamplerState!
    
    init(context:Context?) {
        super.init()
        self.context = context
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    public func setup() {
        print("Background setup", self.id)
        
        let device = Renderer.device
        
        let textureLoader = MTKTextureLoader(device: device!)
        
        let textureLoaderOptions = [
            MTKTextureLoader.Option.textureUsage: NSNumber(value: MTLTextureUsage.shaderRead.rawValue),
            MTKTextureLoader.Option.textureStorageMode: NSNumber(value: MTLStorageMode.`private`.rawValue)
        ]
        
        do {
            texture = try textureLoader.newTexture(name: "ColorMap", scaleFactor: 1.0, bundle: nil, options: textureLoaderOptions)
        } catch {
            fatalError("Couldnt load image")
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
        sampler = device!.makeSamplerState(descriptor: descriptor)!
        
        material = PhongMaterial(
            simd_make_float3(1.0, 0.0, 0.0),
            simd_make_float3(0.0, 1.0, 0.0),
            simd_make_float3(0.0, 0.0, 1.0),
            30,
            1
        )
        
        //
//        material.onBind = { (_ renderEncoder: MTLRenderCommandEncoder) in
//            renderEncoder.setFragmentBuffer(lights.buffer, offset: lights.offset, index: 1)
//        }
        
//        geometry = OBJLoader(path: "background")
//        geometry = OBJLoader(path: "objects")
        geometry = IcoSphereGeometry(radius: 400, res: 2)
//        geometry = BoxGeometry(size: 100)
//        MTLPrimitiveType.triangle
//        geometry.primitiveType = .triangle
        
//        print(geometry.vertexData)
        
//        geometry = CylinderGeometry(
//            size: (100, 300),
//            res: (60, 3, 3)
//        )
        
        mesh = Mesh(geometry: geometry, material: material)
        mesh.depthWriteEnabled = false
//        mesh.triangleFillMode = .lines /// wireframe
//        mesh.cullMode = .front
//        mesh.cullMode = .back
//        mesh.cullMode = .none
        
        
//        let scale = Float(15)
//        let scale = Float(7) /// background
//        let scale = Float(4) /// objects
        let scale = Float(1) /// objects
        mesh.scale = simd_make_float3(scale, scale, scale)
//        mesh.position = simd_make_float3(0, 0, -200)
        mesh.position = simd_make_float3(0, 0, 0)
//        mesh.orientation = simd_quaternion(Float.pi * 0.25, simd_make_float3(0, 1, 1))
        
        add(mesh)
    }
    
    // MARK: - Materials
    
    func setupMaterialUniforms() {
        //
    }
    
    func updateMaterialUniforms() {
//        lightBufferIndex = (lightBufferIndex + 1) % maxBuffersInFlight
//        lightBufferOffset = lightUniformsSize * lightBufferIndex
//        lightUniforms = UnsafeMutableRawPointer(lightUniformsBuffer.contents() + lightBufferOffset).bindMemory(to: LightUniforms.self, capacity: 1)
    }
    
}
