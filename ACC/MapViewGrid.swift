//
//  MapViewGrid.swift
//  ACC
//
//  Created by Hung-Yun Liao on 7/5/16.
//  Copyright © 2016 Hung-Yun Liao. All rights reserved.
//

import UIKit

class MapViewGrid: UIView {

    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        drawGrid(CGPoint(x: bounds.midX, y: bounds.midY), gridSize: CGFloat(10))
    }
    
    private func getLinePath(startPoint: CGPoint, endPoint: CGPoint) -> UIBezierPath {
        
        let linePath = UIBezierPath()
        linePath.moveToPoint(startPoint)
        linePath.addLineToPoint(endPoint)
        
        return linePath
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
