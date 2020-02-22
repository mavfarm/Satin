//
//  FBO.swift
//  Satin
//
//  Created by Colin Duffy on 2/20/20.
//  Copyright © 2020 Colin Duffy. All rights reserved.
//

import Metal

open class FBO {
    
    public var writeBuffer: MTLTexture
    public var readBuffer: MTLTexture
    public var format: MTLPixelFormat
    
    public init(width: Int, height: Int, format: MTLPixelFormat) {
        self.writeBuffer = Pass.createRenderTarget(width: width, height: height, format: format)
        self.readBuffer = Pass.createRenderTarget(width: width, height: height, format: format)
        self.format = format
    }
    
    open func swapBuffers() {
        let temp = self.readBuffer
        self.readBuffer = self.writeBuffer
        self.writeBuffer = temp
    }
    
    open func resize(_ width: Int, _ height: Int) {
        self.writeBuffer = Pass.createRenderTarget(width: width, height: height, format: format)
        self.readBuffer = Pass.createRenderTarget(width: width, height: height, format: format)
    }
    
}
