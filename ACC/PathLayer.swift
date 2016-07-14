//
//  PathLayer.swift
//  ACC
//
//  Created by Hung-Yun Liao on 7/7/16.
//  Copyright © 2016 Hung-Yun Liao. All rights reserved.
//

import UIKit

class PathLayer: CAShapeLayer {
    /// Indicate the color of the grid line.
    @IBInspectable var pathColor:UIColor = UIColor.blueColor() {
        didSet {
            self.strokeColor = pathColor.CGColor
            self.setNeedsDisplay()
        }
    }
    
    init(frame: CGRect) {
        super.init()
        self.strokeColor = pathColor.CGColor
        self.fillColor = pathColor.CGColor
        self.backgroundColor = UIColor.clearColor().CGColor
        self.frame = frame
    }
    
    internal convenience required init?(coder aDecoder: NSCoder) {
        self.init(frame: CGRectZero)
    }
    
    override var frame: CGRect {
        didSet {
            updatePath(bounds)
            updateRoutePath()
        }
    }
    
    
    
    /* MARK: Private instances */
    // Not yet implement "Z" axis
    private var routePath = UIBezierPath()
    private var pathPoints = [ThreeAxesSystem<CGFloat>]() // an array that keeps the original path points which are used to re-draw the routePath when the scale is changed.
    private var origin = ThreeAxesSystem<CGFloat>(x: 0, y: 0, z:0)
    private var previousPoint = ThreeAxesSystem<CGFloat>(x: 0, y: 0, z: 0)
    private var currentPoint = ThreeAxesSystem<CGFloat>(x: 0, y: 0, z: 0)
    private var resetOffset = ThreeAxesSystem<CGFloat>(x: 0, y: 0, z:0)
    
    private var isReset = false
    private var isResetScale = false
    private var scale: CGFloat = 1.0
    
    
    /* MARK: Public APIs */
    func setScale(scale: Double) {
        self.scale = CGFloat(scale)
        if !pathPoints.isEmpty {
            for i in 0..<pathPoints.count {
                pathPoints[i].x *= self.scale
                pathPoints[i].y *= self.scale
                pathPoints[i].z *= self.scale
            }
            
            currentPoint.x = pathPoints[pathPoints.count-1].x
            currentPoint.y = pathPoints[pathPoints.count-1].y
            isResetScale = true
        }
        updateRoutePath()
    }
    
    func setOrigin(x: Double, y: Double) {
        cleanPath()
        origin.x = CGFloat(x)
        origin.y = CGFloat(y)
        updateRoutePath()
    }
    
    func movePointTo(x: Double, y: Double) {
        
        if !isReset {
            previousPoint.x = currentPoint.x
            previousPoint.y = currentPoint.y
        } else {
            previousPoint.x = 0
            previousPoint.y = 0
            isReset = false
        }
        currentPoint.x = CGFloat(x)*scale - resetOffset.x
        currentPoint.y = CGFloat(y)*scale - resetOffset.y
        
        pathPoints.append(ThreeAxesSystem<CGFloat>(x: currentPoint.x, y: currentPoint.y, z: 0)) // z has not yet been implemented
        updateRoutePath()
    }
    
    func cleanPath() {
        if currentPoint.x != 0 && currentPoint.y != 0 {
            resetOffset.x += currentPoint.x
            resetOffset.y += currentPoint.y
        }
        isReset = true
        routePath.removeAllPoints()
        pathPoints.removeAll()
        updateRoutePath()
    }
    
    private func updatePath(rect: CGRect) {
        // Draw nothing when the rect is too small
        if CGRectGetWidth(rect) < 1 || CGRectGetHeight(rect) < 1 {
            return
        }
        self.setNeedsDisplay()
    }
    
    private func updateRoutePath() {
        
        let drawing = UIBezierPath()
        
        if isResetScale {
            routePath.removeAllPoints()
            for i in 0..<(pathPoints.count - 1) {
                routePath.moveToPoint(CGPoint(x: pathPoints[i].x + origin.x, y: pathPoints[i].y + origin.y))
                routePath.addLineToPoint(CGPoint(x: pathPoints[i+1].x + origin.x, y: pathPoints[i+1].y + origin.y))
            }
            isResetScale = false
            
        } else {
            routePath.moveToPoint(CGPoint(x: previousPoint.x + origin.x, y: previousPoint.y + origin.y))
            routePath.addLineToPoint(CGPoint(x: currentPoint.x + origin.x, y: currentPoint.y + origin.y))
        }
        
        var circle = UIBezierPath()
        circle = getCircle(atCenter: CGPoint(x: currentPoint.x + origin.x, y: currentPoint.y + origin.y), radius: CGFloat(5))
        
        drawing.appendPath(routePath)
        drawing.appendPath(circle)
        self.path = drawing.CGPath
        
        self.setNeedsDisplay()
    }
}

