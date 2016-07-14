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
    
    private func showIntIfCan(aDouble: Double) -> String {
        return aDouble%1 != 0 ? "\(aDouble)" : "\(Int(aDouble))"
    }
    
    private func updateUI() {
        
        self.sublayers?.removeAll()
        
        for i in 0..<Int(bounds.width) {
            let shift: CGFloat
            if i%2 == 0 {
                shift = 0
            } else {
                shift = -15
            }
            let rightText: CATextLayer = CATextLayer()
            rightText.fontSize = 10
            rightText.frame = CGRectMake(-3 + self.frame.width/2 + CGFloat(i)*20, shift, 30, 30)
            rightText.string = showIntIfCan(Double(i) * scaleValue)
            rightText.foregroundColor = UIColor.blackColor().CGColor
            self.addSublayer(rightText)
            
            if i == 0 {
                continue
            }
            
            let leftText: CATextLayer = CATextLayer()
            leftText.fontSize = 10
            leftText.frame = CGRectMake(-3 + self.frame.width/2 + CGFloat(-i)*20, shift, 30, 30)
            leftText.string = showIntIfCan(Double(-i) * scaleValue)
            leftText.foregroundColor = UIColor.blackColor().CGColor
            self.addSublayer(leftText)
        }
        
        for i in 0..<Int(bounds.height) {
            
            if i == 0 {
                continue
            }
            
            let upText: CATextLayer = CATextLayer()
            upText.fontSize = 10
            upText.frame = CGRectMake(-20 + self.frame.width/2, -8 + CGFloat(-i)*20 , 30, 30)
            upText.string = showIntIfCan(Double(i) * scaleValue)
            upText.foregroundColor = UIColor.blackColor().CGColor
            self.addSublayer(upText)
            
            let downText: CATextLayer = CATextLayer()
            downText.fontSize = 10
            downText.frame = CGRectMake(-25 + self.frame.width/2, -8 + CGFloat(i)*20 , 30, 30)
            downText.string = showIntIfCan(Double(-i) * scaleValue)
            downText.foregroundColor = UIColor.blackColor().CGColor
            self.addSublayer(downText)
        }
    }
    
    private func updateBounds(rect: CGRect) {
        
    }
    
}
