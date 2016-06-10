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
    
    var prefs = NSUserDefaults.standardUserDefaults() {
        didSet {
            updateUI()
        }
    }
    
    
    
    @IBOutlet weak var mapView: MapView! {
        didSet {
            updateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(methodOfReceivedNotification(_:)), name:"NotificationIdentifier", object: nil)

        
        self.view.backgroundColor = UIColor.greenColor()
    }
//    deinit {
//        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSUserDefaultsDidChangeNotification, object: nil)
//    }
    
    func methodOfReceivedNotification(notification: NSNotification){
        if let getX = prefs.stringForKey("x") {
            mapView.mapx = Double(getX)!
        } else {
            mapView.mapx = 0
        }
        
        if let getY = prefs.stringForKey("y") {
            mapView.mapy = Double(getY)!
        } else {
            mapView.mapy = 0
        }
//        NSNotificationCenter.defaultCenter().removeObserver(self, name: "NotificationIdentifier", object: nil)
//        NSNotificationCenter.defaultCenter().removeObserver(self)

    }
    
    func updateUI() {
        
        
//        if let getX = prefs.stringForKey("x") {
//            mapView.mapx = Double(getX)!
//        } else {
//            mapView.mapx = 0
//        }
//        
//        if let getY = prefs.stringForKey("y") {
//            mapView.mapy = Double(getY)!
//        } else {
//            mapView.mapy = 0
//        }
        
        
    }
    
    //    func moveTo(x: Double, y: Double) {
    //        aax = x
    //        aay = y
    //    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
