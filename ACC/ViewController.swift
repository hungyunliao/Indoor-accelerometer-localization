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
    
    var distanceTraveled : Double = 0.0
    var velocityX: Double = 0.0
    var velocityY: Double = 0.0
    var velocityZ: Double = 0.0
    var calibrationTimesRemained: Int = 0
    var avgX: Double = 0.0
    var avgY: Double = 0.0
    var avgZ: Double = 0.0
    var isCalibrated: Bool = false
    var calibrationPointsRemained: Int = 0
    var accCaliSumX: Double = 0.0
    
    var isCalibratedGyro: Bool = false
    var calibrationTimesGyroRemained: Int = 0
    var avgGyroX: Double = 0.0
    var avgGyroY: Double = 0.0
    var avgGyroZ: Double = 0.0
    
    var staticStateJudgeTimer = (a: 0.0, w: 0.0)
    
    // MARK: Kalman Filter
    var kalmanX: KalmanFilter = KalmanFilter()
    var kalmanY: KalmanFilter = KalmanFilter()
    var kalmanZ: KalmanFilter = KalmanFilter()
    var x: [Double] = [1, 2, 3]
    var y: [Double] = [1, 2, 3]
    var linearCoef = (slope: 0.0, intercept: 0.0)
    var kValueX: Double = 0.0
    var kValueY: Double = 0.0
    var kValueZ: Double = 0.0
    var outputX: Double = 0.0
    var outputY: Double = 0.0
    var outputZ: Double = 0.0
    var outputGyroX: Double = 0.0
    var outputGyroY: Double = 0.0
    var outputGyroZ: Double = 0.0
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
    @IBOutlet var distance: UILabel?
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
        
        distanceTraveled = 0.0
        velocityX = 0.0
        velocityY = 0.0
        velocityZ = 0.0
        outputX = 0.0
        outputY = 0.0
        outputZ = 0.0
        calibrationTimesRemained = calibrationTimeAssigned
        avgX = 0.0
        avgY = 0.0
        avgZ = 0.0
        isCalibrated = false
        calibrationPointsRemained = numberOfPointsForCalibration
        accCaliSumX = 0.0
        
        calibrationTimesGyroRemained = calibrationTimeAssigned
        avgGyroX = 0.0
        avgGyroY = 0.0
        avgGyroZ = 0.0
        outputGyroX = 0.0
        outputGyroY = 0.0
        outputGyroZ = 0.0
        isCalibratedGyro = false
        
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
        
        if !isCalibrated {
            
            info?.text = "Calibrating..."
            
            if calibrationTimesRemained > 0 {
                avgX += acceleration.x
                avgY += acceleration.y
                avgZ += acceleration.z
                calibrationTimesRemained -= 1
            } else {
                avgX /= Double(calibrationTimeAssigned)
                avgY /= Double(calibrationTimeAssigned)
                avgZ /= Double(calibrationTimeAssigned)
                isCalibrated = true
            }
            
        } else {
            
            info?.text = "Detecting..."
            
            /* KalmanFilter begins */
            linearCoef = SimpleLinearRegression(x, y: y)
            
            kValueX = kalmanX.Update(acceleration.x)
            outputX = linearCoef.intercept + linearCoef.slope*kValueX - avgX
            accX?.text = "\(outputX)"
            
            kValueY = kalmanY.Update(acceleration.y)
            outputY = linearCoef.intercept + linearCoef.slope*kValueY - avgY
            accY?.text = "\(outputY)"
            
            kValueZ = kalmanZ.Update(acceleration.z)
            outputZ = linearCoef.intercept + linearCoef.slope*kValueZ - avgZ
            accZ?.text = "\(outputZ)"
            /* KalmanFilter ends */
            
            /* Note1 */
            
            if fabs(outputX) >= 0.1 {
                velocityX += outputX * 9.81 * motionManager.accelerometerUpdateInterval
            }
            if fabs(outputY) >= 0.1 {
                velocityY += outputY * 9.81 * motionManager.accelerometerUpdateInterval
            }
            if fabs(outputZ) >= 0.1 {
                velocityZ += outputZ * 9.81 * motionManager.accelerometerUpdateInterval
            }
            
            velX?.text = "\(velocityX)"
            velY?.text = "\(velocityY)"
            velZ?.text = "\(velocityZ)"
            
            if fabs(outputX) < 0.1 && fabs(outputY) < 0.1 && fabs(outputZ) < 0.1 { // 0.1 is regarded as the "static state" for acc
                staticStateJudgeTimer.a += 1
                if staticStateJudgeTimer.a >= zeroVelocityThreshold && staticStateJudgeTimer.w >= zeroVelocityThreshold {
                    if velocityX != 0 {
                        velocityX /= 2
                        if fabs(velocityX) < 0.0001 {
                            velocityX = 0
                        }
                    }
                    if velocityY != 0 {
                        velocityY /= 2
                        if fabs(velocityY) < 0.0001 {
                            velocityY = 0
                        }
                    }
                    if velocityZ != 0 {
                        velocityZ /= 2
                        if fabs(velocityZ) < 0.0001 {
                            velocityZ = 0
                        }
                    }
                }
            } else {
                staticStateJudgeTimer.a = 0.0
            }
            
            distanceTraveled += velocityX * motionManager.accelerometerUpdateInterval
            distance?.text = "\(distanceTraveled)"
        }
    }
    
    func outputRotData(rotation: CMRotationRate){
        
        
        if !isCalibratedGyro {
            //            if calibrationTimesGyro == calibrationTimeAssigned {
            //                maxRotX?.text = String(rotation.x)
            //            }
            
            if calibrationTimesGyroRemained > 0 {
                avgGyroX += rotation.x
                avgGyroY += rotation.y
                avgGyroZ += rotation.z
                calibrationTimesGyroRemained -= 1
            } else {
                avgGyroX /= Double(calibrationTimeAssigned)
                avgGyroY /= Double(calibrationTimeAssigned)
                avgGyroZ /= Double(calibrationTimeAssigned)
                isCalibratedGyro = true
            }
            
        } else {
            
            outputGyroX = rotation.x - avgGyroX
            outputGyroY = rotation.y - avgGyroY
            outputGyroZ = rotation.z - avgGyroZ
            
            rotX?.text = "\(outputGyroX)"
            rotY?.text = "\(outputGyroY)"
            rotZ?.text = "\(outputGyroZ)"
            
            if outputGyroX < 0.01 && outputGyroY < 0.01 && outputGyroZ < 0.01 {  // 0.01 is regarded as "static state" for angle acc
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

