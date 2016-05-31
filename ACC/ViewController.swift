//
//  ViewController.swift
//  ACC
//
//  Created by Hung-Yun Liao on 5/23/16.
//  Copyright © 2016 Hung-Yun Liao. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    // MARK: System parameters setup
    var accelerometerUpdateInterval: Double = 0.1
    var gyroUpdateInterval: Double = 0.1
    var calibrationTimeAssigned: Int = 100
    var numberOfPointsForCalibration: Int = 3
    var zeroVelocityThreshold: Double = 10.0 // the higher, the longer the system takes setting the V to 0 while acc and w are 0.
    
    // MARK: Instance variables
    var currentMaxAccelXNegative: Double = 0.0
    var currentMaxAccelXPositive: Double = 0.0
    var currentMaxAccelY: Double = 0.0
    var currentMaxAccelZ: Double = 0.0
    var currentMaxRotX: Double = 0.0
    var currentMaxRotY: Double = 0.0
    var currentMaxRotZ: Double = 0.0
    var motionManager = CMMotionManager()
    
    var accSys: System = System()
    var gyroSys: System = System()
    var staticStateJudgeTimer = (a: 0.0, w: 0.0)
    
    // MARK: Kalman Filter
    var kalmanX: KalmanFilter = KalmanFilter()
    var kalmanY: KalmanFilter = KalmanFilter()
    var kalmanZ: KalmanFilter = KalmanFilter()
    var x: [Double] = [1, 2, 3]
    var y: [Double] = [1, 2, 3]
    var linearCoef = (slope: 0.0, intercept: 0.0)

    var STDEV = [Double]()
    
    // MARK: Outlets
    @IBOutlet var accX: UILabel?
    @IBOutlet var accY: UILabel?
    @IBOutlet var accZ: UILabel?
    @IBOutlet var maxAccXNegative: UILabel?
    @IBOutlet var maxAccXPositive: UILabel?
    @IBOutlet var velY: UILabel?
    @IBOutlet var velZ: UILabel?
    @IBOutlet var rotX: UILabel?
    @IBOutlet var rotY: UILabel?
    @IBOutlet var rotZ: UILabel?
    @IBOutlet var maxRotX: UILabel?
    @IBOutlet var maxRotY: UILabel?
    @IBOutlet var maxRotZ: UILabel?
    
    @IBOutlet var velX: UILabel?
    @IBOutlet var disX: UILabel?
    @IBOutlet var info: UILabel?
    
    // MARK: Functions
    @IBAction func reset() {
        
        currentMaxAccelXNegative = 0.0
        currentMaxAccelXPositive = 0.0
        currentMaxAccelY = 0.0
        currentMaxAccelZ = 0.0
        currentMaxRotX = 0.0
        currentMaxRotY = 0.0
        currentMaxRotZ = 0.0
        
        accSys.reset()
        
        gyroSys.reset()
        
    }
    
    override func viewDidLoad() {
        
        self.reset()
        
        // Set Motion Manager Properties
        motionManager.accelerometerUpdateInterval = accelerometerUpdateInterval
        motionManager.gyroUpdateInterval = gyroUpdateInterval
        
        // Recording data
        motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: { (accelerometerData: CMAccelerometerData?, NSError) -> Void in
            self.outputAccData(accelerometerData!.acceleration)
            if NSError != nil {
                print("\(NSError)")
            }
        })
        
        motionManager.startGyroUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: { (gyroData: CMGyroData?, NSError) -> Void in
            self.outputRotData(gyroData!.rotationRate)
            if NSError != nil {
                print("\(NSError)")
            }
        })
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func outputAccData(acceleration: CMAcceleration){
        
        if !accSys.isCalibrated {
            
            info?.text = "Calibrating..."
            
            if accSys.calibrationTimesRemained < calibrationTimeAssigned {
                accSys.avg.x += acceleration.x
                accSys.avg.y += acceleration.y
                accSys.avg.z += acceleration.z
                accSys.calibrationTimesRemained += 1
            } else {
                accSys.avg.x /= Double(calibrationTimeAssigned)
                accSys.avg.y /= Double(calibrationTimeAssigned)
                accSys.avg.z /= Double(calibrationTimeAssigned)
                accSys.isCalibrated = true
            }
            
        } else {
            
            info?.text = "Detecting..."
            
            /* KalmanFilter begins */
            linearCoef = SimpleLinearRegression(x, y: y)
            
            accSys.kValue.x = kalmanX.Update(acceleration.x)
            accSys.output.x = linearCoef.intercept + linearCoef.slope*accSys.kValue.x - accSys.avg.x
            accX?.text = "\(accSys.output.x)"
            
            accSys.kValue.y = kalmanY.Update(acceleration.y)
            accSys.output.y = linearCoef.intercept + linearCoef.slope*accSys.kValue.y - accSys.avg.y
            accY?.text = "\(accSys.output.y)"
            
            accSys.kValue.z = kalmanZ.Update(acceleration.z)
            accSys.output.z = linearCoef.intercept + linearCoef.slope*accSys.kValue.z - accSys.avg.z
            accZ?.text = "\(accSys.output.z)"
            /* KalmanFilter ends */
            
            /* Note1 */
            
            if fabs(accSys.output.x) >= 0.1 {
                accSys.velocity.x += accSys.output.x * 9.81 * motionManager.accelerometerUpdateInterval
            }
            if fabs(accSys.output.y) >= 0.1 {
                accSys.velocity.y += accSys.output.y * 9.81 * motionManager.accelerometerUpdateInterval
            }
            if fabs(accSys.output.z) >= 0.1 {
                accSys.velocity.z += accSys.output.z * 9.81 * motionManager.accelerometerUpdateInterval
            }
            
            velX?.text = "\(accSys.velocity.x)"
            velY?.text = "\(accSys.velocity.y)"
            velZ?.text = "\(accSys.velocity.z)"
            
            if fabs(accSys.output.x) < 0.1 && fabs(accSys.output.y) < 0.1 && fabs(accSys.output.z) < 0.1 { // 0.1 is regarded as the "static state" for acc
                staticStateJudgeTimer.a += 1
                if staticStateJudgeTimer.a >= zeroVelocityThreshold && staticStateJudgeTimer.w >= zeroVelocityThreshold {
                    if accSys.velocity.x != 0 {
                        accSys.velocity.x /= 2
                        if fabs(accSys.velocity.x) < 0.0001 {
                            accSys.velocity.x = 0
                        }
                    }
                    if accSys.velocity.y != 0 {
                        accSys.velocity.y /= 2
                        if fabs(accSys.velocity.y) < 0.0001 {
                            accSys.velocity.y = 0
                        }
                    }
                    if accSys.velocity.z != 0 {
                        accSys.velocity.z /= 2
                        if fabs(accSys.velocity.z) < 0.0001 {
                            accSys.velocity.z = 0
                        }
                    }
                }
            } else {
                staticStateJudgeTimer.a = 0.0
            }
            
            accSys.distance.x += accSys.velocity.x * motionManager.accelerometerUpdateInterval
            disX?.text = "\(accSys.distance.x)"
            
            accSys.distance.y += accSys.velocity.y * motionManager.accelerometerUpdateInterval
            
            accSys.distance.z += accSys.velocity.z * motionManager.accelerometerUpdateInterval
        }
    }
    
    func outputRotData(rotation: CMRotationRate){
        
        
        if !gyroSys.isCalibrated {
            
            if gyroSys.calibrationTimesRemained < calibrationTimeAssigned {
                gyroSys.avg.x += rotation.x
                gyroSys.avg.y += rotation.y
                gyroSys.avg.z += rotation.z
                gyroSys.calibrationTimesRemained += 1
            } else {
                gyroSys.avg.x /= Double(calibrationTimeAssigned)
                gyroSys.avg.y /= Double(calibrationTimeAssigned)
                gyroSys.avg.z /= Double(calibrationTimeAssigned)
                gyroSys.isCalibrated = true
            }
            
        } else {
            
            gyroSys.output.x = rotation.x - gyroSys.avg.x
            gyroSys.output.y = rotation.y - gyroSys.avg.y
            gyroSys.output.z = rotation.z - gyroSys.avg.z
        
            rotX?.text = "\(gyroSys.output.x)"
            rotY?.text = "\(gyroSys.output.y)"
            rotZ?.text = "\(gyroSys.output.z)"
            
            if gyroSys.output.x < 0.01 && gyroSys.output.y < 0.01 && gyroSys.output.z < 0.01 {  // 0.01 is regarded as "static state" for angle acc
                staticStateJudgeTimer.w += 1
            } else {
                staticStateJudgeTimer.w = 0.0
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

/* Note1 */
//            /* STDEV: used to compare the filter effect (KalmanFilter, 3-point filter, non) */
//            if STDEV.count < 100 {
//                STDEV.append(outputX - avg)
//            } else {
//                accX?.text = "\(standardDeviation(STDEV))"
//            }
//            /* End of STDEV */
/* KalmanFilter ends */

//            /* 3-point Filter begins */
//            if calibrationPointsRemained != 0 {
//                accCaliSumX += acceleration.x
//                calibrationPointsRemained -= 1
//            } else {
//                accCaliSumX /= Double(numberOfPointsForCalibration)
//                /* STDEV */
//                if STDEV.count < 100 {
//                    STDEV.append(accCaliSumX - avg)
//                } else {
//                    accX?.text = "\(standardDeviation(STDEV))"
//                }
//                /* End of STDEV */
//                accX?.text = "\(accCaliSumX - avg)"
//                if acceleration.x > currentMaxAccelXPositive {
//                    currentMaxAccelXPositive = acceleration.x
//                }
//
//                if acceleration.x < currentMaxAccelXNegative { // negative
//                    currentMaxAccelXNegative = acceleration.x
//                }
//                accCaliSumX = 0.0
//                calibrationPointsRemained = numberOfPointsForCalibration
//            }
//            /* 3-point Filter ends */

