//
//  MapView.swift
//  ACC
//
//  Created by Hung-Yun Liao on 6/8/16.
//  Copyright © 2016 Hung-Yun Liao. All rights reserved.
//

import UIKit

@IBDesignable
class MapView: UIView {
    
    @IBInspectable
    var mapx: Double = 0.0 {
        willSet {
            oldMapx = mapx
        }
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable
    var mapy: Double = 0.0 {
        willSet {
            oldMapy = mapy
        }
        didSet {
            setNeedsDisplay()
        }
    }
    
    var oldMapx: Double = 0.0
    var oldMapy: Double = 0.0
    
    override func drawRect(rect: CGRect) {
        
        let path = UIBezierPath()
        
        path.moveToPoint(CGPoint(x: oldMapx + Double(bounds.width/2), y: oldMapy + Double(bounds.height/2)))
        
        path.addLineToPoint(CGPoint(x: mapx + Double(bounds.width/2), y: mapy + Double(bounds.height/2)))
        
        path.lineWidth = 2.0
        
        UIColor.blueColor().set()
        
        path.stroke()
        
    }
    
}
