//
//  VVNestBootomViewProtocol.swift
//  NestScrollView
//
//  Created by 王海洋 on 2019/9/29.
//  Copyright © 2019 王海洋. All rights reserved.
//

import Foundation
import UIKit

public protocol VVNestBottomViewProtocol: NSObjectProtocol {
    
    /// 底部图层是否可滑动
    /// - Parameter isScrollEnable: bool
    func nestBottomView(_ isScrollEnable: Bool)
    
    /// 底部图层的偏移量
    /// - Parameter offset: CGPoint
    func nestBottonView(_ offset: CGPoint)
    
    /// 底部图层内容大小
    func bottomViewContentSize() -> CGSize
    
    /// 底部图层偏移量
    func bottomViewContentOffset() -> CGPoint
    
   /**额外占用的空间
       ：自定义view中，页面可能不只是UITableView,或者UICollectionView，整个的view顶部或者底部
          如果有其它的View占位，在这需要返回UITableView,或者UICollectionView以外的其他view的整体高度
          以便在嵌套图层中实现正确的滚动位置
       */
      func excludeViewHeight() -> CGFloat
      
      /// 开始触摸屏幕
      func startTouch()
         
         /// 结束触摸屏幕
      func stopTouch()
         
         /// 超出底部基准线： 可以通过该接口实现加载新数据
      func scrollOffBottomBaseLine() 
}

extension VVNestBottomViewProtocol {}
