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
    
    private func updateUI() {
        
        for i in 0..<Int(bounds.width) {
            let rightText: CATextLayer = CATextLayer()
            rightText.fontSize = 10
            rightText.frame = CGRectMake(-3 + self.frame.width/2 + CGFloat(i)*20, 0, 20, 20)
            rightText.string = "\(i * Int(scaleValue))"
            rightText.foregroundColor = UIColor.blackColor().CGColor
            self.addSublayer(rightText)
            
            if i == 0 {
                continue
            }
            
            let leftText: CATextLayer = CATextLayer()
            leftText.fontSize = 10
            leftText.frame = CGRectMake(-3 + self.frame.width/2 + CGFloat(-i)*20, 0, 20, 20)
            leftText.string = "\(-i * Int(scaleValue))"
            leftText.foregroundColor = UIColor.blackColor().CGColor
            self.addSublayer(leftText)
        }
        
        for i in 0..<Int(bounds.height) {
            
            if i == 0 {
                continue
            }
            
            let upText: CATextLayer = CATextLayer()
            upText.fontSize = 10
            upText.frame = CGRectMake(-13 + self.frame.width/2, -8 + CGFloat(-i)*20 , 20, 20)
            upText.string = "\(i * Int(scaleValue))"
            upText.foregroundColor = UIColor.blackColor().CGColor
            self.addSublayer(upText)
            
            let downText: CATextLayer = CATextLayer()
            downText.fontSize = 10
            downText.frame = CGRectMake(-17 + self.frame.width/2, -8 + CGFloat(i)*20 , 20, 20)
            downText.string = "\(-i * Int(scaleValue))"
            downText.foregroundColor = UIColor.blackColor().CGColor
            self.addSublayer(downText)
        }
    }
    
    private func updateBounds(rect: CGRect) {
        
    }
    
}
