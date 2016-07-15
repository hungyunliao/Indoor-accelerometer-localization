//
//  MapViewController.swift
//  ACC
//
//  Created by Hung-Yun Liao on 6/8/16.
//  Copyright © 2016 Hung-Yun Liao. All rights reserved.
//

import UIKit


class MapViewController: UIViewController, DataProcessorDelegate {
    
    // MARK: Model
    var dataSource: DataProcessor? = nil
    
    // MARK: PublicDB used to pass the object of DataProcessor
    var publicDB = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var mapView: MapView!
    
    @IBAction func cleanpath(sender: UIButton) {
        mapView?.cleanPath()
    }
    
    // MARK: Outlets
    @IBOutlet weak var accX: UILabel!
    @IBOutlet weak var accY: UILabel!
    @IBOutlet weak var velX: UILabel!
    @IBOutlet weak var velY: UILabel!
    @IBOutlet weak var disX: UILabel!
    @IBOutlet weak var disY: UILabel!
    
    // MARK: Override functions
    override func viewDidLoad() {
        
        mapView.backgroundColor = UIColor.blackColor()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(receiveDataSource(_:)), name:"dataSource", object: nil)
        mapView.setScale(20.0)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        dataSource?.delegate = self
    }
    
    // MARK: Functions
    func receiveDataSource(notification: NSNotification) {
        if let source = notification.object as? DataProcessor {
            dataSource = source
            dataSource!.startsDetection()
        }
    }
    
    // MARK: Delegate
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
