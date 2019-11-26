//
//  Lights.swift
//
//  Created by Colin Duffy on 10/30/19.
//

import Foundation
import simd
import Metal
import Satin

public struct IncidentLight {
    var color: simd_float3
    var direction: simd_float3
    var visible: Bool
}

public struct ReflectedLight {
    var directDiffuse: simd_float3
    var directSpecular: simd_float3
    var indirectDiffuse: simd_float3
    var indirectSpecular: simd_float3
}

public struct GeometricContext {
    var position: simd_float3
    var normal: simd_float3
    var viewDir: simd_float3
    #if CLEARCOAT
    var clearcoatNormal: simd_float3
    #endif
}

public struct DirectionalLight {
    var direction: simd_float3
    var color: simd_float3
    
    var shadow: Int
    var shadowBias: Float
    var shadowRadius: Float
    var shadowMapSize: simd_float2
}

/*
 typedef struct
 {
     // Per-frame uniforms.
     matrix_float4x4 projectionMatrix;
     matrix_float4x4 projectionMatrixInv;
     matrix_float4x4 viewMatrix;
     matrix_float4x4 viewMatrixInv;
     vector_float2 depthUnproject;
     vector_float3 screenToViewSpace;
     
     // Per-mesh uniforms.
     matrix_float4x4 modelViewMatrix;
     matrix_float3x3 normalMatrix;
     matrix_float4x4 modelMatrix;
     
     // Per-light properties.
     vector_float3 ambientLightColor;
     vector_float3 directionalLightDirection;
     vector_float3 directionalLightColor;
     uint framebufferWidth;
     uint framebufferHeight;
 } AAPLUniforms;
 */

//public struct PointLight {
//    var position: simd_float3
//    var color: simd_float3
//    var distance: Float
//    var decay: Float
//
//    var shadow: Int
//    var shadowBias: Float
//    var shadowRadius: Float
//    var shadowMapSize: simd_float2
//    var shadowCameraNear: Float
//    var shadowCameraFar: Float
//}

public struct PointLight {
    var position: vector_float3
    var color: vector_float3
    var distance: Float
    var decay: Float
    
    var shadow: uint
    var shadowBias: Float
    var shadowRadius: Float
    var shadowMapSize: vector_float2
    var shadowCameraNear: Float
    var shadowCameraFar: Float
}

public struct SpotLight {
    var position: simd_float3
    var direction: simd_float3
    var color: simd_float3
    var distance: Float
    var decay: Float
    var coneCos: Float
    var penumbraCos: Float
    
    var shadow: Int
    var shadowBias: Float
    var shadowRadius: Float
    var shadowMapSize: simd_float2
}

public struct RectAreaLight {
    var color: simd_float3
    var position: simd_float3
    var halfWidth: simd_float3
    var halfHeight: simd_float3
}

public struct HemisphereLight {
    var direction: simd_float3
    var skyColor: simd_float3
    var groundColor: simd_float3
}

public struct LightUniforms {
    var POINT_LIGHTS: uint
    
    var ambientLightColor: vector_float3
//    var lightProbe: [simd_float3]
    
    
//    var NUM_DIR_LIGHTS: Int
//    var NUM_SPOT_LIGHTS: Int
//    var NUM_RECT_AREA_LIGHTS: Int
//    var NUM_HEMI_LIGHTS: Int
    
    var pointLights: [PointLight]
//    var directionalLights: [DirectionalLight]
//    var spotLights: [SpotLight]
//    var rectAreaLights: [RectAreaLight]
//    var hemisphereLights: [HemisphereLight]
}

public class LightManager {
    
    public var uniforms: LightUniforms /// what we update
    public var buffer: MTLBuffer! /// what we pass to the GPU (shaders)
    
    let alignedUniformsSize = ((MemoryLayout<LightUniforms>.size + 255) / 256) * 256
    var uniformBufferIndex: Int = 0
    var uniformBufferOffset: Int = 0
    var uniformsPointer: UnsafeMutablePointer<LightUniforms>!
    
    init() {
        self.uniforms = LightUniforms(
            POINT_LIGHTS: 1,
            ambientLightColor: vector_float3(0, 1, 0),
//            lightProbe: [
//                simd_make_float3(0, 0, 0),
//                simd_make_float3(0, 0, 0),
//                simd_make_float3(0, 0, 0),
//                simd_make_float3(0, 0, 0),
//                simd_make_float3(0, 0, 0),
//                simd_make_float3(0, 0, 0),
//                simd_make_float3(0, 0, 0),
//                simd_make_float3(0, 0, 0),
//                simd_make_float3(0, 0, 0)
//            ],
//            NUM_DIR_LIGHTS: 0,
//            NUM_SPOT_LIGHTS: 0,
//            NUM_RECT_AREA_LIGHTS: 0,
//            NUM_HEMI_LIGHTS: 0,
            pointLights: []
//            directionalLights: [],
//            spotLights: []
//            rectAreaLights: [],
//            hemisphereLights: []
        )
        
        ///
        let uniformBufferSize = alignedUniformsSize * Satin.maxBuffersInFlight
        print(alignedUniformsSize, uniformBufferSize)
        guard let uniBuffer = Renderer.device.makeBuffer(length: uniformBufferSize, options: [MTLResourceOptions.storageModeShared]) else { return }
        buffer = uniBuffer
        buffer.label = "Light Uniforms"
        uniformsPointer = UnsafeMutableRawPointer(buffer.contents()).bindMemory(to: LightUniforms.self, capacity: 1)
    }
    
    public var offset: Int {
        get {
            return uniformBufferOffset
        }
    }
    
    // MARK: Add
    
    public func addPointLight(light:PointLight) {
//        self.uniforms.pointLights.append(light)
    }
    
//    public func addDirectionalLight(light:DirectionalLight) {
//        self.uniforms.directionalLights.append(light)
//    }
    
//    public func addSpotLight(light:SpotLight) {
//        self.uniforms.spotLights.append(light)
//    }
    
//    public func addRectLight(light:RectAreaLight) {
//        self.uniforms.rectAreaLights.append(light)
//    }
//
//    public func addHemiLight(light:HemisphereLight) {
//        self.uniforms.hemisphereLights.append(light)
//    }
    
    // MARK: Update
    
    public func update() {
        updateUniformsBuffer()
        updateUniforms()
    }
    
    func updateUniforms() {
        uniforms.POINT_LIGHTS = UInt32(uniforms.pointLights.count)
//        uniforms.NUM_DIR_LIGHTS = uniforms.directionalLights.count
//        uniforms.NUM_SPOT_LIGHTS = uniforms.spotLights.count
//        uniforms.NUM_RECT_AREA_LIGHTS = uniforms.rectAreaLights.count
//        uniforms.NUM_HEMI_LIGHTS = uniforms.hemisphereLights.count
        
        uniformsPointer[0] = uniforms
    }
    
    func updateUniformsBuffer() {
        if buffer != nil {
            uniformBufferIndex = (uniformBufferIndex + 1) % maxBuffersInFlight
            uniformBufferOffset = alignedUniformsSize * uniformBufferIndex
            uniformsPointer = UnsafeMutableRawPointer(buffer.contents() + uniformBufferOffset).bindMemory(to: LightUniforms.self, capacity: 1)
        }
    }
}
