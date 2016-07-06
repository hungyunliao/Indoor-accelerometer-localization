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
    @IBInspectable var gridColor:UIColor = UIColor.cyanColor() {
        didSet {
            self.strokeColor = gridColor.CGColor
            self.setNeedsDisplay()
        }
    }
    
    init(frame: CGRect) {
        super.init()
        self.strokeColor = gridColor.CGColor
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
        let gridSize = CGFloat(10)
        
        let gridPath = UIBezierPath()
        
        for i in 0...Int(bounds.height) {
            gridPath.moveToPoint(CGPoint(x: CGFloat(0), y: centerPoint.y + CGFloat(i) * gridSize))
            gridPath.addLineToPoint(CGPoint(x: bounds.width, y: centerPoint.y + CGFloat(i) * gridSize))
            
            gridPath.moveToPoint(CGPoint(x: CGFloat(0), y: centerPoint.y - CGFloat(i) * gridSize))
            gridPath.addLineToPoint(CGPoint(x: bounds.width, y: centerPoint.y - CGFloat(i) * gridSize))
        }
        
        for i in 0...Int(bounds.width) {
            gridPath.moveToPoint(CGPoint(x: centerPoint.x +  CGFloat(i) * gridSize, y: CGFloat(0)))
            gridPath.addLineToPoint(CGPoint(x: centerPoint.x + CGFloat(i) * gridSize, y: bounds.height))
            
            gridPath.moveToPoint(CGPoint(x: centerPoint.x -  CGFloat(i) * gridSize, y: CGFloat(0)))
            gridPath.addLineToPoint(CGPoint(x: centerPoint.x - CGFloat(i) * gridSize, y: bounds.height))
        }
        self.path = gridPath.CGPath
        self.setNeedsDisplay()
    }
}
