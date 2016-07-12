//
//  UIViewExtension.swift
//  ACC
//
//  Created by Hung-Yun Liao on 7/12/16.
//  Copyright © 2016 Hung-Yun Liao. All rights reserved.
//

import UIKit

extension UIView {
    func layerGradient(topColor: CGColor, bottomColor: CGColor) {
        let layer: CAGradientLayer = CAGradientLayer()
        layer.frame = self.frame
        //layer.cornerRadius = CGFloat(frame.width / 20)
        
        layer.colors = [topColor, bottomColor]
        self.layer.insertSublayer(layer, atIndex: 0)
    }
}
