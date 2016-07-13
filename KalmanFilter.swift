//
//  KalmanFilter.swift
//  ACC
//
//  Created by Hung-Yun Liao on 5/27/16.
//  Copyright © 2016 Hung-Yun Liao. All rights reserved.
//

import Foundation
import CoreMotion

struct System {
    var isCalibrated = true
    var calibrationTimesDone = 0
    var staticStateJudgeTimer = 0.0
    var threePtFilterPointsDone = 1
    
    var base = ThreeAxesSystemDouble()
    var output = ThreeAxesSystemDouble()
    var kValue = ThreeAxesSystemDouble()
    var velocity = ThreeAxesSystemDouble()
    var distance = ThreeAxesSystemDouble()
    
    var kalman = ThreeAxesSystemKalman()
    
    mutating func reset() {
        isCalibrated = true
        calibrationTimesDone = 0
        staticStateJudgeTimer = 0.0
        threePtFilterPointsDone = 0
        
        base.x = 0.0
        base.y = 0.0
        base.z = 0.0
        
        output.x = 0.0
        output.y = 0.0
        output.z = 0.0
        
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