//
//  GridLayer.swift
//  ACC
//
//  Created by Antonio081014 on 7/6/16.
//  Copyright © 2016 Hung-Yun Liao. All rights reserved.
//

import UIKit

class GridView: UIView {
    
    // MARK: Instance variables
    var scaleValueForTheText: Double = 1
    var origin = ThreeAxesSystem<CGFloat>(x: 0, y: 0, z: 0)
    
    // MARK: Public APIs
    func setScale(scale: Double) {
        scaleValueForTheText = scale
        setNeedsDisplay()
    }
    
    func setOrigin(x: Double, y: Double) {
        origin.x = CGFloat(x)
        origin.y = CGFloat(y)
        setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        
        // Draw nothing when the rect is too small
        if CGRectGetWidth(rect) < 1 || CGRectGetHeight(rect) < 1 {
            return
        }
        
        /* Draw Texts */
        self.layer.sublayers?.removeAll() // removes the previous textLayer if has any
        let textLayer: TextLayer = TextLayer(frame: self.frame)
        textLayer.scaleValue = scaleValueForTheText
        textLayer.setOrigin(Double(origin.x), y: Double(origin.y))
        self.layer.addSublayer(textLayer)
        
        
        /* Draw Grids */
        let centerPoint = CGPointMake(origin.x, origin.y)
        
        // draw the grid
        let gridPath = UIBezierPath()
        let gridSize = CGFloat(10)
        let pattern: [CGFloat] = [4, 2]
        gridPath.setLineDash(pattern, count: 2, phase: 0.0)
        gridPath.lineWidth = 1
        
        // draw the scales
        let scalePath = UIBezierPath()
        scalePath.lineWidth = 2
        
        // draw X, Y axises
        let axisPath = UIBezierPath()
        axisPath.lineWidth = 2
        
        for i in 0...Int(bounds.height) {
            if i == 0 {
                axisPath.moveToPoint(CGPoint(x: CGFloat(0), y: centerPoint.y + CGFloat(i) * gridSize))
                axisPath.addLineToPoint(CGPoint(x: bounds.width, y: centerPoint.y + CGFloat(i) * gridSize))
                continue
            }
            if Double(i)%2 == 0 {
                scalePath.moveToPoint(CGPoint(x: centerPoint.x, y: centerPoint.y + CGFloat(i) * gridSize))
                scalePath.addLineToPoint(CGPoint(x: centerPoint.x + 5, y: centerPoint.y + CGFloat(i) * gridSize))
                
                scalePath.moveToPoint(CGPoint(x: centerPoint.x, y: centerPoint.y - CGFloat(i) * gridSize))
                scalePath.addLineToPoint(CGPoint(x: centerPoint.x + 5, y: centerPoint.y - CGFloat(i) * gridSize))
            }
            
            gridPath.moveToPoint(CGPoint(x: CGFloat(0), y: centerPoint.y + CGFloat(i) * gridSize))
            gridPath.addLineToPoint(CGPoint(x: bounds.width, y: centerPoint.y + CGFloat(i) * gridSize))
            
            gridPath.moveToPoint(CGPoint(x: CGFloat(0), y: centerPoint.y - CGFloat(i) * gridSize))
            gridPath.addLineToPoint(CGPoint(x: bounds.width, y: centerPoint.y - CGFloat(i) * gridSize))
        }
        
        for i in 0...Int(bounds.width) {
            if i == 0 {
                axisPath.moveToPoint(CGPoint(x: centerPoint.x +  CGFloat(i) * gridSize, y: CGFloat(0)))
                axisPath.addLineToPoint(CGPoint(x: centerPoint.x + CGFloat(i) * gridSize, y: bounds.height))
                continue
            }
            if Double(i)%2 == 0 {
                scalePath.moveToPoint(CGPoint(x: centerPoint.x +  CGFloat(i) * gridSize, y: centerPoint.y - 5))
                scalePath.addLineToPoint(CGPoint(x: centerPoint.x + CGFloat(i) * gridSize, y: centerPoint.y))
                
                scalePath.moveToPoint(CGPoint(x: centerPoint.x -  CGFloat(i) * gridSize, y: centerPoint.y - 5))
                scalePath.addLineToPoint(CGPoint(x: centerPoint.x - CGFloat(i) * gridSize, y: centerPoint.y))
            }
            
            gridPath.moveToPoint(CGPoint(x: centerPoint.x +  CGFloat(i) * gridSize, y: CGFloat(0)))
            gridPath.addLineToPoint(CGPoint(x: centerPoint.x + CGFloat(i) * gridSize, y: bounds.height))
            
            
            gridPath.moveToPoint(CGPoint(x: centerPoint.x -  CGFloat(i) * gridSize, y: CGFloat(0)))
            gridPath.addLineToPoint(CGPoint(x: centerPoint.x - CGFloat(i) * gridSize, y: bounds.height))
        }
        
        UIColor.blackColor().colorWithAlphaComponent(0.1).set()
        gridPath.stroke()
        UIColor.blackColor().set()
        scalePath.stroke()
        UIColor.blackColor().set()
        axisPath.stroke()
    }
}


class GradientView: UIView {
    
    override var frame: CGRect { didSet { setNeedsDisplay() } }
    
    private var topColor: CGColor = UIColor.clearColor().CGColor
    private var bottomColor: CGColor = UIColor.clearColor().CGColor
    
    func colorSetUp(topColor: CGColor, bottomColor: CGColor) {
        self.topColor = topColor
        self.bottomColor = bottomColor
        setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        self.layer.sublayers?.removeAll()
        self.layerGradient(topColor, bottomColor: bottomColor)
    }
}
