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
    
    // MARK: test param
    var test = 0
    var sum = 0.0
    
    // MARK: System parameters setup
    var accelerometerUpdateInterval: Double = 0.1
    var gyroUpdateInterval: Double = 0.1
    var calibrationTimeAssigned: Int = 100
    var staticStateJudgeThreshold = (acc: 0.1, gyro: 0.1, timer: 5.0)
    
    let gravityConstant = 9.80665
    
    var staticStateJudge = (modulAcc: false, modulGyro: false, modulDiffAcc: false) // 1: static 0: dynamic
    var arrayForStatic = [Double](count: 7, repeatedValue: -1)
    var index = 0
    var modulusDiff = 0.0
    
    let publicDB = NSUserDefaults.standardUserDefaults()
    
    // MARK: Instance variables
    var motionManager = CMMotionManager()
    var accModulusAvg = 0.0
    var accSys: System = System()
    var gyroSys: System = System()
    
    // MARK: Kalman Filter
    var arrayOfPoints: [Double] = [1, 2, 3]
    var linearCoef = (slope: 0.0, intercept: 0.0)
    
    var STDEV = [Double]()
    
    // MARK: Three-Point Filter
    let numberOfPointsForThreePtFilter = 3
    var threePtFilterPointsRemained = 0
    
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
            
            if accSys.calibrationTimesDone < calibrationTimeAssigned {
                accSys.base.x += acceleration.x
                accSys.base.y += acceleration.y
                accSys.base.z += acceleration.z + 1 // MARK: should change
                accSys.calibrationTimesDone += 1
            } else {
                accSys.base.x /= Double(calibrationTimeAssigned)
                accSys.base.y /= Double(calibrationTimeAssigned)
                accSys.base.z /= Double(calibrationTimeAssigned)
                accSys.isCalibrated = true
            }
            
        } else {
            
            //info?.text = "Detecting..."
            
            /* Note 3 */
            
            /* 3-point Filter begins */
            if threePtFilterPointsRemained != 0 {
                accSys.output.x += acceleration.x
                accSys.output.y += acceleration.y
                accSys.output.z += acceleration.z
                threePtFilterPointsRemained -= 1
            } else {
                
                
                accSys.output.x = (accSys.output.x/Double(numberOfPointsForThreePtFilter)) - accSys.base.x
                accSys.output.y = (accSys.output.y/Double(numberOfPointsForThreePtFilter)) - accSys.base.y
                accSys.output.z = (accSys.output.z/Double(numberOfPointsForThreePtFilter)) - accSys.base.z
                
                accX?.text = "\(acceleration.z)"
                accY?.text = "\(accSys.base.z)"
                accZ?.text = "\(accSys.output.z)"
                
                threePtFilterPointsRemained = numberOfPointsForThreePtFilter
                
                /* 3-point Filter ends */
                /* Note1 */
                
                /* Note2-1 */
                
                if index == arrayForStatic.count {
                    for i in 0..<(arrayForStatic.count - 1) {
                        arrayForStatic[i] = arrayForStatic[i + 1]
                    }
                    arrayForStatic[index - 1] = modulus(acceleration.x, y: acceleration.y, z: acceleration.z)
                    accModulusAvg += arrayForStatic[3]
                    accModulusAvg /= 2
                    modulusDiff = modulusDifference(arrayForStatic, avgModulus: accModulusAvg)
                } else {
                    arrayForStatic[index] = modulus(acceleration.x, y: acceleration.y, z: acceleration.z)
                    index += 1
                    if index == arrayForStatic.count {
                        for i in 0...((arrayForStatic.count - 1)/2) {
                            accModulusAvg += arrayForStatic[i]
                        }
                        accModulusAvg /= Double((arrayForStatic.count - 1)/2 + 1)
                        modulusDiff = modulusDifference(arrayForStatic, avgModulus: accModulusAvg)
                    }
                }
                
                // Static Judgement Condition 1
                if fabs(modulusDiff) < 0.1 {
                    staticStateJudge.modulDiffAcc = true
                } else {
                    staticStateJudge.modulDiffAcc = false
                }
                
                // Static Judgement Condition 2
                if fabs(modulus(acceleration.x, y: acceleration.y, z: acceleration.z) - 1) < (1/gravityConstant) {
                    staticStateJudge.modulAcc = true
                } else {
                    staticStateJudge.modulAcc = false
                }
                
                // Static Judgement Condition 1 && 2 && 3
                if staticStateJudge.modulAcc && staticStateJudge.modulGyro && staticStateJudge.modulDiffAcc { // when all of the three indicators (modulAcc, modulGyro, modulDiffAcc) are true
                    info?.text = "static state"
                    accSys.velocity.x = 0
                    accSys.velocity.y = 0
                    accSys.velocity.z = 0
                } else {
                    // if the device is moving (in dynamic state), meaning the position is changing, so the position needs to be updated, otherwise, the position need not be updated to save the resources.
                    info?.text = "dynamic state"
                    
                    // save the changed position to the PUBLIC NSUserdefault object so that they can be accessed by other VIEW
                    publicDB.setValue(accSys.distance.x, forKey: "x")
                    publicDB.setValue(accSys.distance.y, forKey: "y")
                    // post the notification to the NotificationCenter to notify everyone who is in the observer list.
                    NSNotificationCenter.defaultCenter().postNotificationName("PositionChanged", object: nil)
                }
                
                
                // Velocity Calculation
                if fabs(accSys.output.x) >= 0.1 {
                    accSys.velocity.x += roundNum(accSys.output.x * gravityConstant * motionManager.accelerometerUpdateInterval)
                }
                velX?.text = "\(accSys.velocity.x)"
                
                if fabs(accSys.output.y) >= 0.1 {
                    accSys.velocity.y += roundNum(accSys.output.y * gravityConstant * motionManager.accelerometerUpdateInterval)
                }
                velY?.text = "\(accSys.velocity.y)"
                
                if (fabs(accSys.output.z) - 1) >= 0.1 {
                    accSys.velocity.z += roundNum(accSys.output.z * gravityConstant * motionManager.accelerometerUpdateInterval)
                }
                velZ?.text = "\(accSys.velocity.z)"
                
                // Distance Calculation
                accSys.distance.x += roundNum(accSys.velocity.x * motionManager.accelerometerUpdateInterval)
                disX?.text = "\(accSys.distance.x)"
                
                accSys.distance.y += roundNum(accSys.velocity.y * motionManager.accelerometerUpdateInterval)
                disY?.text = "\(accSys.distance.y)"
                
                accSys.distance.z += roundNum(accSys.velocity.z * motionManager.accelerometerUpdateInterval)
                disZ?.text = "\(accSys.distance.z)"
                
                // clear the stored value for the next round of 3-point avg computation
                accSys.output.x = 0
                accSys.output.y = 0
                accSys.output.z = 0
            }
        }
    }
    
    func outputRotData(rotation: CMRotationRate) {
        
        if !gyroSys.isCalibrated {
            
            if gyroSys.calibrationTimesDone < calibrationTimeAssigned {
                gyroSys.base.x += rotation.x
                gyroSys.base.y += rotation.y
                gyroSys.base.z += rotation.z
                gyroSys.calibrationTimesDone += 1
            } else {
                gyroSys.base.x /= Double(calibrationTimeAssigned)
                gyroSys.base.y /= Double(calibrationTimeAssigned)
                gyroSys.base.z /= Double(calibrationTimeAssigned)
                gyroSys.isCalibrated = true
            }
            
        } else {
            
            gyroSys.kValue.x = gyroSys.kalman.x.Update(rotation.x)
            gyroSys.output.x = roundNum(linearCoef.intercept + linearCoef.slope*gyroSys.kValue.x - gyroSys.base.x)
            rotX?.text = "\(gyroSys.output.x)"
            
            gyroSys.kValue.y = gyroSys.kalman.y.Update(rotation.y)
            gyroSys.output.y = roundNum(linearCoef.intercept + linearCoef.slope*gyroSys.kValue.y - gyroSys.base.y)
            rotY?.text = "\(gyroSys.output.y)"
            
            gyroSys.kValue.z = gyroSys.kalman.z.Update(rotation.z)
            gyroSys.output.z = roundNum(linearCoef.intercept + linearCoef.slope*gyroSys.kValue.z - gyroSys.base.z)
            rotZ?.text = "\(gyroSys.output.z)"
            
            // gyro is the angular speed, not the angular acceleration
            if fabs(gyroSys.output.x) >= 0.1 {
                gyroSys.distance.x += roundNum(gyroSys.output.x * motionManager.gyroUpdateInterval)
            }
            velXGyro?.text = "\(gyroSys.distance.x)"
            
            if fabs(gyroSys.output.y) >= 0.1 {
                gyroSys.distance.y += roundNum(gyroSys.output.y * motionManager.gyroUpdateInterval)
            }
            velYGyro?.text = "\(gyroSys.distance.y)"
            
            if fabs(gyroSys.output.z) >= 0.1 {
                gyroSys.distance.z += roundNum(gyroSys.output.z * motionManager.gyroUpdateInterval)
            }
            //velZGyro?.text = "\(gyroSys.distance.z)"
            
            /* Note2-2 */
            
            // Static Judgement Condition 3
            velZGyro?.text = "\(modulus(gyroSys.output.x, y: gyroSys.output.y, z: gyroSys.output.z))"
            if modulus(gyroSys.output.x, y: gyroSys.output.y, z: gyroSys.output.z) < 0.1 {
                staticStateJudge.modulGyro = true
            } else {
                staticStateJudge.modulGyro = false
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


/* Note2-1 */
//            if (fabs(accSys.output.x) < staticStateJudgeThreshold.acc &&
//                fabs(accSys.output.y) < staticStateJudgeThreshold.acc &&
//                fabs(accSys.output.z + 1) < staticStateJudgeThreshold.acc) {
//                accSys.staticStateJudgeTimer += 1
//
//                if (accSys.staticStateJudgeTimer >= staticStateJudgeThreshold.timer && gyroSys.staticStateJudgeTimer >= staticStateJudgeThreshold.timer) {
//                    if accSys.velocity.x != 0 {
////                        accSys.velocity.x /= 2
////                        if fabs(accSys.velocity.x) < 0.0001 {
//                            accSys.velocity.x = 0
////                        }
//                    }
//                    if accSys.velocity.y != 0 {
////                        accSys.velocity.y /= 2
////                        if fabs(accSys.velocity.y) < 0.0001 {
//                            accSys.velocity.y = 0
////                        }
//                    }
//                    if accSys.velocity.z != 0 {
////                        accSys.velocity.z /= 2
////                        if fabs(accSys.velocity.z) < 0.0001 {
//                            accSys.velocity.z = 0
////                        }
//                    }
//                }
//            } else {
//                accSys.staticStateJudgeTimer = 0.0
//            }

/* Note2-2 */
//            if (gyroSys.output.x < staticStateJudgeThreshold.gyro &&
//                gyroSys.output.y < staticStateJudgeThreshold.gyro &&
//                gyroSys.output.z < staticStateJudgeThreshold.gyro) {
//                gyroSys.staticStateJudgeTimer += 1
//            } else {
//                gyroSys.staticStateJudgeTimer = 0.0
//            }

/* Note 3 */
/* KalmanFilter begins */
//            accSys.kValue.x = accSys.kalman.x.Update(acceleration.x)
//            accSys.output.x = roundNum(linearCoef.intercept + linearCoef.slope*accSys.kValue.x - accSys.base.x)
//            accX?.text = "\(accSys.output.x)"
//
//
//
//
//            accSys.kValue.y = accSys.kalman.y.Update(acceleration.y)
//            accSys.output.y = roundNum(linearCoef.intercept + linearCoef.slope*accSys.kValue.y - accSys.base.y)
//            accY?.text = "\(accSys.output.y)"
//
//            accSys.kValue.z = accSys.kalman.z.Update(acceleration.z)
//            accSys.output.z = roundNum(linearCoef.intercept + linearCoef.slope*accSys.kValue.z - accSys.base.z)
//            accZ?.text = "\(accSys.output.z)"
/* KalmanFilter ends */
