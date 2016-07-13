//
//  Filter.swift
//  ACC
//
//  Created by kai-hsiang, lien on 2016/7/11.
//  Copyright © 2016年 Hung-Yun Liao. All rights reserved.
//

import Foundation

protocol Filter {
    
    func initFilter(deviceMotionUpdateInterval: Double)
    
    func filter<T>(x: T, y: T, z: T) -> (T, T, T)
}