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
    
    var circleColor: UIColor = UIColor.init(red: 0, green: 71/255.0, blue: 102/255.0, alpha: 0.8) {
        didSet {
            self.fillColor = circleColor.CGColor
            self.setNeedsDisplay()
        }
    }
    
    init(frame: CGRect) {
        super.init()
        self.strokeColor = pathColor.CGColor
        self.fillColor = circleColor.CGColor
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
    private var previousOrigin = ThreeAxesSystem<CGFloat>(x: 0, y: 0, z:0)
    private var currentOrigin = ThreeAxesSystem<CGFloat>(x: 0, y: 0, z:0)
    private var previousPoint = ThreeAxesSystem<CGFloat>(x: 0, y: 0, z: 0)
    private var currentPoint = ThreeAxesSystem<CGFloat>(x: 0, y: 0, z: 0)
    private var resetOffset = ThreeAxesSystem<CGFloat>(x: 0, y: 0, z:0)
    
    private var isResetScale = false
    private var accumulatedScale: CGFloat = 1.0
    
    
    /* MARK: Public APIs */
    func setScale(scale: Double) {
        accumulatedScale *= CGFloat(scale)
        resetOffset.x *= CGFloat(scale)
        resetOffset.y *= CGFloat(scale)
        
        if !pathPoints.isEmpty {
            for i in 0..<pathPoints.count {
                pathPoints[i].x *= CGFloat(scale)
                pathPoints[i].y *= CGFloat(scale)
                pathPoints[i].z *= CGFloat(scale)
            }
            
            currentPoint.x = pathPoints[pathPoints.count-1].x
            currentPoint.y = pathPoints[pathPoints.count-1].y
            isResetScale = true
        }
        updateRoutePath()
    }
    
    func setOrigin(x: Double, y: Double) {
        
        previousOrigin.x = currentOrigin.x
        previousOrigin.y = currentOrigin.y
        
        if !pathPoints.isEmpty {
            for i in 0..<pathPoints.count {
                pathPoints[i].x -= (currentOrigin.x - previousOrigin.x)
                pathPoints[i].y -= (currentOrigin.x - previousOrigin.x)
            }
            
            currentPoint.x = pathPoints[pathPoints.count-1].x
            currentPoint.y = pathPoints[pathPoints.count-1].y
            isResetScale = true
        }

        resetOffset.x += (currentOrigin.x - previousOrigin.x)
        resetOffset.y += (currentOrigin.y - previousOrigin.y)
        
        currentOrigin.x = CGFloat(x)
        currentOrigin.y = CGFloat(y)
        updateRoutePath()
    }
    
    func movePointTo(x: Double, y: Double) {
        
        previousPoint.x = currentPoint.x
        previousPoint.y = currentPoint.y

        currentPoint.x = CGFloat(x)*accumulatedScale - resetOffset.x
        currentPoint.y = CGFloat(y)*accumulatedScale - resetOffset.y
        
        pathPoints.append(ThreeAxesSystem<CGFloat>(x: currentPoint.x, y: currentPoint.y, z: 0)) // z has not yet been implemented
        updateRoutePath()
    }
    
    func cleanPath() {
        
        if !pathPoints.isEmpty {
            resetOffset.x += currentPoint.x
            resetOffset.y += currentPoint.y
        }
        currentPoint.x = 0
        currentPoint.y = 0
        previousPoint.x = 0
        previousPoint.y = 0
        
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
                routePath.moveToPoint(CGPoint(x: pathPoints[i].x + currentOrigin.x, y: pathPoints[i].y + currentOrigin.y))
                routePath.addLineToPoint(CGPoint(x: pathPoints[i+1].x + currentOrigin.x, y: pathPoints[i+1].y + currentOrigin.y))
            }
            isResetScale = false
            
        } else {
            routePath.moveToPoint(CGPoint(x: previousPoint.x + currentOrigin.x, y: previousPoint.y + currentOrigin.y))
            routePath.addLineToPoint(CGPoint(x: currentPoint.x + currentOrigin.x, y: currentPoint.y + currentOrigin.y))
        }
        
        var circle = UIBezierPath()
        circle = getCircle(atCenter: CGPoint(x: currentPoint.x + currentOrigin.x, y: currentPoint.y + currentOrigin.y), radius: CGFloat(5))
        
        drawing.appendPath(routePath)
        drawing.appendPath(circle)
        self.path = drawing.CGPath
        
        self.setNeedsDisplay()
    }
}

