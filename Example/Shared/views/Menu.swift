//
//  Menu.swift
//  Example iOS
//
//  Created by Colin Duffy on 10/24/19.
//  Copyright © 2019 Reza Ali. All rights reserved.
//

import Metal
import MetalKit
import Satin

class Menu: Object {
    
    var btnTop: ImagePlane!
    var btnBottom: ImagePlane!
    var btnLeft: ImagePlane!
    var btnRight: ImagePlane!
    
    private var _selectedItem: ImagePlane?
    
    init(context:Context?) {
        super.init()
        self.context = context
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    func setup(library: MTLLibrary?, device: MTLDevice) {
        /*
         TOP = Search
         Left = Channels
         Right = Shop
         Bottom = Signal
         */
        
        let scale = UIScreen.main.nativeScale
        let x = Float(UIScreen.main.bounds.width  * 0.4 * scale)
        let y = Float(UIScreen.main.bounds.height * 0.45 * scale)
        let a = Float.pi * 0.5
        
        /// Buttons
        btnTop = ImagePlane(context: context)
        btnTop.setup(library: library, device: device, textureName: "nav_search")
        btnTop.position.y = y
        add(btnTop)
        
        btnBottom = ImagePlane(context: context)
        btnBottom.setup(library: library, device: device, textureName: "nav_signal")
        btnBottom.position.y = -y
        add(btnBottom)
        
        btnLeft = ImagePlane(context: context)
        btnLeft.setup(library: library, device: device, textureName: "nav_channels")
        btnLeft.position.x = -x
        btnLeft.orientation = simd_quaternion(a, simd_make_float3(0, 0, 1))
        add(btnLeft)
        
        btnRight = ImagePlane(context: context)
        btnRight.setup(library: library, device: device, textureName: "nav_shop")
        btnRight.position.x = x
        btnRight.orientation = simd_quaternion(-a, simd_make_float3(0, 0, 1))
        add(btnRight)
    }
    
    public func setItem(name:String) {
        if(name == "top") {
            selectedItem = btnTop
        } else if(name == "bottom") {
            selectedItem = btnBottom
        } else if(name == "left") {
            selectedItem = btnLeft
        } else if(name == "right") {
            selectedItem = btnRight
        } else {
            selectedItem = nil
        }
    }
    
    public var selectedItem: ImagePlane? {
        get {
            return _selectedItem
        }
        set(value) {
            if(_selectedItem != nil) {
                _selectedItem?.deselectItem()
            }
            
            _selectedItem = value
            if(_selectedItem != nil) {
                _selectedItem?.selectItem()
            }
            
        }
    }
    
}
