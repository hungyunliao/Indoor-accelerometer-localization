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
        //self.layerGradient(UIColor.blackColor().CGColor, bottomColor: UIColor.whiteColor().CGColor)
        //self.backgroundColor = UIColor.redColor()
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
            textLayer.frame = CGRectMake(0, gridLayer.frame.height/2, gridLayer.frame.width, gridLayer.frame.height)
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
}
