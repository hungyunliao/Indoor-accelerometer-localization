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
    var delegate: DataProcessorDelegate? = nil
    
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
    var deviceMotionUpdateInterval: Double = 0.03
    let accelerationThreshold = 0.001
    var staticStateJudgeThreshold = (accModulus: 0.5, gyroModulus: 20/M_PI, modulusDiff: 0.05)
    
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
    
    // MARK: Filter decision
    enum Option {
        case Raw
        case ThreePoint
        case Kalman
    }
    let filterChoice = Option.ThreePoint
    
    // MARK: Performance measure
    var performanceDataArrayX = [Double]()
    var performanceDataArrayY = [Double]()
    var performanceDataArrayZ = [Double]()
    var count = 1
    var performanceDataSize = 100
    var executePerformanceCompare = true
    
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
      
        let acc: CMAcceleration = motion.userAcceleration
        //print(acc)
        let rot = motion.attitude.rotationMatrix
        
        let x = (acc.x*rot.m11 + acc.y*rot.m21 + acc.z*rot.m31) * gravityConstant
        let y = (acc.x*rot.m12 + acc.y*rot.m22 + acc.z*rot.m32) * gravityConstant
        let z = (acc.x*rot.m13 + acc.y*rot.m23 + acc.z*rot.m33) * gravityConstant
        
        if executePerformanceCompare == true {
            if count <= performanceDataSize {
                performanceDataArrayX.append(x)
                performanceDataArrayY.append(y)
                performanceDataArrayZ.append(z)
                if count == performanceDataSize {
                    //print(performanceDataArrayX)
                    performance(performanceDataArrayX, arrY: performanceDataArrayY, arrZ: performanceDataArrayZ, performanceDataSize: performanceDataSize)
                }
                count += 1
            }
        }
        
        var test:Filter
        
        switch filterChoice {
        case .Raw:
            test = RawFilter()
        case .ThreePoint:
            test = ThreePointFilter()
        case .Kalman:
            test = KalmanFilter()
        }
        
        (absSys.accelerate.x, absSys.accelerate.y, absSys.accelerate.z) = test.filter(x, y: y, z: z)
        
        determineVelocityAndCoculateDistance()
        
        newData(speedDataType.accelerate, sensorData: absSys.accelerate)
        newData(speedDataType.velocity, sensorData: absSys.velocity)
        newData(speedDataType.distance, sensorData: absSys.distance)
        
        absSys.accelerate.x = 0
        absSys.accelerate.y = 0
        absSys.accelerate.z = 0
    }
    
    func determineVelocityAndCoculateDistance() {
        
        // Static Judgement Condition 1 && 2 && 3
        if staticStateJudge.modulAcc && staticStateJudge.modulGyro && staticStateJudge.modulDiffAcc {
            
            newStatus("static state") // sending status to delegate
            
            absSys.velocity.x = 0
            absSys.velocity.y = 0
            absSys.velocity.z = 0
            
        } else {
            
            newStatus("dynamic state") // sending status to delegate
            

            if fabs(absSys.accelerate.x) > accelerationThreshold {
                absSys.velocity.x += absSys.accelerate.x * deviceMotionUpdateInterval
                absSys.distance.x += absSys.velocity.x * deviceMotionUpdateInterval
            }
            if fabs(absSys.accelerate.y) > accelerationThreshold {
                absSys.velocity.y += absSys.accelerate.y * deviceMotionUpdateInterval
                absSys.distance.y += absSys.velocity.y * deviceMotionUpdateInterval
            }
            if fabs(absSys.accelerate.z) > accelerationThreshold {
                absSys.velocity.z += absSys.accelerate.z * deviceMotionUpdateInterval
                absSys.distance.z += absSys.velocity.z * deviceMotionUpdateInterval
            }
        }
    }

    func outputAccData(acceleration: CMAcceleration) {
        
        accSys.accelerate.x = acceleration.x * gravityConstant
        accSys.accelerate.y = acceleration.y * gravityConstant
        accSys.accelerate.z = acceleration.z * gravityConstant
        
        print(modulus(accSys.accelerate.x, y: accSys.accelerate.y, z: accSys.accelerate.z) - gravityConstant, modulus(gyroSys.accelerate.x, y: gyroSys.accelerate.y, z: gyroSys.accelerate.z), modulusDiff, staticStateJudge)
 
        
        // Static Judgement Condition 3
        modulusDiffCalculation()
        
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
        
        gyroSys.accelerate.x = rotation.x
        gyroSys.accelerate.y = rotation.y
        gyroSys.accelerate.z = rotation.z
        
        // Static Judgement Condition 2
        if modulus(gyroSys.accelerate.x, y: gyroSys.accelerate.y, z: gyroSys.accelerate.z) < staticStateJudgeThreshold.gyroModulus {
            staticStateJudge.modulGyro = true
        } else {
            staticStateJudge.modulGyro = false
        }
    }
    
    
    
    func modulusDiffCalculation() {
        
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
    }
    
    func performance (arrX : [Double], arrY : [Double], arrZ : [Double], performanceDataSize: Int) {
        //let typeOfFilter = "Raw"
        var test:Filter
        var resultX = 0.0
        var resultY = 0.0
        var resultZ = 0.0
        var outX = Array(count: performanceDataSize, repeatedValue:0.0)
        var outY = Array(count: performanceDataSize, repeatedValue:0.0)
        var outZ = Array(count: performanceDataSize, repeatedValue:0.0)
        
        test = RawFilter()
        for index in 0..<performanceDataSize {
            (outX[index], outY[index], outZ[index]) = test.filter(arrX[index], y: arrY[index], z: arrZ[index])
        }
        resultX = standardDeviation(outX)
        resultY = standardDeviation(outY)
        resultZ = standardDeviation(outZ)
        print("Raw       :", resultX, resultY, resultZ)
        
        test = ThreePointFilter()
        for index in 0..<performanceDataSize {
            (outX[index], outY[index], outZ[index]) = test.filter(arrX[index], y: arrY[index], z: arrZ[index])
        }
        resultX = standardDeviation(outX)
        resultY = standardDeviation(outY)
        resultZ = standardDeviation(outZ)
        print("ThreePoint:", resultX, resultY, resultZ)
    }

}


