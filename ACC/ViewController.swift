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
    let gravityConstant = 9.80665
    let publicDB = NSUserDefaults.standardUserDefaults()
    var accelerometerUpdateInterval: Double = 0.01
    var gyroUpdateInterval: Double = 0.01
    var deviceMotionUpdateInterval: Double = 0.03
    let accelerationThreshold = 0.0001
    //var staticStateJudgeThreshold = (accModulus: 1.0, gyroModulus: 35/M_PI, modulusDiff: 0.1)
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
    //var linearCoef = (slope: 0.0, intercept: 0.0)
    
    // MARK: Refined Kalman Filter
    var arrayForCalculatingKalmanRX = [Double]()
    var arrayForCalculatingKalmanRY = [Double]()
    var arrayForCalculatingKalmanRZ = [Double]()
    
    // MARK: Static judement
    var staticStateJudge = (modulAcc: false, modulGyro: false, modulDiffAcc: false) // true: static false: dynamic
    var arrayForStatic = [Double](count: 7, repeatedValue: -1)
    var index = 0
    var modulusDiff = -1.0
    
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
    
    @IBOutlet var velXGyro: UILabel?
    @IBOutlet var velYGyro: UILabel?
    @IBOutlet var velZGyro: UILabel?
    
    @IBOutlet var disXGyro: UILabel?
    @IBOutlet var disYGyro: UILabel?
    @IBOutlet var disZGyro: UILabel?
    
    @IBAction func reset() {
        accSys.reset()
        gyroSys.reset()
        absSys.reset()
    }
    
    // MARK: Override functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reset()
        
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
                print("error here \(error)")
            }
        })

        //linearCoef = SimpleLinearRegression(arrayOfPoints, y: arrayOfPoints) // For Kalman. Initializing the coef before the recording functions running
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Functions
    func outputXTrueNorthMotionData(motion: CMDeviceMotion) {
        
        let acc: CMAcceleration = motion.userAcceleration
        //print(acc)
        let rot = motion.attitude.rotationMatrix
        
        var x = 0.0
        var y = 0.0
        var z = 0.0
        
        x = (acc.x*rot.m11 + acc.y*rot.m21 + acc.z*rot.m31) * gravityConstant
        y = (acc.x*rot.m12 + acc.y*rot.m22 + acc.z*rot.m32) * gravityConstant
        z = (acc.x*rot.m13 + acc.y*rot.m23 + acc.z*rot.m33) * gravityConstant
        
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
        
        var test:Filter
        
        switch filterChoice {
        case .Raw:
            test = RawFilter()
        case .ThreePoint:
            test = ThreePointFilter()
        case .Kalman:
            test = KalmanFilter()
        }
        
        (absSys.output.x, absSys.output.y, absSys.output.z) = test.filter(x, y: y, z: z)
        
        determineVelocity()
        
        absSys.output.x = 0
        absSys.output.y = 0
        absSys.output.z = 0
    }
    
    func determineVelocity() {
        
        /*
         print(fabs(modulus(accSys.output.x, y: accSys.output.y, z: accSys.output.z) - gravityConstant),
         modulus(gyroSys.output.x, y: gyroSys.output.y, z: gyroSys.output.z),
         fabs(modulusDiff),
         staticStateJudge.modulAcc,
         staticStateJudge.modulGyro,
         staticStateJudge.modulDiffAcc)
         */
        
        // Static Judgement Condition 1 && 2 && 3
        if staticStateJudge.modulAcc && staticStateJudge.modulGyro && staticStateJudge.modulDiffAcc {
            
            info?.text = "static state"
            
            absSys.velocity.x = 0
            absSys.velocity.y = 0
            absSys.velocity.z = 0
            
        } else {
            
            info?.text = "dynamic state"
            
            if fabs(absSys.output.x) > accelerationThreshold {
                absSys.velocity.x += absSys.output.x * deviceMotionUpdateInterval
                absSys.distance.x += absSys.velocity.x * deviceMotionUpdateInterval
            }
            if fabs(absSys.output.y) > accelerationThreshold {
                absSys.velocity.y += absSys.output.y * deviceMotionUpdateInterval
                absSys.distance.y += absSys.velocity.y * deviceMotionUpdateInterval
            }
            if fabs(absSys.output.z) > accelerationThreshold {
                absSys.velocity.z += absSys.output.z * deviceMotionUpdateInterval
                absSys.distance.z += absSys.velocity.z * deviceMotionUpdateInterval
            }
            passValueToView()
        }
        
        displayOnAccLabel(absSys.output)
        displayOnVelLabel(absSys.velocity)
        displayOnDisLabel(absSys.distance)
    }
    
    func passValueToView() {
        publicDB.setValue(absSys.output.x, forKey: "accX")
        publicDB.setValue(absSys.output.y, forKey: "accY")
        publicDB.setValue(absSys.velocity.x, forKey: "velX")
        publicDB.setValue(absSys.velocity.x, forKey: "velY")
        
        // save the changed position to the PUBLIC NSUserdefault object so that they can be accessed by other VIEWCONTROLLERs
        publicDB.setValue(absSys.distance.x, forKey: "x")
        publicDB.setValue(absSys.distance.y, forKey: "y")
        // post the notification to the NotificationCenter to notify everyone who is on the observer list.
        NSNotificationCenter.defaultCenter().postNotificationName("PositionChanged", object: nil)
    }
    
    private func displayOnAccLabel(outputValue: ThreeAxesSystemDouble) {
        accX?.text = "\(roundNum(outputValue.x))"
        accY?.text = "\(roundNum(outputValue.y))"
        accZ?.text = "\(roundNum(outputValue.z))"
    }
    
    private func displayOnVelLabel(outputValue: ThreeAxesSystemDouble) {
        velX?.text = "\(roundNum(outputValue.x))"
        velY?.text = "\(roundNum(outputValue.y))"
        velZ?.text = "\(roundNum(outputValue.z))"
    }
    
    private func displayOnDisLabel(outputValue: ThreeAxesSystemDouble) {
        disX?.text = "\(roundNum(outputValue.x))"
        disY?.text = "\(roundNum(outputValue.y))"
        disZ?.text = "\(roundNum(outputValue.z))"
    }
    
    func outputAccData(acceleration: CMAcceleration) {
        
        //        if !accSys.isCalibrated {
        //
        //            info?.text = "Calibrating..." + String(accSys.calibrationTimesDone) + "/" + String(calibrationTimeAssigned)
        //
        //            if accSys.calibrationTimesDone < calibrationTimeAssigned {
        //
        //                arrayForCalculatingKalmanRX += [acceleration.x]
        //                arrayForCalculatingKalmanRY += [acceleration.y]
        //                arrayForCalculatingKalmanRZ += [acceleration.z]
        //                accSys.calibrationTimesDone += 1
        //
        //            } else {
        //
        //                var kalmanInitialRX = 0.0
        //                var kalmanInitialRY = 0.0
        //                var kalmanInitialRZ = 0.0
        //
        //                for index in arrayForCalculatingKalmanRX {
        //                    kalmanInitialRX += pow((index - accSys.base.x), 2)/Double(calibrationTimeAssigned)
        //                }
        //                for index in arrayForCalculatingKalmanRY {
        //                    kalmanInitialRY += pow((index - accSys.base.y), 2)/Double(calibrationTimeAssigned)
        //                }
        //                for index in arrayForCalculatingKalmanRZ {
        //                    kalmanInitialRZ += pow((index - accSys.base.z), 2)/Double(calibrationTimeAssigned)
        //                }
        //                accSys.isCalibrated = true
        //            }
        //
        //        } else {
        
        accSys.output.x = acceleration.x * gravityConstant
        accSys.output.y = acceleration.y * gravityConstant
        accSys.output.z = acceleration.z * gravityConstant
        
        // Static Judgement Condition 3
        if index == arrayForStatic.count {
            accModulusAvg = 0
            for i in 0..<(arrayForStatic.count - 1) {
                arrayForStatic[i] = arrayForStatic[i + 1]
                accModulusAvg += arrayForStatic[i]
            }
            arrayForStatic[index - 1] = modulus(accSys.output.x, y: accSys.output.y, z: accSys.output.z)
            accModulusAvg += arrayForStatic[index - 1]
            accModulusAvg /= Double(arrayForStatic.count)
            modulusDiff = modulusDifference(arrayForStatic, avgModulus: accModulusAvg)
        } else {
            arrayForStatic[index] = modulus(accSys.output.x, y: accSys.output.y, z: accSys.output.z)
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
        if fabs(modulus(accSys.output.x, y: accSys.output.y, z: accSys.output.z) - gravityConstant) < staticStateJudgeThreshold.accModulus {
            staticStateJudge.modulAcc = true
        } else {
            staticStateJudge.modulAcc = false
        }
        //        }
    }
    
    func outputRotData(rotation: CMRotationRate) {
        // Static Judgement Condition 2
        if modulus(gyroSys.output.x, y: gyroSys.output.y, z: gyroSys.output.z) < staticStateJudgeThreshold.gyroModulus {
            staticStateJudge.modulGyro = true
        } else {
            staticStateJudge.modulGyro = false
        }
    }
    
}

// MARK: operator define
infix operator ^ {}
func ^ (radix: Double, power: Double) -> Double {
    return pow(radix, power)
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

// this STDEV function is from github: https://gist.github.com/jonelf/9ae2a2133e21e255e692
func standardDeviation(arr : [Double]) -> Double
{
    let length = Double(arr.count)
    let avg = arr.reduce(0, combine: {$0 + $1}) / length
    let sumOfSquaredAvgDiff = arr.map { pow($0 - avg, 2.0)}.reduce(0, combine: {$0 + $1})
    return sqrt(sumOfSquaredAvgDiff / length)
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