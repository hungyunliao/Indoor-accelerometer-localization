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
    
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var gridView: GridView!
    @IBOutlet weak var mapView: MapView! {
        didSet {
            
            // add pinch gesture recog
            mapView.addGestureRecognizer(UIPinchGestureRecognizer(
                target: self, action: #selector(MapViewController.changeScale(_:))
                ))
            
            // add swipe gestures recog
            let rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(MapViewController.moveScreenToRight))
            rightSwipeGestureRecognizer.direction = .Right
            mapView.addGestureRecognizer(rightSwipeGestureRecognizer)
            
            let upSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(MapViewController.moveScreenToUp))
            upSwipeGestureRecognizer.direction = .Up
            mapView.addGestureRecognizer(upSwipeGestureRecognizer)
            
            let downSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(MapViewController.moveScreenToDown))
            downSwipeGestureRecognizer.direction = .Down
            mapView.addGestureRecognizer(downSwipeGestureRecognizer)
            
            let leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(MapViewController.moveScreenToLeft))
            leftSwipeGestureRecognizer.direction = .Left
            mapView.addGestureRecognizer(leftSwipeGestureRecognizer)
            
        }
    }
    
    /* MARK: Gesture Functions */
    var pinchScale: CGFloat = 1
    
    func changeScale(recognizer: UIPinchGestureRecognizer) {
        
        switch recognizer.state {
        case .Changed, .Ended:
            
            pinchScale *= recognizer.scale
            pinchScale = toZeroPointFiveMultiples(pinchScale) // let pinchScale always be the multiples of 0.5 to keep the textLayer clean.
            
            if pinchScale == 0 { // restrict the minimum scale to 0.5 instead of 0, otherwise the scale will always be 0 afterwards.
                pinchScale = 0.5
            }
            
            let times = pinchScale/CGFloat(gridView.scaleValueForTheText)
            
            if gridView.scaleValueForTheText != 0.5 || pinchScale != 0.5 {
                mapView.setScale(Double(1/times))
            }
            
            gridView.scaleValueForTheText = Double(pinchScale)
            recognizer.scale = 1
        default:
            break
        }

    }
    
    var shiftedBySwipe = ThreeAxesSystem<Double>(x:0, y:0, z:0)
    let shiftAmount: Double = 20
    
    func moveScreenToRight() {
        shiftedBySwipe.x += shiftAmount
        origin.x += shiftAmount
        setOrigin(origin.x, y: origin.y)
    }
    
    func moveScreenToUp() {
        shiftedBySwipe.y -= shiftAmount
        origin.y -= shiftAmount
        setOrigin(origin.x, y: origin.y)
    }
    
    func moveScreenToDown() {
        shiftedBySwipe.y += shiftAmount
        origin.y += shiftAmount
        setOrigin(origin.x, y: origin.y)
    }
    
    func moveScreenToLeft() {
        shiftedBySwipe.x -= shiftAmount
        origin.x -= shiftAmount
        setOrigin(origin.x, y: origin.y)
    }
    
    // MARK: Outlets
    @IBOutlet weak var accX: UILabel!
    @IBOutlet weak var accY: UILabel!
    @IBOutlet weak var velX: UILabel!
    @IBOutlet weak var velY: UILabel!
    @IBOutlet weak var disX: UILabel!
    @IBOutlet weak var disY: UILabel!
    
    @IBAction func cleanpath(sender: UIButton) {
        mapView?.cleanPath()
    }
    
    private func setOrigin(x: Double, y: Double) {
        gridView?.setOrigin(x, y: y)
        mapView?.setOrigin(x, y: y)
    }
    
    // MARK: Override functions
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(receiveDataSource(_:)), name:"dataSource", object: nil)
        
        // MapDisplayView API setup
        gridView.backgroundColor = UIColor.clearColor()
        gradientView.frame = view.frame
        gridView.scaleValueForTheText = 1
        
        mapView.backgroundColor = UIColor.clearColor()
        mapView.frame = view.frame
        mapView.setScale(1.0)
        
        (origin.x, origin.y) = (Double(view.frame.midX), Double(view.frame.midY))
        setOrigin(origin.x, y: origin.y)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.currentDevice().orientation.isLandscape.boolValue {
            //print("Landscape - \(view.frame.size)")
            if mapView != nil {
                mapView.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.height, view.frame.width)
                gradientView.frame = mapView.frame
                (origin.x, origin.y) = (Double(mapView.frame.midX) + shiftedBySwipe.x, Double(mapView.frame.midY) + shiftedBySwipe.y)
                setOrigin(origin.x, y: origin.y)
            }
     } else {
            //print("Portrait - \(view.frame.size)")
            if mapView != nil {
                mapView.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.height, view.frame.width)
                gradientView.frame = mapView.frame
                (origin.x, origin.y) = (Double(mapView.frame.midX) + shiftedBySwipe.x, Double(mapView.frame.midY) + shiftedBySwipe.y)
                setOrigin(origin.x, y: origin.y)
            }
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
            mapView.movePointTo(Double(data.x) * magnify, y: Double(data.y) * magnify)
            disX.text = "\(roundNum(Double(data.x)) * magnify)"
            disY.text = "\(roundNum(Double(data.y)) * magnify)"
        }
    }
    
    func sendingNewStatus(person: DataProcessor, status: String) {
        // intentionally left blank to conform to the protocol
    }
}
