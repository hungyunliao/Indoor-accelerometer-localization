//
//  DataProcessor.swift
//  ACC
//
//  Created by Hung-Yun Liao on 6/29/16.
//  Copyright © 2016 Hung-Yun Liao. All rights reserved.
//

import Foundation
import CoreMotion

protocol DataProcessorDelegate {
    func sendingNewData(person: DataProcessor, type: speedDataType, data: ThreeAxesSystemDouble)
    func sendingNewStatus(person: DataProcessor, status: String)
}

enum speedDataType {
    case accelerate
    case velocity
    case distance
}

class DataProcessor {

    // MARK: delegate
    var delegate: DataProcessorDelegate? = nil // MARK: Question: what's the difference between "?" and "!" here?
    
    func newData(type: speedDataType, sensorData: ThreeAxesSystemDouble) {
        delegate?.sendingNewData(self, type: type, data: sensorData)
    }
    
    func newStatus(status: String) {
        delegate?.sendingNewStatus(self, status: status)
    }
    
    // MARK: test param
    var test = 0
    var sum = 0.0
    
    // MARK: System parameters setup
    let gravityConstant = 9.80665
    let publicDB = NSUserDefaults.standardUserDefaults()
    var accelerometerUpdateInterval: Double = 0.01
    var gyroUpdateInterval: Double = 0.01
    var deviceMotionUpdateInterval: Double = 0.09
    let accelerationThreshold = 0.1
    var staticStateJudgeThreshold = (accModulus: 1.0, gyroModulus: 35/M_PI, modulusDiff: 0.1)
    
    
    var calibrationTimeAssigned: Int = 100
    
    // MARK: Instance variables
    var motionManager = CMMotionManager()
    var accModulusAvg = 0.0
    var accSys: System = System()
    var gyroSys: System = System()
    var absSys: System = System()
    
    // MARK: Kalman Filter
    var arrayOfPoints: [Double] = [1, 2, 3]
    var linearCoef = (slope: 0.0, intercept: 0.0)
    
    // MARK: Refined Kalman Filter
    var arrayForCalculatingKalmanRX = [Double]()
    var arrayForCalculatingKalmanRY = [Double]()
    var arrayForCalculatingKalmanRZ = [Double]()
    
    // MARK: Static judement
    var staticStateJudge = (modulAcc: false, modulGyro: false, modulDiffAcc: false) // true: static false: dynamic
    var arrayForStatic = [Double](count: 7, repeatedValue: -1)
    var index = 0
    var modulusDiff = -1.0
    
    // MARK: Three-Point Filter
    let numberOfPointsForThreePtFilter = 3
    var arrayX = [Double]()
    var arrayY = [Double]()
    var arrayZ = [Double]()
    
    func startsDetection() {
        
        // Set Motion Manager Properties
        motionManager.accelerometerUpdateInterval = accelerometerUpdateInterval
        motionManager.gyroUpdateInterval = gyroUpdateInterval
        motionManager.startDeviceMotionUpdates()//for gyro degree
        motionManager.deviceMotionUpdateInterval = deviceMotionUpdateInterval
        
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
        
        motionManager.startDeviceMotionUpdatesUsingReferenceFrame(CMAttitudeReferenceFrame.XTrueNorthZVertical, toQueue: NSOperationQueue.currentQueue()!, withHandler: { (motion,  error) in
            if motion != nil {
                self.outputXTrueNorthMotionData(motion!)
            }
            if error != nil {
                print("\(error)")
            }
        })
    }
  
    func reset() {
        accSys.reset()
        gyroSys.reset()
        absSys.reset()
    }
    
    // MARK: Functions
    func outputXTrueNorthMotionData(motion: CMDeviceMotion) {
      
        /* 3-point Filter begins */
        if absSys.threePtFilterPointsDone < numberOfPointsForThreePtFilter {
            
            let acc: CMAcceleration = motion.userAcceleration
            let rot = motion.attitude.rotationMatrix
            
            arrayX.append(acc.x*rot.m11 + acc.y*rot.m21 + acc.z*rot.m31)
            arrayY.append(acc.x*rot.m12 + acc.y*rot.m22 + acc.z*rot.m32)
            arrayZ.append(acc.x*rot.m13 + acc.y*rot.m23 + acc.z*rot.m33)
            
            absSys.threePtFilterPointsDone += 1
            
        } else {
            
            for i in 0..<3 {
                absSys.accelerate.x += arrayX[i]
                absSys.accelerate.y += arrayY[i]
                absSys.accelerate.z += arrayZ[i]
            }
            
            arrayX.removeFirst()
            arrayY.removeFirst()
            arrayZ.removeFirst()
            
            absSys.accelerate.x = absSys.accelerate.x/Double(numberOfPointsForThreePtFilter) * gravityConstant
            absSys.accelerate.y = absSys.accelerate.y/Double(numberOfPointsForThreePtFilter) * gravityConstant
            absSys.accelerate.z = absSys.accelerate.z/Double(numberOfPointsForThreePtFilter) * gravityConstant
            
            absSys.threePtFilterPointsDone = 2 // only needs to save ONE point for the next average. (a1+a2+a3)/3, (a2+a3+a4)/3 ...
            /* 3-point Filter ends */
            
            // Static Judgement Condition 1 && 2 && 3
            if staticStateJudge.modulAcc && staticStateJudge.modulGyro && staticStateJudge.modulDiffAcc {
                
                newStatus("static state") // sending status to delegate
                
                absSys.velocity.x = 0
                absSys.velocity.y = 0
                absSys.velocity.z = 0
                
            } else {
                
                newStatus("dynamic state") // sending status to delegate
                
                if fabs(absSys.accelerate.x) > accelerationThreshold {
                    absSys.velocity.x += absSys.accelerate.x * deviceMotionUpdateInterval * Double(numberOfPointsForThreePtFilter)
                    absSys.distance.x += absSys.velocity.x * deviceMotionUpdateInterval * Double(numberOfPointsForThreePtFilter)
                }
                if fabs(absSys.accelerate.y) > accelerationThreshold {
                    absSys.velocity.y += absSys.accelerate.y * deviceMotionUpdateInterval * Double(numberOfPointsForThreePtFilter)
                    absSys.distance.y += absSys.velocity.y * deviceMotionUpdateInterval * Double(numberOfPointsForThreePtFilter)
                }
                if fabs(absSys.accelerate.z) > accelerationThreshold {
                    absSys.velocity.z += absSys.accelerate.z * deviceMotionUpdateInterval * Double(numberOfPointsForThreePtFilter)
                    absSys.distance.z += absSys.velocity.z * deviceMotionUpdateInterval * Double(numberOfPointsForThreePtFilter)
                }
                
                publicDB.setValue(absSys.accelerate.x, forKey: "accX")
                publicDB.setValue(absSys.accelerate.y, forKey: "accY")
                publicDB.setValue(absSys.velocity.x, forKey: "velX")
                publicDB.setValue(absSys.velocity.x, forKey: "velY")
                
                // save the changed position to the PUBLIC NSUserdefault object so that they can be accessed by other VIEWCONTROLLERs
                publicDB.setValue(absSys.distance.x, forKey: "x")
                publicDB.setValue(absSys.distance.y, forKey: "y")
                // post the notification to the NotificationCenter to notify everyone who is on the observer list.
                NSNotificationCenter.defaultCenter().postNotificationName("PositionChanged", object: nil)
                
            }
            
            // sending data to delegate
            newData(speedDataType.accelerate, sensorData: absSys.accelerate)
            newData(speedDataType.velocity, sensorData: absSys.velocity)
            newData(speedDataType.distance, sensorData: absSys.distance)
            
            absSys.accelerate.x = 0
            absSys.accelerate.y = 0
            absSys.accelerate.z = 0
        }
    }
    
    
    func outputAccData(acceleration: CMAcceleration) {
        
        accSys.accelerate.x = acceleration.x * gravityConstant
        accSys.accelerate.y = acceleration.y * gravityConstant
        accSys.accelerate.z = acceleration.z * gravityConstant
        
        // Static Judgement Condition 3
        if index == arrayForStatic.count {
            accModulusAvg = 0
            for i in 0..<(arrayForStatic.count - 1) {
                arrayForStatic[i] = arrayForStatic[i + 1]
                accModulusAvg += arrayForStatic[i]
            }
            arrayForStatic[index - 1] = modulus(accSys.accelerate.x, y: accSys.accelerate.y, z: accSys.accelerate.z)
            accModulusAvg += arrayForStatic[index - 1]
            accModulusAvg /= Double(arrayForStatic.count)
            modulusDiff = modulusDifference(arrayForStatic, avgModulus: accModulusAvg)
        } else {
            arrayForStatic[index] = modulus(accSys.accelerate.x, y: accSys.accelerate.y, z: accSys.accelerate.z)
            index += 1
            if index == arrayForStatic.count {
                for element in arrayForStatic {
                    accModulusAvg += element
                }
                accModulusAvg /= Double(arrayForStatic.count)
                modulusDiff = modulusDifference(arrayForStatic, avgModulus: accModulusAvg)
            }
        }
        
        if modulusDiff != -1 && fabs(modulusDiff) < staticStateJudgeThreshold.modulusDiff {
            staticStateJudge.modulDiffAcc = true
        } else {
            staticStateJudge.modulDiffAcc = false
        }
        
        // Static Judgement Condition 1
        if fabs(modulus(accSys.accelerate.x, y: accSys.accelerate.y, z: accSys.accelerate.z) - gravityConstant) < staticStateJudgeThreshold.accModulus {
            staticStateJudge.modulAcc = true
        } else {
            staticStateJudge.modulAcc = false
        }
    }
    
    func outputRotData(rotation: CMRotationRate) {
        
        // Static Judgement Condition 2
        if modulus(gyroSys.accelerate.x, y: gyroSys.accelerate.y, z: gyroSys.accelerate.z) < staticStateJudgeThreshold.gyroModulus {
            staticStateJudge.modulGyro = true
        } else {
            staticStateJudge.modulGyro = false
        }
    }

}


