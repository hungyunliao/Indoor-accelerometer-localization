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

    // Instance variables
    var currentMaxAccelX: Double = 0.0 //negative
    var currentMaxAccelXPositive: Double = 0.0
    var currentMaxAccelY: Double = 0.0
    var currentMaxAccelZ: Double = 0.0
    var currentMaxRotX: Double = 0.0
    var currentMaxRotY: Double = 0.0
    var currentMaxRotZ: Double = 0.0
    
    var motionManager = CMMotionManager()
    
    var distanceT : Double = 0.0
    var velocityX: Double = 0.0
    var calibrationTimes: Int = 100
    var calibrationSum: Double = 0.0
    var avg : Double = 0.0
    var isCalibrated: Bool = false
    
    // Outlets
    @IBOutlet var accX: UILabel?
    
    @IBOutlet var accY: UILabel?
    
    @IBOutlet var accZ: UILabel?
    
    @IBOutlet var maxAccX: UILabel?
    
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
    
    // Functions
    @IBAction func reset() {
        currentMaxAccelX = 0.0 //negative AccelX
        currentMaxAccelXPositive = 0.0
        currentMaxAccelY = 0.0
        currentMaxAccelZ = 0.0
        currentMaxRotX = 0.0
        currentMaxRotY = 0.0
        currentMaxRotZ = 0.0
        
        distanceT = 0.0
        velocityX = 0.0
        calibrationTimes = 100
        calibrationSum = 0
        avg = 0.0
        isCalibrated = false
    }
    
    
    override func viewDidLoad() {
        
        self.reset()
        
        // Set Motion Manager Properties
        
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.gyroUpdateInterval = 0.2
        
        // Recording data
        
        motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: { (accelerometerData: CMAccelerometerData?, NSError) -> Void in
            self.outputAccData(accelerometerData!.acceleration)
            if(NSError != nil) {
                print("\(NSError)")
            }
        })
        
        motionManager.startGyroUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: { (gyroData: CMGyroData?, NSError) -> Void in
            self.outputRotData(gyroData!.rotationRate)
            if (NSError != nil){
                print("\(NSError)")
            }
        })
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func outputAccData(acceleration: CMAcceleration){
        
        if !isCalibrated {
            if calibrationTimes == 100 {
                maxAccXPositive?.text = String(acceleration.x)
            }
            if calibrationTimes > 0 {
                calibrationSum += acceleration.x
                calibrationTimes -= 1
            } else {
                maxAccX?.text = String(calibrationSum)
                avg = calibrationSum / 100
                isCalibrated = true
            }
        }
        else {
            accX?.text = "\(acceleration.x - avg)"
            if acceleration.x > currentMaxAccelXPositive
            {
                currentMaxAccelXPositive = acceleration.x
            }
            
            if acceleration.x < currentMaxAccelX // negative
            {
                currentMaxAccelX = acceleration.x
            }
        }
        
        accY?.text = "\(acceleration.y).2fg"
        if fabs(acceleration.y) > fabs(currentMaxAccelY)
        {
            currentMaxAccelY = acceleration.y
        }
        
        accZ?.text = "\(acceleration.z).2fg"
        if fabs(acceleration.z) > fabs(currentMaxAccelZ)
        {
            currentMaxAccelZ = acceleration.z
        }
        
        if Double(accX!.text!)! >= 1 || Double(accX!.text!)! <= -1 {
            velocityX += acceleration.x * 9.81 * motionManager.accelerometerUpdateInterval
        }
        
        //maxAccX?.text = "\(currentMaxAccelX).2f"
        //maxAccXPositive?.text = "\(currentMaxAccelXPositive).2f"
        maxAccY?.text = "\(currentMaxAccelY).2f"
        maxAccZ?.text = "\(currentMaxAccelZ).2f"
        
        velX?.text = "\(velocityX)"
        distanceT += velocityX * motionManager.accelerometerUpdateInterval
        distance?.text = "\(distanceT)"
        //distance?.text = "\(avg)"
        
        
    }
    
    func outputRotData(rotation: CMRotationRate){
        
        
        rotX?.text = "\(rotation.x).2fr/s"
        if fabs(rotation.x) > fabs(currentMaxRotX)
        {
            currentMaxRotX = rotation.x
        }
        
        rotY?.text = "\(rotation.y).2fr/s"
        if fabs(rotation.y) > fabs(currentMaxRotY)
        {
            currentMaxRotY = rotation.y
        }
        
        rotZ?.text = "\(rotation.z).2fr/s"
        if fabs(rotation.z) > fabs(currentMaxRotZ)
        {
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

