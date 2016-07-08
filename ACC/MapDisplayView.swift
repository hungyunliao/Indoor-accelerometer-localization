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
    private let gridLayer: GridLayer
    //private let gridLayer2: PathLayer
    
    override init(frame: CGRect) {
        gridLayer = GridLayer(frame: frame)
//        gridLayer2 = PathLayer(frame: frame)
//        gridLayer2.pathColor = UIColor.yellowColor()
        super.init(frame: frame)
        
        
        self.layer.addSublayer(gridLayer)
//        self.layer.addSublayer(gridLayer2)
    }
    
    internal convenience required init?(coder aDecoder: NSCoder) {
        self.init(frame: CGRectZero)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.addSublayer(gridLayer)
//        self.layer.addSublayer(gridLayer2)
    }
    
    override var frame: CGRect {
        didSet {
            gridLayer.frame = frame
//            gridLayer2.frame = frame
        }
    }
    
    
    /*
     relationships:
     1. ViewController: receieves data
     2. ViewController calls View to change
     3. View calls layers to change
     */
    func methodForControllerToCall(x: Double, y: Double) {
//        gridLayer2.movePointTo(x, y: y)
    }
}
