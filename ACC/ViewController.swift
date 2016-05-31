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
    
    // System parameters setup
    var accelerometerUpdateInterval: Double = 0.1
    var gyroUpdateInterval: Double = 0.1
    var calibrationTimeAssigned: Int = 100
    var numberOfPointsForCalibration: Int = 3
    var zeroVelocityThreshold: Double = 10.0 // the higher, the longer the system takes setting the V to 0 while acc and w are 0.
    
    // Instance variables
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
    var calibrationTimes: Int = 0
    var avgX: Double = 0.0
    var avgY: Double = 0.0
    var avgZ: Double = 0.0
    var isCalibrated: Bool = false
    var calibrationPointsRemained: Int = 0
    var accCaliSumX: Double = 0.0
    
    var isCalibratedGyro: Bool = false
    var calibrationTimesGyro: Int = 0
    var calibrationSumGyro: Double = 0.0
    var avgGyro: Double = 0.9
    
    var zeroVJudge = (a: 0.0, w: 0.0)
    
    // Kalman Filter
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
    var STDEV = [Double]()
    
    // Outlets
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
    
    // Functions
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
        calibrationTimes = calibrationTimeAssigned
        avgX = 0.0
        avgY = 0.0
        avgZ = 0.0
        isCalibrated = false
        calibrationPointsRemained = numberOfPointsForCalibration
        accCaliSumX = 0.0
        
        calibrationTimesGyro = calibrationTimeAssigned
        calibrationSumGyro = 0
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
            
            if calibrationTimes > 0 {
                avgX += acceleration.x
                avgY += acceleration.y
                avgZ += acceleration.z
                calibrationTimes -= 1
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
                zeroVJudge.a += 1
                if zeroVJudge.a >= zeroVelocityThreshold && zeroVJudge.w >= zeroVelocityThreshold {
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
                zeroVJudge.a = 0.0
            }
            
            
            distanceTraveled += velocityX * motionManager.accelerometerUpdateInterval
            distance?.text = "\(distanceTraveled)"
        }
    }
    
    func outputRotData(rotation: CMRotationRate){
        
        
        if !isCalibratedGyro {
            if calibrationTimesGyro == calibrationTimeAssigned {
                maxRotX?.text = String(rotation.x)
            }
            
            if calibrationTimesGyro > 0 {
                calibrationSumGyro += rotation.x
                calibrationTimesGyro -= 1
            } else {
                avgGyro = calibrationSumGyro / Double(calibrationTimeAssigned)
                maxRotX?.text = String(rotation.x - avgGyro)
                isCalibratedGyro = true
            }
            
        }
        
        rotX?.text = "\(rotation.x).2fr/s"
        if fabs(rotation.x) > fabs(currentMaxRotX) {
            currentMaxRotX = rotation.x
        }
        
        rotY?.text = "\(rotation.y).2fr/s"
        if fabs(rotation.y) > fabs(currentMaxRotY) {
            currentMaxRotY = rotation.y
        }
        
        rotZ?.text = "\(rotation.z).2fr/s"
        if fabs(rotation.z) > fabs(currentMaxRotZ) {
            currentMaxRotZ = rotation.z
        }
        
        //maxRotX?.text = "\(currentMaxRotX).2f"
        maxRotY?.text = "\(currentMaxRotY).2f"
        maxRotZ?.text = "\(currentMaxRotZ).2f"
        
        if Double((rotX?.text!)!) < 0.01 {  // 0.01 is regarded as "static state" for angle acc
            zeroVJudge.w += 1
        } else {
            zeroVJudge.w = 0.0
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

