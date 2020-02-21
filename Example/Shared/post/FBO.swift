//
//  FBO.swift
//  Example iOS
//
//  Created by Colin Duffy on 2/20/20.
//  Copyright © 2020 Reza Ali. All rights reserved.
//

import Metal

class FBO {
    
    var writeBuffer: MTLTexture
    var readBuffer: MTLTexture
    var format: MTLPixelFormat
    
    init(width: Int, height: Int, format: MTLPixelFormat) {
        self.writeBuffer = Pass.createRenderTarget(width: width, height: height, format: format)
        self.readBuffer = Pass.createRenderTarget(width: width, height: height, format: format)
        self.format = format
    }
    
    func swapBuffers() {
        let temp = self.readBuffer
        self.readBuffer = self.writeBuffer
        self.writeBuffer = temp
    }
    
    func resize(_ width: Int, _ height: Int) {
        self.writeBuffer = Pass.createRenderTarget(width: width, height: height, format: format)
        self.readBuffer = Pass.createRenderTarget(width: width, height: height, format: format)
    }
    
}
