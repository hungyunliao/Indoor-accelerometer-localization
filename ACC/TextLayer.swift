//
//  TextLayer.swift
//  ACC
//
//  Created by Hung-Yun Liao on 7/10/16.
//  Copyright © 2016 Hung-Yun Liao. All rights reserved.
//

import UIKit

class TextLayer: CATextLayer {
    /// Indicate the color of the grid line.
    @IBInspectable
    var textColor: UIColor = UIColor.blackColor() {
        didSet {
            self.foregroundColor = textColor.CGColor
            self.setNeedsDisplay()
        }
    }
    
    var origin = ThreeAxesSystem<CGFloat>(x: 0, y: 0, z: 0)
    
    var scaleValue: Double {
        didSet {
            updateUI()
            setNeedsDisplay()
        }
    }
    
    init(frame: CGRect) {
        
        self.scaleValue = 1.0
        super.init()
        self.frame = frame
        self.foregroundColor = textColor.CGColor
        self.backgroundColor = UIColor.clearColor().CGColor
        
    }
    
    internal convenience required init?(coder aDecoder: NSCoder) {
        self.init(frame: CGRectZero)
    }
    
    override var frame: CGRect {
        didSet {
            updateUI()
            updateBounds(bounds)
            setNeedsDisplay()
        }
    }
    
    func setOrigin(x: Double, y: Double) {
        origin.x = CGFloat(x)
        origin.y = CGFloat(y)
        updateUI()
    }
    
    private func showIntIfCan(aDouble: Double) -> String {
        return aDouble%1 != 0 ? "\(aDouble)" : "\(Int(aDouble))"
    }
    
    private func updateUI() {
        
        self.sublayers?.removeAll()
        
        let centerPoint = CGPointMake(origin.x, origin.y)
        
        for i in 0..<Int(bounds.width) {
            
            let shift: CGFloat
            if i%2 == 0 {
                shift = 0
            } else {
                shift = -15
            }
            
            let positiveXNums = drawTextLayer(CGRectMake(-3 + centerPoint.x + CGFloat(i)*20, centerPoint.y + shift, 30, 30), printText: showIntIfCan(Double(i) * scaleValue))
            self.addSublayer(positiveXNums)
            
            if i == 0 { continue }
            
            let negativeXNums = drawTextLayer(CGRectMake(-3 + centerPoint.x + CGFloat(-i)*20, centerPoint.y + shift, 30, 30), printText: showIntIfCan(Double(-i) * scaleValue))
            self.addSublayer(negativeXNums)
        }
        
        for i in 0..<Int(bounds.height) {
            
            if i == 0 { continue }
            
            let positiveYNums = drawTextLayer(CGRectMake(-20 + centerPoint.x, -8 + centerPoint.y + CGFloat(-i)*20 , 30, 30), printText: showIntIfCan(Double(i) * scaleValue))
            self.addSublayer(positiveYNums)
            
            let negativeYNums = drawTextLayer(CGRectMake(-25 + centerPoint.x, -8 + centerPoint.y + CGFloat(i)*20 , 30, 30), printText: showIntIfCan(Double(-i) * scaleValue))
            self.addSublayer(negativeYNums)
        }
    }
    
    private func drawTextLayer(frame: CGRect, printText: String) -> CATextLayer {
        let text: CATextLayer = CATextLayer()
        text.fontSize = 10
        text.frame = frame
        text.string = printText
        text.foregroundColor = UIColor.blackColor().CGColor
        return text
    }
    
    private func updateBounds(rect: CGRect) {
        
    }
    
}
