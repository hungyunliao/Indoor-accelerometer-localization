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

    @IBInspectable var
    mapx: Double = 0.0 { didSet { setNeedsDisplay() } }
    @IBInspectable var
    mapy: Double = 0.0 { didSet { setNeedsDisplay() } }

    override func drawRect(rect: CGRect) {
        
        let path = UIBezierPath()
        
        path.moveToPoint(CGPoint(x: bounds.width/2, y: bounds.height/2))
        
        path.addLineToPoint(CGPoint(x: mapx, y: mapy))
        
        path.lineWidth = 5.0
        
        UIColor.blueColor().set()
        
        path.stroke()
    }

}
