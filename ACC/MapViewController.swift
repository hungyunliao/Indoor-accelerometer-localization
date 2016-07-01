//
//  MapViewController.swift
//  ACC
//
//  Created by Hung-Yun Liao on 6/8/16.
//  Copyright © 2016 Hung-Yun Liao. All rights reserved.
//

import UIKit


class MapViewController: UIViewController {
    
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
    
    @IBOutlet weak var backgroundLayer: BackgroundLayer!
    @IBOutlet weak var frontLayer: FrontLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundLayer.backgroundColor = UIColor.blueColor()
        frontLayer.backgroundColor = UIColor.redColor()
        //backgroundLayer.testfunc()
        
        mapView.backgroundColor = UIColor.blackColor()
        mapView.setScale(50.0)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updatePosition(_:)), name:"PositionChanged", object: nil)
        //self.view.backgroundColor = UIColor.greenColor()
    }
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSUserDefaultsDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func updatePosition(notification: NSNotification){
        
//        if let getDisX = publicDB.stringForKey("x") {
//            mapView.moveXTo(Double(getDisX)!)
//            disX.text = "\(roundNum(Double(getDisX)!))"
//        }
//        
//        if let getDisY = publicDB.stringForKey("y") {
//            mapView.moveYTo(Double(getDisY)!)
//            disY.text = "\(roundNum(Double(getDisY)!))"
//        }
        
        if let getDisX = publicDB.stringForKey("x") {
            if let getDisY = publicDB.stringForKey("y") {
                mapView.movePointTo(Double(getDisX)!, y: Double(getDisY)!)
                disX.text = "\(roundNum(Double(getDisX)!))"
                disY.text = "\(roundNum(Double(getDisY)!))"
            }
        }
        
        if let getAccX = publicDB.stringForKey("accX") {
            accX.text = "\(roundNum(Double(getAccX)!))"
        }
        if let getAccY = publicDB.stringForKey("accY") {
            accY.text = "\(roundNum(Double(getAccY)!))"
        }
        if let getVelX = publicDB.stringForKey("velX") {
            velX.text = "\(roundNum(Double(getVelX)!))"
        }
        if let getVelY = publicDB.stringForKey("velY") {
            velY.text = "\(roundNum(Double(getVelY)!))"
        }
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
