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
    @IBInspectable var pathColor:UIColor = UIColor.blackColor() {
        didSet {
            self.strokeColor = pathColor.CGColor
            self.setNeedsDisplay()
        }
    }
    
    init(frame: CGRect) {
        super.init()
        self.strokeColor = pathColor.CGColor
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
            updatePath(bounds)
            updateRoutePath()
        }
    }
    
    
    
    /* MARK: Private instances */
    // Not yet implement "Z" axis
    private var previousMapX: CGFloat = 0 { didSet { updateRoutePath() } }
    private var previousMapY: CGFloat = 0 { didSet { updateRoutePath() } }
    private var currentMapX: CGFloat = 0 { didSet { updateRoutePath() } }
    private var currentMapY: CGFloat = 0 { didSet { updateRoutePath() } }
    private var routePath = UIBezierPath()
    private var isReset = false
    private var scale: CGFloat = 1.0
    
    private var resetXOffset: CGFloat = 0.0
    private var resetYOffset: CGFloat = 0.0
    
    private var originX: CGFloat {
        get {
            return bounds.midX
        }
        set {
            self.originX = newValue
        }
    }
    
    private var originY: CGFloat {
        get {
            return bounds.midY
        }
        set {
            self.originY = newValue
        }
    }
    
    
    /* MARK: Public APIs */
    func setScale(scale: Double) {
        self.scale = CGFloat(scale)
    }
    
    func setOrigin(x: Double, y: Double) {
        cleanPath()
        originX = CGFloat(x)
        originY = CGFloat(y)
    }
    
    func movePointTo(x: Double, y: Double) {
        if !isReset {
            previousMapX = currentMapX
            previousMapY = currentMapY
        } else {
            previousMapX = 0
            previousMapY = 0
            isReset = false
        }
        currentMapX = CGFloat(x)*scale - resetXOffset
        currentMapY = CGFloat(y)*scale - resetYOffset
    }
    
    func cleanPath() {
        if currentMapX != 0 && currentMapY != 0 {
            resetXOffset += currentMapX
            resetYOffset += currentMapY
        }
        isReset = true
        routePath.removeAllPoints()
    }
    
    
    /**
     Draw Grids in given rectangle
     
     - Parameter rect: The rectangle area to draw the grids in it.
     
     */
    private func updatePath(rect: CGRect) {
        // Draw nothing when the rect is too small
        if CGRectGetWidth(rect) < 1 || CGRectGetHeight(rect) < 1 {
            return
        }
        self.setNeedsDisplay()
    }
    
    private func updateRoutePath() {
        let drawing = UIBezierPath()
        
//        let xAxis = getLinePath(CGPoint(x: 0, y: bounds.midY), endPoint: CGPoint(x: bounds.width, y: bounds.midY))
//        let yAxis = getLinePath(CGPoint(x: bounds.midX, y: 20), endPoint: CGPoint(x: bounds.midX, y: bounds.height))

        routePath.moveToPoint(CGPoint(x: previousMapX + originX, y: previousMapY + originY))
        routePath.addLineToPoint(CGPoint(x: currentMapX + originX, y: currentMapY + originY))
        
        var circle = UIBezierPath()
        circle = getCircle(atCenter: CGPoint(x: currentMapX + originX, y: currentMapY + originY), radius: CGFloat(5))
        
//        drawing.appendPath(xAxis)
//        drawing.appendPath(yAxis)
        drawing.appendPath(routePath)
        drawing.appendPath(circle)
        self.path = drawing.CGPath
        
        self.setNeedsDisplay()
    }
}
