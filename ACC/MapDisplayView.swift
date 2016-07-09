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
    
    override init(frame: CGRect) {
        gridLayer = GridLayer(frame: frame)
        gridLayer.backgroundColor = UIColor.clearColor().CGColor
        pathLayer = PathLayer(frame: frame)
        pathLayer.backgroundColor = UIColor.clearColor().CGColor
        pathLayer.pathColor = UIColor.yellowColor()
        super.init(frame: frame)
        //gridLayer.frame = CGRectMake(0, 0, 100, 100)
        self.layer.addSublayer(gridLayer)
        self.layer.addSublayer(pathLayer)
    }
    
    
    
    internal convenience required init?(coder aDecoder: NSCoder) {
        self.init(frame: CGRectZero)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.addSublayer(gridLayer)
        self.layer.addSublayer(pathLayer)
    }
    
    override var frame: CGRect {
        didSet {
            gridLayer.frame = frame
            pathLayer.frame = frame
        }
    }
    
    
    /*
     relationships:
     1. ViewController: receieves data as a delegate
     2. ViewController calls View to change
     3. View calls layers to change
     */
    func methodForControllerToCall(x: Double, y: Double) {
        pathLayer.movePointTo(x, y: y)
    }
}
