//
//  VVDynamicItem.swift
//  NestScrollView
//
//  Created by 王海洋 on 2018/4/12.
//  Copyright © 2019 王海洋. All rights reserved.
//

import UIKit
import Foundation
class DynamicItem: NSObject, UIDynamicItem {
    var transform: CGAffineTransform
    var center: CGPoint
    var bounds: CGRect
    
    override init() {
        center = CGPoint(x: 0, y: 0)
        bounds = CGRect(x: 0, y: 0, width: 1, height: 1)
        transform = CGAffineTransform.init()
    }
}
