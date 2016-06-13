//
//  MapView.swift
//  ACC
//
//  Created by Hung-Yun Liao on 6/8/16.
//  Copyright © 2016 Hung-Yun Liao. All rights reserved.
//

import UIKit

@IBDesignable
class MapView: UIView {
    
    /* MARK: Private instances */
    // Not yet implement "Z" axis
    private var mapX = [CGFloat]() { didSet { setNeedsDisplay() } }
    private var mapY = [CGFloat]() { didSet { setNeedsDisplay() } }
    
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
    func setOrigin(x: Double, y: Double) {
        cleanMovement()
        originX = CGFloat(x)
        originY = CGFloat(y)
    }
    
    func moveXTo(position: Double) {
        mapX.append(CGFloat(position) - resetXOffset)
    }
    
    func moveYTo(position: Double) {
        mapY.append(CGFloat(position) - resetYOffset)
    }
    
    func cleanMovement() {
        resetXOffset += mapX.last!
        resetYOffset += mapY.last!
        mapX.removeAll()
        mapY.removeAll()
    }
    
    override func drawRect(rect: CGRect) {
        
        let xAxis = getLinePath(CGPoint(x: 0, y: bounds.midY), endPoint: CGPoint(x: bounds.width, y: bounds.midY))
        xAxis.stroke()
        
        let yAxis = getLinePath(CGPoint(x: bounds.midX, y: 20), endPoint: CGPoint(x: bounds.midX, y: bounds.height))
        yAxis.stroke()
        
        
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: originX, y: originY))
        
        if !mapX.isEmpty && !mapY.isEmpty {
            
            let pointArrayLength = min(mapX.count, mapY.count)
            for i in 0..<pointArrayLength {
                path.addLineToPoint(CGPoint(x: mapX[i] + bounds.midX, y: mapY[i] + bounds.midY))
            }
        }
        
        path.lineWidth = 2.0
        
        UIColor.blueColor().set()
        
        path.stroke()
        
    }
    
    private func getLinePath(startPoint: CGPoint, endPoint: CGPoint) -> UIBezierPath {
        
        let linePath = UIBezierPath()
        linePath.moveToPoint(startPoint)
        linePath.addLineToPoint(endPoint)
        linePath.lineWidth = 2.0
        UIColor.blackColor().set()
        linePath.stroke()
        
        return linePath
    }
    
}
