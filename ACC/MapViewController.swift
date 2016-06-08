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
    
    
    @IBOutlet weak var mapView: MapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        self.view.backgroundColor = UIColor.greenColor()
    }
    
    func updateUI() {
        mapView.mapx = 500.0
        mapView.mapy = 40.0
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
