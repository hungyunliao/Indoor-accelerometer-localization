//
//  MapView.swift
//  ACC
//
//  Created by Hung-Yun Liao on 6/8/16.
//  Copyright © 2016 Hung-Yun Liao. All rights reserved.
//

import UIKit


class MapView: UIView {
    
    /* MARK: Private instances */
    // Not yet implement "Z" axis
    private var previousMapX: CGFloat = 0 { didSet { setNeedsDisplay() } }
    private var previousMapY: CGFloat = 0 { didSet { setNeedsDisplay() } }
    private var currentMapX: CGFloat = 0 { didSet { setNeedsDisplay() } }
    private var currentMapY: CGFloat = 0 { didSet { setNeedsDisplay() } }
    private var path = UIBezierPath()
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
        path.removeAllPoints()
    }
    
    override func drawRect(rect: CGRect) {
        
        let xAxis = getLinePath(CGPoint(x: 0, y: bounds.midY), endPoint: CGPoint(x: bounds.width, y: bounds.midY))
        xAxis.lineWidth = 2.0
        UIColor.whiteColor().set()
        xAxis.stroke()
        
        let yAxis = getLinePath(CGPoint(x: bounds.midX, y: 20), endPoint: CGPoint(x: bounds.midX, y: bounds.height))
        yAxis.lineWidth = 2.0
        UIColor.whiteColor().set()
        yAxis.stroke()
        
        //drawGrid(CGPoint(x: originX, y: originY), gridSize: CGFloat(10))
        
        path.moveToPoint(CGPoint(x: previousMapX + originX, y: previousMapY + originY))
        path.addLineToPoint(CGPoint(x: currentMapX + originX, y: currentMapY + originY))
        path.lineWidth = 3.0
        UIColor.yellowColor().set()
        path.stroke()

        var circle = UIBezierPath()
        circle = getCircle(atCenter: CGPoint(x: currentMapX + originX, y: currentMapY + originY), radius: CGFloat(5))
        UIColor.cyanColor().set()
        circle.fill()
        
    }
}

class MapViewGrid: UIView {
    
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        drawGrid(CGPoint(x: bounds.midX, y: bounds.midY), gridSize: CGFloat(10))
    }
    
    private func drawGrid(centerPoint: CGPoint, gridSize: CGFloat) {
        
        var gridPath = UIBezierPath()
        UIColor.grayColor().set()
        gridPath.lineWidth = 1.0
        let pattern: [CGFloat] = [4, 2]
        var i: CGFloat = 1
        
        // draw x-direction lines
        while (i <= bounds.height) {
            gridPath = getLinePath(CGPoint(x: 0, y: centerPoint.y + i*gridSize), endPoint: CGPoint(x: bounds.width, y: centerPoint.y + i*gridSize))
            gridPath.setLineDash(pattern, count: 2, phase: 0.0)
            gridPath.stroke()
            
            gridPath = getLinePath(CGPoint(x: 0, y: centerPoint.y + -i*gridSize), endPoint: CGPoint(x: bounds.width, y: centerPoint.y + -i*gridSize))
            gridPath.setLineDash(pattern, count: 2, phase: 0.0)
            gridPath.stroke()
            i += 1
        }
        
        i = 1
        
        // draw y-direction lines
        while (i <= bounds.width) {
            gridPath = getLinePath(CGPoint(x: centerPoint.x + i*gridSize, y: 0), endPoint: CGPoint(x: centerPoint.x + i*gridSize, y: bounds.height))
            gridPath.setLineDash(pattern, count: 2, phase: 0.0)
            gridPath.stroke()
            
            gridPath = getLinePath(CGPoint(x: centerPoint.x + -i*gridSize, y: 0), endPoint: CGPoint(x: centerPoint.x + -i*gridSize, y: bounds.height))
            gridPath.setLineDash(pattern, count: 2, phase: 0.0)
            gridPath.stroke()
            
            i += 1
        }
    }
}

private func getCircle(atCenter center: CGPoint, radius: CGFloat) -> UIBezierPath {
    return UIBezierPath(arcCenter: center, radius: radius, startAngle: 0.0, endAngle: CGFloat(2*M_PI), clockwise: false)
}

private func getLinePath(startPoint: CGPoint, endPoint: CGPoint) -> UIBezierPath {
    
    let linePath = UIBezierPath()
    linePath.moveToPoint(startPoint)
    linePath.addLineToPoint(endPoint)
    
    return linePath
}
