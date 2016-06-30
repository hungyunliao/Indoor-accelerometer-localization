//
//  MapViewController.swift
//  ACC
//
//  Created by Hung-Yun Liao on 6/8/16.
//  Copyright © 2016 Hung-Yun Liao. All rights reserved.
//

import UIKit


class MapViewController: UIViewController, DataProcessorDelegate {
    
    var dataSource: DataProcessor = DataProcessor()
    
    var aax: Double = 0.0
    var aay: Double = 0.0
    
    var publicDB = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var mapView: MapView!
    
    @IBAction func cleanpath(sender: UIButton) {
        mapView?.cleanPath()
    }
    
    @IBOutlet weak var accX: UILabel!
    @IBOutlet weak var accY: UILabel!
    @IBOutlet weak var velX: UILabel!
    @IBOutlet weak var velY: UILabel!
    @IBOutlet weak var disX: UILabel!
    @IBOutlet weak var disY: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.backgroundColor = UIColor.blackColor()
        mapView.setScale(20.0)
        dataSource.startsDetection()
        dataSource.delegate = self
    }
    
    func sendingNewData(person: DataProcessor, type: speedDataType, data: ThreeAxesSystemDouble) {
        switch type {
        case .accelerate:
            accX.text = "\(roundNum(Double(data.x)))"
            accY.text = "\(roundNum(Double(data.y)))"
        case .velocity:
            velX.text = "\(roundNum(Double(data.x)))"
            velY.text = "\(roundNum(Double(data.y)))"
        case .distance:
            mapView.movePointTo(Double(data.x), y: Double(data.y))
            disX.text = "\(roundNum(Double(data.x)))"
            disY.text = "\(roundNum(Double(data.y)))"
        }
    }
    
    func sendingNewStatus(person: DataProcessor, status: String) {
        // intentionally left blank to conform to the protocol
    }
}
