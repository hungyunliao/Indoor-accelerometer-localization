//
//  KalmanFilter.swift
//  ACC
//
//  Created by Hung-Yun Liao on 5/27/16.
//  Copyright © 2016 Hung-Yun Liao. All rights reserved.
//

import Foundation

/*
    Initializating Kalman object in C:
        KalmanFilter kalman(15, 50)
        Double x[3] = {1, 2, 3}
        Double y[3] = {1, 2, 3}
        Double lrCoef[2] = {0, 0}
*/

class KalmanFilter {
    
    private var k: Double = 0.0 // Kalman gain
    private var p: Double = 0.0 // estimation error cvariance
    private var q: Double = 15 // process noise cvariance
    private var r: Double = 50 // measurement noise covariance
    private var x: Double = 0.0 // value
    
    func Update(value: Double) -> Double {
        p = sqrt(q * q + r * r)
        p += q
        k = p / (p + r)
        x += k * (value - x)
        p *= (1 - k)
        
        return x
    }
    
    func GetK() -> Double {
        return k
    }
}

func SimpleLinearRegression (x: [Double], y: [Double]) -> (Double, Double) {
    
    // x and y should be arrays of points. 
    
    var xbar: Double = 0.0
    var ybar: Double = 0.0
    var xybar: Double = 0.0
    var xsqbar: Double = 0.0
    let arrayLength: Int = x.count
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


