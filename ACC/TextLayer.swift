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
            print("in the textColor")
            self.foregroundColor = textColor.CGColor
            self.setNeedsDisplay()
        }
    }
    
    var backColor: UIColor = UIColor.clearColor() {
        didSet {
            print("in the backColor")
            self.backgroundColor = backColor.CGColor
            self.setNeedsDisplay()
        }
    }
    
    var startValue: Double {
        didSet {
            print("in the startValue")
            updateUI()
            setNeedsDisplay()
        }
    }
    
    var scaleValue: Double {
        didSet {
            print("in the scaleValue")
            updateUI()
            setNeedsDisplay()
        }
    }
    
    init(frame: CGRect) {
        print("in the init")
        self.startValue = 0
        self.scaleValue = 2.0
        super.init()
        self.frame = frame
        //print(self.frame.size)
        self.foregroundColor = textColor.CGColor
        self.backgroundColor = backColor.CGColor
        
    }
    
    internal convenience required init?(coder aDecoder: NSCoder) {
        print("in required init")
        self.init(frame: CGRectZero)
    }
    
    override var frame: CGRect {
        didSet {
            print("in the frame in TextLayer")
            updateUI()
            updateBounds(bounds)
            setNeedsDisplay()
        }
    }
    
    private func updateUI() {
        
        print("in the TextLayer \(self.frame.size)")
        print("in the TextLayer \(self.frame.origin)")
        
        for i in 0..<Int(bounds.width) {
            let rightText: CATextLayer = CATextLayer()
            rightText.fontSize = 10
            rightText.frame = CGRectMake(-3 + self.frame.width/2 + CGFloat(i)*20, 0, 20, 20)
            rightText.string = "\(i * Int(scaleValue))"
            rightText.foregroundColor = UIColor.blackColor().CGColor
            self.addSublayer(rightText)
            
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
