//
//  ThreePointFilter.swift
//  ACC
//
//  Created by kai-hsiang, lien on 2016/7/11.
//  Copyright © 2016年 Hung-Yun Liao. All rights reserved.
//

import Foundation
import CoreMotion

var arrayX = [Double]()
var arrayY = [Double]()
var arrayZ = [Double]()
var threePtFilterPointsDone = 1

func ThreePointFilter(var x: Double, var y: Double, var z: Double) -> (Double, Double, Double) {
    let numberOfPointsForThreePtFilter = 3
    //var threePtFilterPointsDone = 0
    //print(threePtFilterPointsDone)
    if threePtFilterPointsDone < numberOfPointsForThreePtFilter {
        
        arrayX.append(x)
        arrayY.append(y)
        arrayZ.append(z)
        //print(arrayX[0])
        
        for i in 0..<threePtFilterPointsDone {
            //print(arrayX[i])
            x += arrayX[i]
            y += arrayY[i]
            z += arrayZ[i]
        }
        
        x = x / Double(threePtFilterPointsDone)
        y = y / Double(threePtFilterPointsDone)
        z = z / Double(threePtFilterPointsDone)
        threePtFilterPointsDone += 1
        
    } else {
        
        arrayX.append(x)
        arrayY.append(y)
        arrayZ.append(z)
        
        for i in 0..<numberOfPointsForThreePtFilter {
            x += arrayX[i]
            y += arrayY[i]
            z += arrayZ[i]
        }
        
        x = x / Double(threePtFilterPointsDone)
        y = y / Double(threePtFilterPointsDone)
        z = z / Double(threePtFilterPointsDone)
        
        arrayX.removeFirst()
        arrayY.removeFirst()
        arrayZ.removeFirst()
    }
    return (x, y, z)
}
