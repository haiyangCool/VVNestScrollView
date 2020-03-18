//
//  VVNestScrollView.swift
//  NestScrollView
//
//  Created by 王海洋 on 2018/4/21.
//  Copyright © 2019 王海洋. All rights reserved.
//

import UIKit
/**
         *******************
         **     TopView   **
         **               **
         **               **
         *******************
         **               **
         **               **
         **               **
         **               **
                
         BottomView(UITableView)
         or (UICollectionView)
         **               **
         **               **
         **               **
         **               **
         *******************

******************
BottomView should implement NestBottomViewProtol methods
******************

*/
public class VVNestScrollView: UIView {

    /// 底部图层需要实现该协议，以获取滑动状态，设置相关操作
    public weak var bottomDelegate: VVNestBottomViewProtocol?
    
    /**
     *   scrollView  承载上部图层和下部图层
     *      scrollView 不可响应手势滑动，而是响应我们自定义的滚动方式
     */
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = false
        scrollView.isScrollEnabled = false
        scrollView.backgroundColor = .white
        return scrollView
    }()
    
    
    /// 顶部图层
    fileprivate var topView: UIView?
    
    /// 底部图层
    fileprivate var bottomView: UIView?
    
    /// 是否为垂直滑动手势
    fileprivate var verticalScroll: Bool = false
    
    /// 实时滑动过程中确定滑动方向，滑动方向一经确认，在该次滑动过程中方向不再进行变更

    fileprivate var scrollDirectionConfirmed: Bool = false
    
    /** 顶部图层高度
     */
    fileprivate var topViewHeight: CGFloat = 0;
    
    
    /** 顶部预留高度
            整体视图向上滚动时，如果topKeepHeight=0，则头部图层滚动至全部隐藏，
            反之，头部图层滚动置 topViewHeight-topKeepHeight后停止，显示topKeepHeight高度的头部图层
     */
    fileprivate var topKeepHeight: CGFloat = 0;
    
    /// 动态滚动item状态
    fileprivate lazy var dynamicItem: VVDynamicItem = VVDynamicItem()
    
    /// 动画执行
    fileprivate var animator: UIDynamicAnimator?
    /// 动态行为 加速/减速
    fileprivate var decelerationBehavior: UIDynamicItemBehavior?
    /// 附着
    fileprivate var spingBehavior: UIAttachmentBehavior?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        animator = UIDynamicAnimator(referenceView: self)
        scrollView.frame = bounds
        addSubview(scrollView)
        registerPanGuster()
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

/**Public Methods
 */
extension VVNestScrollView {
    
    /// 该方法在配置 topView和tbottomView 之前设置，否则会出现动画执行问题
    /// - Parameter height:
    public func setTopKeepHeight(_ height: CGFloat) {
        topKeepHeight = height
        
    }
    
    /// 配置  top View and bottom View
    public func configure(_ top: UIView, bottomView bottom: UIView? = nil, bottomVC viewController: UIViewController? = nil) {
        if let bottom = bottom {

            topView = top
            bottomView = bottom
            configure(topView!, bottom: bottomView!)
            bottomView?.frame = CGRect(origin: CGPoint(x: 0, y: topView!.frame.origin.y), size: (bottom.frame.size))

        }
        
        if let bottom = viewController?.view {

            topView = top
            bottomView = bottom
            configure(topView!, bottom: bottomView!)

        }
        if let topV = topView,let bottomV = bottomView {
            
            bottomV.frame = CGRect(x: 0, y: topV.frame.size.height, width: bottomV.frame.size.width, height: bottomV.frame.size.height)
            scrollView.addSubview(topV)
            scrollView.addSubview(bottomV)
        }
        
        bottomDelegate?.nestBottomView(false)
    }
    
    /// 为可变topView 添加更新（如过topView高度可以变化，reset TopView）
    func reSetTopView(topView view:UIView) {
        topView = view
        if let topV = topView,let bottomV = bottomView {
            bottomV.frame = CGRect(origin: CGPoint(x: 0, y: topV.frame.origin.y), size: (bottomV.frame.size))
            configure(topV, bottom: bottomV)
        }
    }
    
    /** 在底部视图中如果嵌套了横向滑动的控件，
     如果在横向滑动时，需要停止垂直滚动，则【实时】执行该方法
     */
    func stopScroll() {
        animator?.removeAllBehaviors()
        decelerationBehavior = nil
        spingBehavior = nil
    }
}

// 手势
extension VVNestScrollView {
    
    @objc fileprivate func panGusterReceiver(guster: UIPanGestureRecognizer) {
        
        let state = guster.state
        switch state {
        case .began:
            animator?.removeAllBehaviors()
            decelerationBehavior = nil
            spingBehavior = nil
            bottomDelegate?.startTouch()
        case .changed:
            
            let currentX = guster.translation(in: self).x
            let currentY = guster.translation(in: self).y
            if fabsf(Float(currentX/currentY)) >= 5.0{
                
                if !scrollDirectionConfirmed {
                    verticalScroll = false
                    scrollDirectionConfirmed = true
                }
            }else {
                if !scrollDirectionConfirmed {
                    verticalScroll = true
                    scrollDirectionConfirmed = true
                }
            }
            if verticalScroll {
                estimateScroll(with: currentY)
            }

        case .ended:
            bottomDelegate?.stopTouch()
            scrollDirectionConfirmed = false
            if !verticalScroll {
                return
            }
            dynamicItem.center = self.bounds.origin
            let velocity = guster.velocity(in: self)
            let inertialBehavior = UIDynamicItemBehavior(items: [dynamicItem])
            /// 添加线性阻尼
            inertialBehavior.addLinearVelocity(CGPoint(x: 0, y: velocity.y), for: dynamicItem)
            inertialBehavior.resistance = 2.0
            var lastCenter = CGPoint.zero
            inertialBehavior.action = { [weak self] in
                
                if let item = self?.dynamicItem {
                    let cy = item.center.y - lastCenter.y
                    self?.estimateScroll(with: cy)
                    lastCenter = item.center
                }
   
            }
            animator?.addBehavior(inertialBehavior)
            decelerationBehavior = inertialBehavior
        case .cancelled:
            print("")
//            scrollDirectionConfirmed = false
        default:
//            scrollDirectionConfirmed = false
            print("")
        }
        guster.setTranslation(CGPoint.zero, in: self)
        
    }
}

/// 自定义滚动
extension VVNestScrollView {
    
    
    /** 在这里，我们对滚动做出定义
         什么情况下设置为整体的ScrollView进行滚动，什么情况下仅允许底部滚动图层滚动
     
         这里通过整体ScrollView的滑动偏移量是否大于、小于 topViewHeight 来设定
     */
    
    /// - Parameter movedY:
    fileprivate func estimateScroll(with movedY: CGFloat) {
        /// 整体偏移量超过topViewHeight后,topView 已经隐藏,此时开始调整bottomView
        if Int(scrollView.contentOffset.y) >= Int(topViewHeight) {
            
            var btmOffsetY = (bottomDelegate?.bottomViewContentOffset().y)! - movedY
            if btmOffsetY < 0 {
                btmOffsetY = 0
                scrollView.contentOffset = CGPoint(x: 0, y: scrollView.contentOffset.y-movedY)
            }else if (btmOffsetY > ((bottomDelegate?.bottomViewContentOffset().y)!-(bottomView?.frame.size.height)!)) {
               
                btmOffsetY = (bottomDelegate?.bottomViewContentOffset().y)! - rubberBandDistance(Double(movedY), dimension: Double((bottomView?.frame.size.height)!))
            }
            bottomDelegate?.nestBottonView(CGPoint(x: 0, y: btmOffsetY))
            
        }else {
            
            /// Main
            var mainOffsetY = scrollView.contentOffset.y - movedY
            if mainOffsetY < 0 {
                // 远离顶部基准线
                mainOffsetY = scrollView.contentOffset.y - rubberBandDistance(Double(movedY), dimension: Double(UIScreen.main.bounds.size.height))
            }else if (mainOffsetY > topViewHeight) {
                mainOffsetY = topViewHeight
            }
            scrollView.contentOffset = CGPoint(x: 0, y: mainOffsetY)
            if mainOffsetY == 0 {
                bottomDelegate?.nestBottonView(CGPoint.zero)
            }
            
        }
        
        
        /// 超出可是区域判断、添加加减速动画
        let beyondBottom = (bottomDelegate?.bottomViewContentOffset().y)! > (bottomDelegate?.bottomViewContentSize().height)! - (bottomView?.frame.size.height)! + topKeepHeight

        let beyondBounds = scrollView.contentOffset.y < 0 || beyondBottom
        
        if beyondBounds && decelerationBehavior != nil && spingBehavior == nil {
            /// 锚点位置
            var target = CGPoint.zero
            var isMain = false
            if scrollView.contentOffset.y < 0 {
                dynamicItem.center = scrollView.contentOffset
                isMain = true
            }else if (beyondBottom) {
                dynamicItem.center = (bottomDelegate?.bottomViewContentOffset())!
                let bottomExcludeHeight = bottomDelegate?.excludeViewHeight() ?? 0
                
                let bottomTargetOffsetY = (bottomDelegate?.bottomViewContentSize().height)! - (bottomView?.frame.size.height)! + topKeepHeight + bottomExcludeHeight
                target = CGPoint(x: 0, y: bottomTargetOffsetY > 0 ? bottomTargetOffsetY : 0)
                isMain = false
                
            }
            
            animator?.removeBehavior(decelerationBehavior!)
            
            let springAttachBehavior = UIAttachmentBehavior(item: dynamicItem, attachedToAnchor: target)
                       springAttachBehavior.frequency = 2
                       springAttachBehavior.damping = 1
                       springAttachBehavior.length = 0
            springAttachBehavior.action = { [weak self] in
                
                if isMain {
                    self?.scrollView.contentOffset = self!.dynamicItem.center
                    if (self?.scrollView.contentOffset.y)! >= CGFloat(0) {
                        self?.scrollView.contentOffset = CGPoint.zero
                        self?.animator?.removeAllBehaviors()
                        self?.decelerationBehavior = nil
                        self?.spingBehavior = nil
                        
                    }
                }else {
                    let bottomContentOffsetY = self!.bottomDelegate?.bottomViewContentOffset().y
                    if Int(bottomContentOffsetY!) == Int((self?.dynamicItem.center.y)!) {
                        self?.animator?.removeAllBehaviors()
                        self?.decelerationBehavior = nil
                        self?.spingBehavior = nil
                        self?.bottomDelegate?.scrollOffBottomBaseLine()
                    }else {
                    self?.bottomDelegate?.nestBottonView((self?.dynamicItem.center)!)
                    }
                    
                }
                
            }
            
            animator?.addBehavior(springAttachBehavior)
            spingBehavior = springAttachBehavior
            
        }
        
    }
}

/** Private Method
 */
extension VVNestScrollView {
    
    /// 注册pan手势
    fileprivate func registerPanGuster() {
        
        let panGuster = UIPanGestureRecognizer(target: self, action: #selector(panGusterReceiver(guster:)))
        panGuster.delegate = self
        scrollView.addGestureRecognizer(panGuster)
    }
    
    /// 配置顶部和底部图层
    /// - Parameter topView: topView
    /// - Parameter view: bottomView
    fileprivate func configure(_ topView: UIView, bottom view: UIView) {
        
        let topHeight = topView.frame.size.height
        let bottomHeight = view.frame.size.height
        let contentSizeHeight = topHeight + bottomHeight
        topViewHeight = topHeight - topKeepHeight
        scrollView.contentSize = CGSize(width: bounds.size.width, height: contentSizeHeight)
        if contentSizeHeight <= bounds.size.height {
            scrollView.isScrollEnabled = false
        }
    }
    
    fileprivate func rubberBandDistance(_ offset:Double, dimension: Double) -> CGFloat {
           
           let constant = 0.55
           let result = (constant * fabs(offset) * dimension) / (dimension + constant * fabs(offset));
           // The algorithm expects a positive offset, so we have to negate the result if the offset was negative.
           return offset < 0.0 ? CGFloat(-result) : CGFloat(result)
    }
}


extension VVNestScrollView: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}
