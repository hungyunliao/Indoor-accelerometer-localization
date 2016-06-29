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


/*
 * TinyEKF: Extended Kalman Filter for embedded processors
 *
 * Copyright (C) 2015 Simon D. Levy
 *
 * This code is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This code is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with ekf-> code.  If not, see <http:#www.gnu.org/licenses/>.
 */

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

/*
#ifdef DEBUG
static void dump(double * a, int m, int n, const char * fmt)
{
    int i,j;
    
    char f[100];
    sprintf(f, "%s ", fmt);
    for(i=0; i<m; ++i) {
        for(j=0; j<n; ++j)
        printf(f, a[i*n+j]);
        printf("\n");
    }
}
#endif
*/

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

/* TinyEKF code ------------------------------------------------------------------- */

/*
#include "tiny_ekf.h"
*/

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

//static void unpack(void * v, ekf_t * ekf, int n, int m)
func unpack(var v: [Double], var ekf: ekf_t, n: Int, m: Int){
    /* skip over n, m in data structure */
    //char * cptr = (char *)v;
    var cptr: [Double] = v
    //cptr += 2*sizeof(int);
    //...
    //double * dptr = (double *)cptr;
    var dptr: [Double] = cptr
    ekf.x = dptr;
    dptr += n;
    ekf->P = dptr;
    dptr += n*n;
    ekf->Q = dptr;
    dptr += n*n;
    ekf->R = dptr;
    dptr += m*m;
    ekf->G = dptr;
    dptr += n*m;
    ekf->F = dptr;
    dptr += n*n;
    ekf->H = dptr;
    dptr += m*n;
    ekf->Ht = dptr;
    dptr += n*m;
    ekf->Ft = dptr;
    dptr += n*n;
    ekf->Pp = dptr;
    dptr += n*n;
    ekf->fx = dptr;
    dptr += n;
    ekf->hx = dptr;
    dptr += m;
    ekf->tmp1 = dptr;
    dptr += n*m;
    ekf->tmp2 = dptr;
    dptr += m*n;
    ekf->tmp3 = dptr;
    dptr += m*m;
    ekf->tmp4 = dptr;
    dptr += m*m;
    ekf->tmp5 = dptr;
}

//void ekf_init(void * v, int n, int m)
func ekf_init(v: [Double], n: Int, m: Int)
{
    /* retrieve n, m and set them in incoming data structure */
    int * ptr = (int *)v;
    *ptr = n;
    ptr++;
    *ptr = m;
    
    /* unpack rest of incoming structure for initlization */
    ekf_t ekf;
    unpack(v, &ekf, n, m);
    
    /* zero-out matrices */
    zeros(ekf.P, n, n);
    zeros(ekf.Q, n, n);
    zeros(ekf.R, m, m);
    zeros(ekf.G, n, m);
    zeros(ekf.F, n, n);
    zeros(ekf.H, m, n);
}

//int ekf_step(void * v, double * z)
func ekf_step(v: [Double], z: [Double])
{
    /* unpack incoming structure */
    
    int * ptr = (int *)v;
    int n = *ptr;
    ptr++;
    int m = *ptr;
    
    var ekf: ekf_t
    unpack(v, &ekf, n, m);
    
    /* P_k = F_{k-1} P_{k-1} F^T_{k-1} + Q_{k-1} */
    mulmat(ekf.F, ekf.P, ekf.tmp1, n, n, n);
    transpose(ekf.F, ekf.Ft, n, n);
    mulmat(ekf.tmp1, ekf.Ft, ekf.Pp, n, n, n);
    accum(ekf.Pp, ekf.Q, n, n);
    
    /* G_k = P_k H^T_k (H_k P_k H^T_k + R)^{-1} */
    transpose(ekf.H, ekf.Ht, m, n);
    mulmat(ekf.Pp, ekf.Ht, ekf.tmp1, n, n, m);
    mulmat(ekf.H, ekf.Pp, ekf.tmp2, m, n, n);
    mulmat(ekf.tmp2, ekf.Ht, ekf.tmp3, m, n, m);
    accum(ekf.tmp3, ekf.R, m, m);
    if (cholsl(ekf.tmp3, ekf.tmp4, ekf.tmp5, m)) return 1;
    mulmat(ekf.tmp1, ekf.tmp4, ekf.G, n, m, m);
    
    /* \hat{x}_k = \hat{x_k} + G_k(z_k - h(\hat{x}_k)) */
    sub(z, ekf.hx, ekf.tmp5, m);
    mulvec(ekf.G, ekf.tmp5, ekf.tmp2, n, m);
    add(ekf.fx, ekf.tmp2, ekf.x, n);
    
    /* P_k = (I - G_k H_k) P_k */
    mulmat(ekf.G, ekf.H, ekf.tmp1, n, m, n);
    negate(ekf.tmp1, n, n);
    mat_addeye(ekf.tmp1, n);
    mulmat(ekf.tmp1, ekf.Pp, ekf.P, n, n, n);
    
    /* success */
    return 0;
}


