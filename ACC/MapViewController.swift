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
    
    // MARK: Multi-views declaration
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
            
            gridView.setScale(Double(pinchScale))
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
    
    private func updateUIWithGivenFrame(originX: CGFloat, originY: CGFloat, width: CGFloat, height: CGFloat) {
        // All view are set based on the "gradientView" (background)
        gradientView.frame = CGRectMake(originX, originY, width, height)
        gridView.frame = gradientView.frame
        mapView.frame = gradientView.frame
        (origin.x, origin.y) = (Double(gradientView.frame.midX) + shiftedBySwipe.x, Double(gradientView.frame.midY) + shiftedBySwipe.y)
        setOrigin(origin.x, y: origin.y)
    }
    
    // MARK: Override functions
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(receiveDataSource(_:)), name:"dataSource", object: nil)
        
        // Objects setup
        gradientView.colorSetUp(UIColor.whiteColor().CGColor, bottomColor: UIColor.cyanColor().colorWithAlphaComponent(0.5).CGColor)
        
        gridView.backgroundColor = UIColor.clearColor()
        gridView.setScale(1.0)
        
        mapView.backgroundColor = UIColor.clearColor()
        mapView.setScale(1.0)
        
        updateUIWithGivenFrame(view.frame.origin.x, originY: view.frame.origin.y, width: view.frame.width, height: view.frame.height)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.currentDevice().orientation.isLandscape.boolValue {
            // Landscape orientation
            if mapView != nil {
                updateUIWithGivenFrame(view.frame.origin.x, originY: view.frame.origin.y, width: view.frame.height, height: view.frame.width)
            }
     } else {
            // Portrait orientation
            if mapView != nil {
                updateUIWithGivenFrame(view.frame.origin.x, originY: view.frame.origin.y, width: view.frame.height, height: view.frame.width)
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        dataSource?.delegate = self
    }
    
    // MARK: Notification center functions
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
            let magnify = 20.0 // this var is used to make the movement more observable. Basically, if the scale of the map is 1, then magnify should be 20. if 2, then 40.
            mapView.movePointTo(Double(data.x) * magnify, y: Double(data.y) * magnify)
            disX.text = "\(roundNum(Double(data.x)))"
            disY.text = "\(roundNum(Double(data.y)))"
        }
    }
    
    func sendingNewStatus(person: DataProcessor, status: String) {
        // intentionally left blank in order to conform to the protocol
    }
}
