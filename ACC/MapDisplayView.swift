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
    private var text: TextLayer
    
    override init(frame: CGRect) {
        gridLayer = GridLayer(frame: frame)
        gridLayer.backgroundColor = UIColor.clearColor().CGColor
        pathLayer = PathLayer(frame: frame)
        pathLayer.backgroundColor = UIColor.clearColor().CGColor
        text = TextLayer(frame: frame)
//        let fontName: CFStringRef = "HelveticaNeue"
//        text.font = CTFontCreateWithName(fontName, 1, nil)
        text.startValue = 0
        super.init(frame: frame)
        //gridLayer.frame = CGRectMake(0, 0, 100, 100)
        self.layer.addSublayer(gridLayer)
        self.layer.addSublayer(pathLayer)
        self.layer.addSublayer(text)
    }
    
    
    
    internal convenience required init?(coder aDecoder: NSCoder) {
        self.init(frame: CGRectZero)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.addSublayer(gridLayer)
        self.layer.addSublayer(pathLayer)
        self.layer.addSublayer(text)
    }
    
    override var frame: CGRect {
        didSet {
            print("in frame in MapDisplay \(frame.size)")
            gridLayer.frame = frame
            pathLayer.frame = frame
            text.frame = CGRectMake(0, gridLayer.frame.height/2, gridLayer.frame.width, gridLayer.frame.height)
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
