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
    let accelerometerUpdateInterval: Double = 0.2
    let gyroUpdateInterval: Double = 0.2
    let calibrationTimeAssigned: Int = 100
    let numberOfPointsForCalibration: Int = 3
    
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
    var calibrationTimes: Int = 0
    var calibrationSum: Double = 0.0
    var avg: Double = 0.0
    var isCalibrated: Bool = false
    var calibrationPointsRemained: Int = 0
    var accCaliSumX: Double = 0.0
    
    // Kalman Filter
    var kalman: KalmanFilter = KalmanFilter()
    var x: [Double] = [1, 2, 3]
    var y: [Double] = [1, 2, 3]
    var linearCoef = (slope: 0.0, intercept: 0.0)
    var kValue: Double = 0.0
    var outputX: Double = 0.0
    
    // Outlets
    @IBOutlet var accX: UILabel?
    @IBOutlet var accY: UILabel?
    @IBOutlet var accZ: UILabel?
    @IBOutlet var maxAccXNegative: UILabel?
    @IBOutlet var maxAccXPositive: UILabel?
    @IBOutlet var maxAccY: UILabel?
    @IBOutlet var maxAccZ: UILabel?
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
        calibrationTimes = calibrationTimeAssigned
        calibrationSum = 0
        avg = 0.0
        isCalibrated = false
        calibrationPointsRemained = numberOfPointsForCalibration
        accCaliSumX = 0.0
        
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
            if calibrationTimes == calibrationTimeAssigned {
                maxAccXPositive?.text = String(acceleration.x)
            }
            
            if calibrationTimes > 0 {
                calibrationSum += acceleration.x
                calibrationTimes -= 1
            } else {
                maxAccXNegative?.text = String(calibrationSum)
                avg = calibrationSum / Double(calibrationTimeAssigned)
                isCalibrated = true
            }
            
        } else {
            
            info?.text = "Detecting..."
            
            linearCoef = SimpleLinearRegression(x, y: y)
            
            kValue = kalman.Update(acceleration.x)
            
            outputX = linearCoef.intercept + linearCoef.slope*kValue
            
            accX?.text = "\(outputX - avg)"
            
            
            
//            if calibrationPointsRemained != 0 {
//                accCaliSumX += acceleration.x
//                calibrationPointsRemained -= 1
//            } else {
//                accCaliSumX /= Double(numberOfPointsForCalibration)
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
            
            
        }
        
        accY?.text = "\(acceleration.y).2fg"
        if fabs(acceleration.y) > fabs(currentMaxAccelY) {
            currentMaxAccelY = acceleration.y
        }
        
        accZ?.text = "\(acceleration.z).2fg"
        if fabs(acceleration.z) > fabs(currentMaxAccelZ) {
            currentMaxAccelZ = acceleration.z
        }
        
        if Double(accX!.text!)! >= 0.1 || Double(accX!.text!)! <= -0.1 {
            velocityX += Double(accX!.text!)! * 9.81 * motionManager.accelerometerUpdateInterval
        }
        
        //maxAccXNegative?.text = "\(currentMaxAccelXNegative).2f"
        //maxAccXPositive?.text = "\(currentMaxAccelXPositive).2f"
        maxAccY?.text = "\(currentMaxAccelY).2f"
        maxAccZ?.text = "\(currentMaxAccelZ).2f"
        
        velX?.text = "\(velocityX)"
        distanceTraveled += velocityX * motionManager.accelerometerUpdateInterval
        distance?.text = "\(distanceTraveled)"
        //distance?.text = "\(avg)"
        
    }
    
    func outputRotData(rotation: CMRotationRate){
        
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
        
        maxRotX?.text = "\(currentMaxRotX).2f"
        maxRotY?.text = "\(currentMaxRotY).2f"
        maxRotZ?.text = "\(currentMaxRotZ).2f"
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

