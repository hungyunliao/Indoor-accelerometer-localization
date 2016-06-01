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
    var staticStateJudgeThreshold = (acc: 0.1, gyro: 0.1, timer: 10.0)
    
    // MARK: Instance variables
    var currentMaxRotX: Double = 0.0
    var currentMaxRotY: Double = 0.0
    var currentMaxRotZ: Double = 0.0
    var motionManager = CMMotionManager()
    
    var accSys: System = System()
    var gyroSys: System = System()
    
    // MARK: Kalman Filter
    var arrayOfPoints: [Double] = [1, 2, 3]
    var linearCoef = (slope: 0.0, intercept: 0.0)

    var STDEV = [Double]()
    
    // MARK: Outlets
    @IBOutlet var info: UILabel?
    
    @IBOutlet var disX: UILabel?
    @IBOutlet var disY: UILabel?
    @IBOutlet var disZ: UILabel?
    
    @IBOutlet var accX: UILabel?
    @IBOutlet var accY: UILabel?
    @IBOutlet var accZ: UILabel?
    
    @IBOutlet var velX: UILabel?
    @IBOutlet var velY: UILabel?
    @IBOutlet var velZ: UILabel?
    
    @IBOutlet var rotX: UILabel?
    @IBOutlet var rotY: UILabel?
    @IBOutlet var rotZ: UILabel?
    
    @IBOutlet var velXGyro: UILabel?
    @IBOutlet var velYGyro: UILabel?
    @IBOutlet var velZGyro: UILabel?
    
    // MARK: Functions
    @IBAction func reset() {
        
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
        
        linearCoef = SimpleLinearRegression(arrayOfPoints, y: arrayOfPoints) // initializing the coef before the recording functions running
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func outputAccData(acceleration: CMAcceleration) {
        
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
            accSys.kValue.x = accSys.kalman.x.Update(acceleration.x)
            accSys.output.x = linearCoef.intercept + linearCoef.slope*accSys.kValue.x - accSys.avg.x
            accX?.text = "\(accSys.output.x)"
            
            accSys.kValue.y = accSys.kalman.y.Update(acceleration.y)
            accSys.output.y = linearCoef.intercept + linearCoef.slope*accSys.kValue.y - accSys.avg.y
            accY?.text = "\(accSys.output.y)"
            
            accSys.kValue.z = accSys.kalman.z.Update(acceleration.z)
            accSys.output.z = linearCoef.intercept + linearCoef.slope*accSys.kValue.z - accSys.avg.z
            accZ?.text = "\(accSys.output.z)"
            /* KalmanFilter ends */
            
            /* Note1 */
            
            if fabs(accSys.output.x) >= 0.1 {
                accSys.velocity.x += accSys.output.x * 9.81 * motionManager.accelerometerUpdateInterval
            }
            velX?.text = "\(accSys.velocity.x)"
            
            if fabs(accSys.output.y) >= 0.1 {
                accSys.velocity.y += accSys.output.y * 9.81 * motionManager.accelerometerUpdateInterval
            }
            velY?.text = "\(accSys.velocity.y)"
            
            if fabs(accSys.output.z) >= 0.1 {
                accSys.velocity.z += accSys.output.z * 9.81 * motionManager.accelerometerUpdateInterval
            }
            velZ?.text = "\(accSys.velocity.z)"
            
            
            if (fabs(accSys.output.x) < staticStateJudgeThreshold.acc &&
                fabs(accSys.output.y) < staticStateJudgeThreshold.acc &&
                fabs(accSys.output.z) < staticStateJudgeThreshold.acc) {
                accSys.staticStateJudgeTimer += 1
                
                if (accSys.staticStateJudgeTimer >= staticStateJudgeThreshold.timer && gyroSys.staticStateJudgeTimer >= staticStateJudgeThreshold.timer) {
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
                accSys.staticStateJudgeTimer = 0.0
            }
            
            accSys.distance.x += accSys.velocity.x * motionManager.accelerometerUpdateInterval
            disX?.text = "\(accSys.distance.x)"
            
            accSys.distance.y += accSys.velocity.y * motionManager.accelerometerUpdateInterval
            disY?.text = "\(accSys.distance.y)"
            
            accSys.distance.z += accSys.velocity.z * motionManager.accelerometerUpdateInterval
            disZ?.text = "\(accSys.distance.z)"
        }
    }
    
    func outputRotData(rotation: CMRotationRate) {
        
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
            
            gyroSys.kValue.x = gyroSys.kalman.x.Update(rotation.x)
            gyroSys.output.x = linearCoef.intercept + linearCoef.slope*gyroSys.kValue.x - gyroSys.avg.x
            
            gyroSys.kValue.y = gyroSys.kalman.y.Update(rotation.y)
            gyroSys.output.y = linearCoef.intercept + linearCoef.slope*gyroSys.kValue.y - gyroSys.avg.y
            
            gyroSys.kValue.z = gyroSys.kalman.z.Update(rotation.z)
            gyroSys.output.z = linearCoef.intercept + linearCoef.slope*gyroSys.kValue.z - gyroSys.avg.z
            
            rotX?.text = "\(gyroSys.output.x)"
            rotY?.text = "\(gyroSys.output.y)"
            rotZ?.text = "\(gyroSys.output.z)"
            
            if fabs(gyroSys.output.x) >= 0.1 {
                gyroSys.velocity.x += gyroSys.output.x * 9.81 * motionManager.gyroUpdateInterval
            }
            velXGyro?.text = "\(gyroSys.velocity.x)"
            
            if fabs(gyroSys.output.y) >= 0.1 {
                gyroSys.velocity.y += gyroSys.output.y * 9.81 * motionManager.gyroUpdateInterval
            }
            velYGyro?.text = "\(gyroSys.velocity.y)"
            
            if fabs(gyroSys.output.z) >= 0.1 {
                gyroSys.velocity.z += gyroSys.output.z * 9.81 * motionManager.gyroUpdateInterval
            }
            velZGyro?.text = "\(gyroSys.velocity.z)"
            
            
            if (gyroSys.output.x < staticStateJudgeThreshold.gyro &&
                gyroSys.output.y < staticStateJudgeThreshold.gyro &&
                gyroSys.output.z < staticStateJudgeThreshold.gyro) {
                gyroSys.staticStateJudgeTimer += 1
            } else {
                gyroSys.staticStateJudgeTimer = 0.0
            }
            
            gyroSys.distance.x += gyroSys.velocity.x * motionManager.gyroUpdateInterval
            gyroSys.distance.y += gyroSys.velocity.y * motionManager.gyroUpdateInterval
            gyroSys.distance.z += gyroSys.velocity.z * motionManager.gyroUpdateInterval
            
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

