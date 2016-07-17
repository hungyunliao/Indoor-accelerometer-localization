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
    var origin = ThreeAxesSystem<Double>(x: 0, y: 0, z: 0)
    
    // MARK: PublicDB used to pass the object of DataProcessor
    var publicDB = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var gridView: GridView!
    @IBOutlet weak var mapDisplayView: MapView! {
        didSet {
            mapDisplayView.addGestureRecognizer(UIPinchGestureRecognizer(
                target: self, action: #selector(MapViewController.changeScale(_:))
                ))
            
            let rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(MapViewController.moveScreenToRight))
            rightSwipeGestureRecognizer.direction = .Right
            mapDisplayView.addGestureRecognizer(rightSwipeGestureRecognizer)
            
            let upSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(MapViewController.moveScreenToUp))
            upSwipeGestureRecognizer.direction = .Up
            mapDisplayView.addGestureRecognizer(upSwipeGestureRecognizer)
            
            let downSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(MapViewController.moveScreenToDown))
            downSwipeGestureRecognizer.direction = .Down
            mapDisplayView.addGestureRecognizer(downSwipeGestureRecognizer)
            
            let leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(MapViewController.moveScreenToLeft))
            leftSwipeGestureRecognizer.direction = .Left
            mapDisplayView.addGestureRecognizer(leftSwipeGestureRecognizer)
            
            
        }
    }
    
    func setOrigin(x: Double, y: Double) {
        gridView.setOrigin(x, y: y)
        mapDisplayView.setOrigin(x, y: y)
    }
    
    func changeScale(sender: UIPinchGestureRecognizer) {
        print("in the mapviewController")
    }
    
    func moveScreenToRight() {
        origin.x += 20
        setOrigin(origin.x, y: origin.y)
    }
    
    func moveScreenToUp() {
        origin.y -= 20
        setOrigin(origin.x, y: origin.y)
    }
    
    func moveScreenToDown() {
        origin.y += 20
        setOrigin(origin.x, y: origin.y)
    }
    
    func moveScreenToLeft() {
        origin.x -= 20
        setOrigin(origin.x, y: origin.y)
    }
    
    @IBAction func cleanpath(sender: UIButton) {
        mapDisplayView?.cleanPath()
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
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(receiveDataSource(_:)), name:"dataSource", object: nil)
        
        // MapDisplayView API setup
        mapDisplayView.setScale(1.0)
        mapDisplayView.frame = view.frame
        origin.x = Double(mapDisplayView.frame.midX)
        origin.y = Double(mapDisplayView.frame.midY)
        setOrigin(origin.x, y: origin.y)
        //mapDisplayView.layerGradient(UIColor.whiteColor().CGColor, bottomColor: UIColor.cyanColor().colorWithAlphaComponent(0.5).CGColor)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.currentDevice().orientation.isLandscape.boolValue {
            print("Landscape")
            //viewDidLoad()
//            let tempMap: MapDisplayView = MapDisplayView(frame: CGRectMake(30, 30, 100, 100))
//            tempMap.setOrigin(origin.x, y: origin.y)
//            mapDisplayView.addSubview(tempMap)

     } else {
            print("Portrait")
//            let tempMap: MapDisplayView = MapDisplayView(frame: CGRectMake(100, 100, 100, 100))
//            tempMap.setOrigin(origin.x, y: origin.y)
//            mapDisplayView = tempMap
        }
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
            let magnify = 10.0
            mapDisplayView.movePointTo(Double(data.x) * magnify, y: Double(data.y) * magnify)
            disX.text = "\(roundNum(Double(data.x)) * magnify)"
            disY.text = "\(roundNum(Double(data.y)) * magnify)"
        }
    }
    
    func sendingNewStatus(person: DataProcessor, status: String) {
        // intentionally left blank to conform to the protocol
    }
}
