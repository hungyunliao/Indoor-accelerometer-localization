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
        setNeedsDisplay()
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
        setNeedsDisplay()
    }
    
    func movePointTo(x: Double, y: Double) {
        
        previousPoint.x = currentPoint.x
        previousPoint.y = currentPoint.y
        
        currentPoint.x = CGFloat(x)*accumulatedScale - resetOffset.x
        currentPoint.y = CGFloat(y)*accumulatedScale - resetOffset.y
        
        pathPoints.append(ThreeAxesSystem<CGFloat>(x: currentPoint.x, y: currentPoint.y, z: 0)) // z has not yet been implemented
        setNeedsDisplay()
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
        setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        
        
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
        
        UIColor.cyanColor().set()
        routePath.stroke()
        UIColor.blackColor().set()
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

func getCircle(atCenter center: CGPoint, radius: CGFloat) -> UIBezierPath {
    return UIBezierPath(arcCenter: center, radius: radius, startAngle: 0.0, endAngle: CGFloat(2*M_PI), clockwise: false)
}

func getLinePath(startPoint: CGPoint, endPoint: CGPoint) -> UIBezierPath {
    
    let linePath = UIBezierPath()
    linePath.moveToPoint(startPoint)
    linePath.addLineToPoint(endPoint)
    
    return linePath
}
