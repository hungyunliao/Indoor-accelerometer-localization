//
//  KalmanFilter.swift
//  ACC
//
//  Created by Hung-Yun Liao on 5/27/16.
//  Copyright © 2016 Hung-Yun Liao. All rights reserved.
//

import Foundation


// MARK: operator define
infix operator ^ {}
func ^ (radix: Double, power: Double) -> Double {
    return pow(radix, power)
}

/*
    Initializating Kalman object in C:
        KalmanFilter kalman(15, 50)
        Double x[3] = {1, 2, 3}
        Double y[3] = {1, 2, 3}
        Double lrCoef[2] = {0, 0}
*/

struct System {
    var isCalibrated = true
    var calibrationTimesDone = 0
    var staticStateJudgeTimer = 0.0
    var threePtFilterPointsDone = 0
    
    var base = ThreeAxesSystemDouble()
    var accelerate = ThreeAxesSystemDouble()
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
}

struct ThreeAxesSystemKalman {
    var x: KalmanFilter = KalmanFilter()
    var y: KalmanFilter = KalmanFilter()
    var z: KalmanFilter = KalmanFilter()
}

class KalmanFilter {
    
    private var k: Double = 0.0 // Kalman gain
    private var p: Double = 0.0 // estimation error cvariance
    private var q: Double = 1.0 // process(predict) noise cvariance
    private var r: Double = 0.0 // measurement noise covariance
    private var x: Double = 0.0 // value
    
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

func choldc1(var a: [Double], var p: [Double], n: Int) -> Int {
    var i, j, k: Int
    var sum: Double
    
    for (i = 0; i < n; i++) {
        for (j = i; j < n; j++) {
            sum = a[i*n+j];
            for (k = i - 1; k >= 0; k--) {
                sum -= a[i*n+k] * a[j*n+k]
            }
            if (i == j) {
                if (sum <= 0) {
                    return 1 /* error */
                }
                p[i] = sqrt(sum);
            }
            else {
                a[j*n+i] = sum / p[i];
            }
        }
    }
    
    return 0; /* success */
}

func choldcsl(var A: [Double], var a: [Double], var p: [Double], n: Int) -> Int {
    var i, j, k: Int
    var sum: Double
    
    for (i = 0; i < n; i++) {
        for (j = 0; j < n; j++) {
            a[i*n+j] = A[i*n+j]
        }
    }
    /*
    if (choldc1(a, p, n)) {
        return 1
    }
 */
    for (i = 0; i < n; i++) {
        a[i*n+i] = 1 / p[i];
        for (j = i + 1; j < n; j++) {
            sum = 0;
            for (k = i; k < j; k++) {
                sum -= a[j*n+k] * a[k*n+i];
            }
            a[j*n+i] = sum / p[j];
        }
    }
    return 0; /* success */
}

func cholsl(var A: [Double], var a: [Double], var p: [Double], n: Int) -> Int {
    var i, j, k: Int
    /*
    if (choldcsl(A,a,p,n)) {
        return 1
    }
 */
    for (i = 0; i < n; i++) {
        for (j = i + 1; j < n; j++) {
            a[i*n+j] = 0.0;
        }
    }
    for (i = 0; i < n; i++) {
        a[i*n+i] *= a[i*n+i];
        for (k = i + 1; k < n; k++) {
            a[i*n+i] += a[k*n+i] * a[k*n+i];
        }
        for (j = i + 1; j < n; j++) {
            for (k = j; k < n; k++) {
                a[i*n+j] += a[k*n+i] * a[k*n+j];
            }
        }
    }
    for (i = 0; i < n; i++) {
        for (j = 0; j < i; j++) {
            a[i*n+j] = a[j*n+i];
        }
    }
    return 0; /* success */
}

func zeros(var a: [Double], m: Int, n: Int) {
    var j: Int
    
    for (j=0; j<m*n; ++j) {
        a[j] = 0
    }
}

/* C <- A * B */
func mulmat(var a: [Double], var b: [Double], var c: [Double], arows: Int, acols: Int, bcols: Int) {
    var i, j, l: Int
    
    for(i=0; i<arows; ++i) {
        for(j=0; j<bcols; ++j) {
            c[i*bcols+j] = 0;
            for(l=0; l<acols; ++l) {
                c[i*bcols+j] += a[i*acols+l] * b[l*bcols+j]
            }
        }
    }
}

func mulvec(var a: [Double], var x: [Double], var y: [Double], m: Int, n: Int) {
    var i, j: Int
    
    for(i=0; i<m; ++i) {
        y[i] = 0;
        for(j=0; j<n; ++j){
            y[i] += x[j] * a[i*n+j]
        }
    }
}

func transpose(var a: [Double], var at: [Double], m: Int, n: Int) {
    var i, j: Int
    
    for(i=0; i<m; ++i) {
        for(j=0; j<n; ++j) {
            at[j*m+i] = a[i*n+j];
        }
    }
}

/* A <- A + B */
func accum(var a: [Double], var b: [Double], m: Int, n: Int) {
    var i, j: Int
    
    for(i=0; i<m; ++i) {
        for(j=0; j<n; ++j) {
            a[i*n+j] += b[i*n+j]
        }
    }
}

/* C <- A + B */
func add(var a: [Double], var b: [Double], var c: [Double], n: Int) {
    var j: Int
    
    for(j=0; j<n; ++j) {
        c[j] = a[j] + b[j]
    }
}


/* C <- A - B */
func sub(var a: [Double], var b: [Double], var c: [Double], n: Int) {
    var j: Int
    
    for(j=0; j<n; ++j) {
        c[j] = a[j] - b[j]
    }
}

func negate(var a: [Double], m: Int, n: Int) {
    var i, j: Int
    
    for(i=0; i<m; ++i) {
        for(j=0; j<n; ++j) {
            a[i*n+j] = -a[i*n+j]
        }
    }
}

func mat_addeye(var a: [Double], n: Int) {
    var i: Int
    
    for (i=0; i<n; ++i) {
        a[i*n+i] += 1
    }
}

struct ekf_t{
    
    var x: [Double]    /* state vector */
    
    var P: [Double]  /* prediction error covariance */
    var Q: [Double]  /* process noise covariance */
    var R: [Double]  /* measurement error covariance */
    
    var G: [Double]  /* Kalman gain; a.k.a. K */
    
    var F: [Double]  /* Jacobian of process model */
    var H: [Double]  /* Jacobian of measurement model */
    
    var Ht: [Double] /* transpose of measurement Jacobian */
    var Ft: [Double] /* transpose of process Jacobian */
    var Pp: [Double] /* P, post-prediction, pre-update */
    
    var fx: [Double]  /* output of user defined f() state-transition function */
    var hx: [Double]  /* output of user defined h() measurement function */
    
    /* temporary storage */
    var temp1: [Double]
    var temp2: [Double]
    var temp3: [Double]
    var temp4: [Double]
    var temp5: [Double]
    
}
