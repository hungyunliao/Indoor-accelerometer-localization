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
        if mapView != nil {
            mapView.cleanMovement()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.backgroundColor = UIColor.blackColor()
        mapView.setScale(100.0)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updatePosition(_:)), name:"PositionChanged", object: nil)
        //self.view.backgroundColor = UIColor.greenColor()
    }
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSUserDefaultsDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func updatePosition(notification: NSNotification){
        
        if let getX = publicDB.stringForKey("x") {
            mapView.moveXTo(Double(getX)!)
        } else {
            mapView.moveXTo(0.0)
        }
        
        if let getY = publicDB.stringForKey("y") {
            mapView.moveYTo(Double(getY)!)
        } else {
            mapView.moveYTo(0.0)
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
