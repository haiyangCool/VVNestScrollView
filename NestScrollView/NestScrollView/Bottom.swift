//
//  VVNestBootomViewProtocol.swift
//  NestScrollView
//
//  Created by 王海洋 on 2019/9/29.
//  Copyright © 2019 王海洋. All rights reserved.
//

import Foundation
import UIKit

public protocol Bottom: NSObjectProtocol {
    
    /// 底部图层内容大小
    func bottomViewContentSize() -> CGSize
    
    /// 底部高度
    func bottomViewHeight() -> CGFloat
    
    /// 返回底部视图
    func bottomView() -> UIView 
    
    /// 底部图层是否可滑动
    func bottomViewScrollEnable(_ enable: Bool)
    
    /// 更新底部偏移量
    func bottomViewUpdateContentOffset(_ offset: CGPoint)
    
    /// 底部图层偏移量
    func bottomViewContentOffset() -> CGPoint
    
    /// 顶部留白高度
    func excludeTopHeight() -> CGFloat
      
    /// 开始触摸屏幕
    func bottomViewStartTouch()
         
    /// 结束触摸屏幕
    func bottomViewStopTouch()
         
    /// 超出底部基准线： 可以通过该接口实现加载新数据
    func scrollOffBottomBaseLine()
}

