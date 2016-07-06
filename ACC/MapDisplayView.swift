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
    
    override init(frame: CGRect) {
        gridLayer = GridLayer(frame: frame)
        super.init(frame: frame)
        
        self.layer.addSublayer(gridLayer)
    }
    
    internal convenience required init?(coder aDecoder: NSCoder) {
        self.init(frame: CGRectZero)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.addSublayer(gridLayer)
    }
    
    override var frame: CGRect {
        didSet {
            gridLayer.frame = frame
        }
    }
}
