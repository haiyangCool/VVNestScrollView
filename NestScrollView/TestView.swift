//
//  TestView.swift
//  Scroll
//
//  Created by hyw on 2018/11/5.
//  Copyright © 2018年 haiyang_wang. All rights reserved.
//

import UIKit
let NavHeight:CGFloat = 50
let KScreenWidth: CGFloat = UIScreen.main.bounds.size.width
let KScreenHeight: CGFloat = UIScreen.main.bounds.size.height
class TestView: UIView {
    var scrollEnable:Bool = false
    lazy var navLabel: UILabel = {
        let navLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: NavHeight))
        navLabel.text = "this can be a Navigation"
        navLabel.textColor = UIColor.red
        return navLabel
    }()
    lazy var tab: UITableView = {
        let tab = UITableView.init(frame: CGRect(x: 0, y: NavHeight, width: KScreenWidth, height: KScreenHeight), style: .plain)
        tab.backgroundColor = UIColor.clear
        tab.dataSource = self
        tab.delegate = self
        tab.isScrollEnabled = true
        return tab
    }()
    
    fileprivate var contentOFfset:CGPoint = CGPoint.zero
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
       
        self.addSubview(navLabel)
        self.addSubview(tab)
    
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   
}
extension TestView:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 3 {
            return 120
        }
        return 150
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: KScreenWidth, height: 44)
        label.text = "test"
        label.textAlignment = .center
        label.textColor = .purple
        if indexPath.row == 3 {
            let scr = UIScrollView()
            scr.frame = CGRect(x: 0, y: 0, width: KScreenWidth, height: 120)
            scr.contentSize = CGSize(width: 700, height: 120)
            scr.backgroundColor = UIColor.orange
            scr.showsHorizontalScrollIndicator = true
            cell.contentView.addSubview(scr)
        }else {
            cell.contentView.addSubview(label)
        }
        return cell
        
        
    }

}
extension TestView: Bottom {
    func bottomViewContentSize() -> CGSize {
        return tab.contentSize
    }
    
    func bottomViewHeight() -> CGFloat {
        return KScreenHeight
    }
    
    func bottomView() -> UIView {
        return self
    }
    
    func bottomViewScrollEnable(_ enable: Bool) {
        tab.isScrollEnabled = enable
    }
    
    func bottomViewUpdateContentOffset(_ offset: CGPoint) {
        tab.contentOffset = offset
    }
    
    func bottomViewContentOffset() -> CGPoint {
        return tab.contentOffset
    }
    
    func excludeTopHeight() -> CGFloat {
        return 88
    }
    
    func bottomViewStartTouch() {
        
    }
    
    func bottomViewStopTouch() {
        
    }
    
    func scrollOffBottomBaseLine() {
        
    }
    

}


//extension TestView: NestBottomViewProtocol {
//    func startTouch() {
//
//    }
//
//    func stopTouch() {
//
//    }
//
//    func scrollOffBottomBaseLine() {
//        
//    }
//
//    func bottomView(_ isScrollEnable: Bool) {
//        tab.isScrollEnabled = isScrollEnable
//    }
//
//
//    func contentSize() -> CGSize {
//        return tab.contentSize
//    }
//
//    func contentOffset() -> CGPoint {
//        return tab.contentOffset
//    }
//
//    func excludeTopHeight() -> CGFloat {
//        return NavHeight
//    }
//
    
    
//}
