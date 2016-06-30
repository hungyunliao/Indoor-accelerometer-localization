//
//  ViewController.swift
//  ACC
//
//  Created by Hung-Yun Liao on 5/23/16.
//  Copyright © 2016 Hung-Yun Liao. All rights reserved.
//

import UIKit
import CoreMotion
//import CoreLocation
//import MapKit

class ViewController: UIViewController, DataProcessorDelegate {
    
    // MARK: Model
    var dataSource: DataProcessor = DataProcessor()
    
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
    
    
    // MARK: Override functions
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.startsDetection()
        dataSource.delegate = self
    }
    
    // MARK: Delegate
    func sendingNewData(person: DataProcessor, type: speedDataType, data: ThreeAxesSystemDouble) {
        switch type {
        case .accelerate:
            accX?.text = "\(roundNum(data.x))"
            accY?.text = "\(roundNum(data.y))"
            accZ?.text = "\(roundNum(data.z))"
        case .velocity:
            velX?.text = "\(roundNum(data.x))"
            velY?.text = "\(roundNum(data.y))"
            velZ?.text = "\(roundNum(data.z))"
        case .distance:
            disX?.text = "\(roundNum(data.x))"
            disY?.text = "\(roundNum(data.y))"
            disZ?.text = "\(roundNum(data.z))"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


