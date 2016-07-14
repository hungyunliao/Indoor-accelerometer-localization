//
//  GridLayer.swift
//  ACC
//
//  Created by Antonio081014 on 7/6/16.
//  Copyright © 2016 Hung-Yun Liao. All rights reserved.
//

import UIKit

class GridLayer: CAShapeLayer {
    
    /// Indicate the color of the grid line.
    @IBInspectable var gridColor:UIColor = UIColor.blackColor().colorWithAlphaComponent(0.2) {
        didSet {
            self.strokeColor = gridColor.CGColor
            self.setNeedsDisplay()
        }
    }
    
    init(frame: CGRect) {
        super.init()
        self.strokeColor = gridColor.CGColor
        self.backgroundColor = UIColor.clearColor().CGColor
        self.lineWidth = 1.0
        self.lineDashPattern = [4, 2]
        self.lineDashPhase = 0.0
        self.frame = frame
    }
    
    internal convenience required init?(coder aDecoder: NSCoder) {
        self.init(frame: CGRectZero)
    }
    
    override var frame: CGRect {
        didSet {
            updateGridPath(bounds)
        }
    }
    
    /**
     Draw Grids in given rectangle
     
     - Parameter rect: The rectangle area to draw the grids in it.
     
     */
    private func updateGridPath(rect: CGRect) {
        // Draw nothing when the rect is too small
        if CGRectGetWidth(rect) < 1 || CGRectGetHeight(rect) < 1 {
            return
        }
        let centerPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))
        
        // draw the grid
        let gridPath = UIBezierPath()
        let gridSize = CGFloat(10)
        
        // draw the scales
        let scalePath = UIBezierPath()
        let scaleLayer = CAShapeLayer()
        scaleLayer.strokeColor = UIColor.blackColor().CGColor
        scaleLayer.lineWidth = 1.5
        
        // draw X, Y axises
        let axisPath = UIBezierPath()
        let axisLayer = CAShapeLayer()
        axisLayer.strokeColor = UIColor.blackColor().CGColor
        axisLayer.lineWidth = 2
        
        
        for i in 0...Int(bounds.height) {
            if i == 0 {
                axisPath.moveToPoint(CGPoint(x: CGFloat(0), y: centerPoint.y + CGFloat(i) * gridSize))
                axisPath.addLineToPoint(CGPoint(x: bounds.width, y: centerPoint.y + CGFloat(i) * gridSize))
                continue
            }
            if Double(i)%2 == 0 {
                scalePath.moveToPoint(CGPoint(x: bounds.width/2, y: centerPoint.y + CGFloat(i) * gridSize))
                scalePath.addLineToPoint(CGPoint(x: bounds.width/2 + 5, y: centerPoint.y + CGFloat(i) * gridSize))
                
                scalePath.moveToPoint(CGPoint(x: bounds.width/2, y: centerPoint.y - CGFloat(i) * gridSize))
                scalePath.addLineToPoint(CGPoint(x: bounds.width/2 + 5, y: centerPoint.y - CGFloat(i) * gridSize))
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
                scalePath.moveToPoint(CGPoint(x: centerPoint.x +  CGFloat(i) * gridSize, y: bounds.height/2 - 5))
                scalePath.addLineToPoint(CGPoint(x: centerPoint.x + CGFloat(i) * gridSize, y: bounds.height/2))
                
                scalePath.moveToPoint(CGPoint(x: centerPoint.x -  CGFloat(i) * gridSize, y: bounds.height/2 - 5))
                scalePath.addLineToPoint(CGPoint(x: centerPoint.x - CGFloat(i) * gridSize, y: bounds.height/2))
            }
            
            gridPath.moveToPoint(CGPoint(x: centerPoint.x +  CGFloat(i) * gridSize, y: CGFloat(0)))
            gridPath.addLineToPoint(CGPoint(x: centerPoint.x + CGFloat(i) * gridSize, y: bounds.height))
            
            
            gridPath.moveToPoint(CGPoint(x: centerPoint.x -  CGFloat(i) * gridSize, y: CGFloat(0)))
            gridPath.addLineToPoint(CGPoint(x: centerPoint.x - CGFloat(i) * gridSize, y: bounds.height))
        }
        
        scaleLayer.path = scalePath.CGPath
        axisLayer.path = axisPath.CGPath
        
        self.path = gridPath.CGPath
        self.addSublayer(scaleLayer)
        self.addSublayer(axisLayer)
        self.setNeedsDisplay()
    }
}
