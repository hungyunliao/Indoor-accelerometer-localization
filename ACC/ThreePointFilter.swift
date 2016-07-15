//
//  ThreePointFilter.swift
//  ACC
//
//  Created by kai-hsiang, lien on 2016/7/11.
//  Copyright © 2016年 Hung-Yun Liao. All rights reserved.
//

import Foundation
import CoreMotion

var threePtFilterPointsDone = 1
let numberOfPointsForThreePtFilter = 3

/*
protocol Type {
    
    func +(lhs: Self, rhs: Self) -> Self
    func *(lhs: Self, rhs: Self) -> Self
}

extension Int: Type {}
extension Double: Type {}
extension Float: Type {}

func add<Element : Type>(lhs: Element, rhs: Element) -> Element {
    let lhs = lhs
    let rhs = rhs
    return lhs + rhs
}
 */
var arrayX = [Double]()
var arrayY = [Double]()
var arrayZ = [Double]()
//

class ThreePointFilter : Filter{
    
    func initFilter(deviceMotionUpdateInterval: Double) {
    }

    /*
    var arrayX = [T]()
    var arrayY = [T]()
    var arrayZ = [T]()
    */
    //func filter<T>(x: T, y: T, z: T) -> (T, T, T) {
    func filter(x: Double, y: Double, z: Double) -> (Double, Double, Double) {
        var x = x, y = y, z = z
        
        //print(x.dynamicType)
        
        arrayX.append(x)
        arrayY.append(y)
        arrayZ.append(z)
        
        //print(arrayX[0])
        
        if threePtFilterPointsDone < numberOfPointsForThreePtFilter {
            
            threePtFilterPointsDone += 1
            
        } else {
            
            for i in 0..<numberOfPointsForThreePtFilter {
                
                x = x + arrayX[i]
                y = y + arrayY[i]
                z = z + arrayZ[i]
 
                //print(add(2.562, rhs: 3.8))
                //print(add(x, rhs: arrayX[i]))
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

}