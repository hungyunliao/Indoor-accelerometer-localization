//
//  KalmanFilter.swift
//  ACC
//
//  Created by Hung-Yun Liao on 5/27/16.
//  Copyright © 2016 Hung-Yun Liao. All rights reserved.
//

import Foundation
import CoreMotion

// MARK: operator define
infix operator ^ {}
func ^ (radix: Double, power: Double) -> Double {
    return pow(radix, power)
}

struct System {
    var isCalibrated = true
    var calibrationTimesDone = 0
    var staticStateJudgeTimer = 0.0
    var threePtFilterPointsDone = 1
    
    var base = ThreeAxesSystemDouble()
    var accelerate = ThreeAxesSystemDouble()
    var kValue = ThreeAxesSystemDouble()
    var velocity = ThreeAxesSystemDouble()
    var distance = ThreeAxesSystemDouble()
    var rotation = ThreeAxesSystemDouble()
    
    var kalman = ThreeAxesSystemKalman()
    
    mutating func reset() {
        isCalibrated = true
        calibrationTimesDone = 0
        staticStateJudgeTimer = 0.0
        threePtFilterPointsDone = 0
        
        base.x = 0.0
        base.y = 0.0
        base.z = 0.0
        
        accelerate.x = 0.0
        accelerate.y = 0.0
        accelerate.z = 0.0
        
        kValue.x = 0.0
        kValue.y = 0.0
        kValue.z = 0.0
        
        velocity.x = 0.0
        velocity.y = 0.0
        velocity.z = 0.0
        
        distance.x = 0.0
        distance.y = 0.0
        distance.z = 0.0
    }
}

struct ThreeAxesSystemDouble {
    var x = 0.0
    var y = 0.0
    var z = 0.0
    var roll = 0.0
    var pitch = 0.0
    var yaw = 0.0
}

struct ThreeAxesSystem<Element> {
    var x: Element
    var y: Element
    var z: Element
}

struct ThreeAxesSystemKalman {
    var x: KalmanFilter = KalmanFilter()
    var y: KalmanFilter = KalmanFilter()
    var z: KalmanFilter = KalmanFilter()
}

class KalmanFilter : Filter {
    
    private var k: Double = 0.0 // Kalman gain
    private var p: Double = 0.0 // estimation error cvariance
    private var q: Double = 1.0 // process(predict) noise cvariance
    private var r: Double = 0.0 // measurement noise covariance
    private var x: Double = 0.0 // value
    
    func filter<T>(x: T, y: T, z: T) -> (T, T, T) {
        return (x, y, z)
    }
    
    func initFilter(deviceMotionUpdateInterval: Double) {
        var X = Matrix(rows: 9, columns: 1)
        X[0,0] = 0.0
        X[1,0] = 0.0
        X[2,0] = 0.0
        X[3,0] = 0.0
        X[4,0] = 0.0
        X[5,0] = 0.0
        X[6,0] = 0.0
        X[7,0] = 0.0
        X[8,0] = 0.0
        
        var F = Matrix(rows: 9, columns: 9)
        F[0,0] = 1.0
        F[1,1] = 1.0
        F[2,2] = 1.0
        F[0,3] = 1.0
        F[1,4] = 1.0
        F[2,5] = 1.0
        F[0,6] = 1/2*deviceMotionUpdateInterval^2
        F[1,7] = 1/2*deviceMotionUpdateInterval^2
        F[2,8] = 1/2*deviceMotionUpdateInterval^2
        F[3,3] = 1.0
        F[4,4] = 1.0
        F[5,5] = 1.0
        F[3,6] = deviceMotionUpdateInterval
        F[4,7] = deviceMotionUpdateInterval
        F[5,8] = deviceMotionUpdateInterval
        F[6,6] = 1.0
        F[7,7] = 1.0
        F[8,8] = 1.0
        
        var H = Matrix(rows: 3, columns: 9)
        H[0,0] = 1.0
        H[1,1] = 1.0
        H[2,2] = 1.0
    }
    
    /*
     for y in 0..<F.columns {
     for x in 0..<F.rows {
     print(String(F[x,y]))
     }
     print("")
     }
     */
    
    func Update(value: Double) -> Double {
        p = sqrt(q * q + r * r) //?
        p += q
        k = p / (p + r)
        x += k * (value - x)
        p *= (1 - k)
        
        return x
    }
    
    func GetK() -> Double {
        return k
    }
    
    func SetR(value: Double) {
        r = value
    }
}

func SimpleLinearRegression (x: [Double], y: [Double]) -> (Double, Double) {
    
    // x and y should be arrays of points. 
    
    var xbar = 0.0
    var ybar = 0.0
    var xybar = 0.0
    var xsqbar = 0.0
    let arrayLength = x.count
    var linearCoef = (slope: 0.0, intercept: 0.0)
    
    for i in 0..<arrayLength {
        xbar += x[i]
        ybar += y[i]
        xybar += x[i] * y[i]
        xsqbar += x[i] * x[i]
    }
    
    xbar /= Double(arrayLength)
    ybar /= Double(arrayLength)
    xybar /= Double(arrayLength)
    xsqbar /= Double(arrayLength)
    
    linearCoef.slope = (xybar - xbar*ybar) / (xsqbar - xbar*xbar)
    linearCoef.intercept = ybar - linearCoef.slope*xbar
    
    return linearCoef
}

// this STDEV function is from github: https://gist.github.com/jonelf/9ae2a2133e21e255e692
func standardDeviation(arr : [Double]) -> Double
{
    let length = Double(arr.count)
    let avg = arr.reduce(0, combine: {$0 + $1}) / length
    let sumOfSquaredAvgDiff = arr.map { pow($0 - avg, 2.0)}.reduce(0, combine: {$0 + $1})
    return sqrt(sumOfSquaredAvgDiff / length)
}

func modulus(x: Double, y: Double, z: Double) -> Double {
    return sqrt((x ^ 2) + (y ^ 2) + (z ^ 2))
}

func modulusDifference(arr: [Double], avgModulus: Double) -> Double {
    var sum = 0.0
    for i in 0..<arr.count {
        sum += ((arr[i] - avgModulus) ^ 2)
    }
    return sum / Double(arr.count)
}

func roundNum(number: Double) -> Double {
    return round(number * 10000) / 10000
}
