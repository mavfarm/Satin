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
    
    private var geometry: Geometry!
    private var mesh: Mesh!
    
    override init() {
        super.init()
        self.id = "Background"
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    override open func setup() {
        geometry = IcoSphereGeometry(radius: 400, res: 2)
        
        mesh = Mesh(geometry: geometry, material: BasicColorMaterial(simd_make_float4(0, 0, 1, 1)))
        mesh.id = "Ball"
        mesh.triangleFillMode = .lines /// wireframe
        add(mesh)
    }
    
}
