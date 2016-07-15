//
//  MapDisplayView.swift
//  ACC
//
//  Created by Antonio081014 on 7/6/16.
//  Copyright © 2016 Hung-Yun Liao. All rights reserved.
//

import UIKit

@IBDesignable
class MapDisplayView: UIView {
    private var pinchScale: CGFloat = 1
    private var gridLayer: GridLayer
    private var pathLayer: PathLayer
    private var textLayer: TextLayer
    
    override init(frame: CGRect) {
        gridLayer = GridLayer(frame: frame)
        pathLayer = PathLayer(frame: frame)
        textLayer = TextLayer(frame: frame)
        super.init(frame: frame)
        self.layer.addSublayer(gridLayer)
        self.layer.addSublayer(pathLayer)
        self.layer.addSublayer(textLayer)
    }
    
    
    internal convenience required init?(coder aDecoder: NSCoder) {
        self.init(frame: CGRectZero)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.addSublayer(gridLayer)
        self.layer.addSublayer(pathLayer)
        self.layer.addSublayer(textLayer)
    }
    
    override var frame: CGRect {
        didSet {
            gridLayer.frame = frame
            pathLayer.frame = frame
            //textLayer.frame = CGRectMake(0, frame.height/2, frame.width, frame.height)
            textLayer.frame = frame
        }
    }
    
    
    /*
     relationships:
     1. ViewController: receieves data as a delegate
     2. ViewController calls View to change
     3. View calls layers to change
     */
    func movePointTo(x: Double, y: Double) {
        pathLayer.movePointTo(x, y: y)
    }
    func cleanPath() {
        pathLayer.cleanPath()
    }
    func setScale(scale: Double) {
        textLayer.scaleValue = scale
        pathLayer.setScale(scale)
    }
    
    func changeScale(recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .Ended:
            
            pinchScale *= recognizer.scale
            pinchScale = toZeroPointFiveMultiples(pinchScale) // let pinchScale always be the multiples of 0.5 to keep the textLayer clean.
            
            if pinchScale == 0 { // restrict the minimum scale to 0.5 instead of 0, otherwise the scale will always be 0 afterwards.
                pinchScale = 0.5
            }
            
            let times = pinchScale/CGFloat(textLayer.scaleValue)
            
            if textLayer.scaleValue != 0.5 || pinchScale != 0.5 {
                pathLayer.setScale(Double(1/times))
            }
            
            textLayer.scaleValue = Double(pinchScale)
            recognizer.scale = 1
        default:
            break
        }
    }
    
    func setOrigin(x: Double, y: Double) {
        pathLayer.setOrigin(x, y: y)
        gridLayer.setOrigin(x, y: y)
        textLayer.setOrigin(x, y: y)
    }

}

func toZeroPointFiveMultiples(x: CGFloat) -> CGFloat { // decrease 'x' to the closest *.5  ex: 1.73 -> 1.5, 3.21 -> 3.0, 0.33 -> 0
    return CGFloat(Int(x/0.5)) * 0.5
    
}